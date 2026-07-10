# frozen_string_literal: true

# The verification gate (auth plan_2): unverified accounts land here and
# nowhere else. Works with or without a session — signup doesn't log you
# in, so the pending email travels in the Rails session cookie. Code and
# resend responses are identical whether or not the email maps to an
# account (no enumeration oracle).
class EmailVerificationsController < InertiaController
  allow_unauthenticated_access

  def show
    return redirect_to new_session_path if pending_email.blank?
    return redirect_to root_path if Current.user&.verified?

    render inertia: "auth/check_inbox", props: { email: pending_email }
  end

  def update
    user = pending_user

    if user && AuthToken.redeem_code(user:, purpose: "email_verification", code: params[:code].to_s)
      complete_verification(user)
    else
      redirect_to email_verification_path, alert: "That code didn't work. It may have expired — codes only live 15 minutes."
    end
  end

  def resend
    if (user = pending_user) && !user.verified?
      issued = AuthToken.issue!(user:, purpose: "email_verification")
      AuthMailer.email_verification(user, code: issued.code, link_token: issued.link_token).deliver_later
      AuthEvent.record!("verification_resent", user:, request:)
    end

    redirect_to email_verification_path, notice: "If that address needs verifying, a fresh code is on its way."
  end

  def confirm
    token = AuthToken.redeem_link(purpose: "email_verification", link_token: params[:token])

    if token
      complete_verification(token.user)
    else
      redirect_to new_session_path, alert: "That link is invalid or has expired. Sign in to request a new one."
    end
  end

  private

  def pending_email
    session[:pending_verification_email].presence || Current.user&.email_address
  end

  def pending_user
    email = pending_email
    email && User.find_by(email_address: email)
  end

  def complete_verification(user)
    user.verify!
    AuthEvent.record!("email_verified", user:, request:)
    session.delete(:pending_verification_email)
    start_new_session_for(user) unless Current.user == user
    redirect_to root_path, notice: "You're verified. Welcome to Cue."
  end
end
