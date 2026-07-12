# frozen_string_literal: true

# Login/logout (auth plan_2). One create endpoint, two proofs: a password
# or an emailed code. Failure responses are identical for unknown emails,
# wrong passwords, wrong modes, and wrong codes — no enumeration oracle.
# Rails' authenticate_by runs a dummy digest on misses (timing parity).
class SessionsController < InertiaController
  allow_unauthenticated_access only: %i[new create]
  allow_unverified_access only: :destroy

  INVALID_LOGIN = "That email and proof didn't line up. Check both and try again."

  def new
    return redirect_to organizations_path if authenticated?

    render inertia: "auth/login", props: {
      code_sent: session[:pending_login_email],
      email_address: params[:email_address]
    }
  end

  def create
    user = params[:code].present? ? authenticate_with_code : authenticate_with_password

    if user && !user.locked?
      user.register_successful_login!
      AuthEvent.record!("login_succeeded", user:, request:,
                        metadata: { mode: params[:code].present? ? "code" : "password" })
      session.delete(:pending_login_email)
      start_new_session_for(user)
      redirect_to after_login_url(user)
    else
      handle_failed_login
    end
  end

  def destroy
    AuthEvent.record!("logout", user: Current.user, request:)
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Signed out. The cues will wait."
  end

  private

  def authenticate_with_password
    user = User.authenticate_by(params.permit(:email_address, :password))
    user if user&.password_login?
  end

  def authenticate_with_code
    # The email comes from the server-side session, planted when the code
    # was requested — the client only supplies the code. A code typed into
    # a browser that never requested one fails like any bad login.
    email = session[:pending_login_email].to_s
    user = User.find_by(email_address: email)
    return nil unless user

    token = AuthToken.redeem_code(user:, purpose: "login_code", code: params[:code].to_s)
    return nil unless token

    # A redeemed login code proves email ownership as thoroughly as a
    # verification code does.
    user.verify!
    user
  end

  def after_login_url(user)
    return email_verification_path unless user.verified?

    after_authentication_url
  end

  # One failure path for every cause — wrong password, unknown email,
  # wrong code, locked account — so responses can't become an oracle.
  # Crossing the threshold locks the account and emails the unlock link.
  def handle_failed_login
    attempted_email = (params[:email_address].presence || session[:pending_login_email]).to_s.strip.downcase
    user = User.find_by(email_address: attempted_email)

    if user&.register_failed_login!
      issued = AuthToken.issue!(user:, purpose: "unlock")
      AuthMailer.account_locked(user, link_token: issued.link_token).deliver_later
      AuthEvent.record!("account_locked", user:, request:)
    end

    AuthEvent.record!("login_failed", user:, request:)
    redirect_to new_session_path, alert: INVALID_LOGIN
  end
end
