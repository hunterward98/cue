# frozen_string_literal: true

# Requests a one-time login code (the passwordless path, ratified A1).
# The response never varies: unknown emails and password-mode accounts
# get the same screen — password-mode accounts get a nudge email instead
# of a code (same trick as signup's existing-account email).
class LoginCodesController < InertiaController
  allow_unauthenticated_access

  def create
    email = params[:email_address].to_s.strip.downcase
    user = User.find_by(email_address: email)

    if user&.password_login?
      AuthMailer.password_login_reminder(user).deliver_later
    elsif user
      issued = AuthToken.issue!(user:, purpose: "login_code")
      AuthMailer.login_code(user, code: issued.code, link_token: issued.link_token).deliver_later
      AuthEvent.record!("login_code_requested", user:, request:)
    end

    session[:pending_login_email] = email
    redirect_to new_session_path,
                notice: "If that address has an account, a sign-in code is on its way."
  end

  def confirm
    token = AuthToken.redeem_link(purpose: "login_code", link_token: params[:token])

    if token
      token.user.verify!
      AuthEvent.record!("login_succeeded", user: token.user, request:, metadata: { mode: "magic_link" })
      start_new_session_for(token.user)
      redirect_to organizations_path, notice: "Signed in. No password, no fuss."
    else
      redirect_to new_session_path, alert: "That sign-in link is invalid or has expired. Request a fresh one."
    end
  end
end
