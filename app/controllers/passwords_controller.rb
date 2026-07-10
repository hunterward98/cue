# frozen_string_literal: true

# Password reset (auth plan_2): request → emailed link → set new password
# → every session revoked + notification email. The reset token is only
# consumed when the new password actually saves, so a validation stumble
# doesn't strand the user with a dead link.
class PasswordsController < InertiaController
  allow_unauthenticated_access

  def new
    render inertia: "auth/forgot_password"
  end

  def create
    email = params[:email_address].to_s.strip.downcase
    user = User.find_by(email_address: email)

    if user&.password_login?
      issued = AuthToken.issue!(user:, purpose: "password_reset")
      AuthMailer.password_reset(user, link_token: issued.link_token).deliver_later
      AuthEvent.record!("password_reset_requested", user:, request:)
    end

    redirect_to new_session_path,
                notice: "If that address has a password to reset, instructions are on their way."
  end

  def edit
    return invalid_link unless peeked_token

    render inertia: "auth/reset_password", props: { token: params[:token] }
  end

  def update
    token = peeked_token
    return invalid_link unless token

    user = token.user
    user.password = params[:password].to_s

    if user.save
      token.consume!
      user.sessions.destroy_all
      cookies.delete(:session_id)
      AuthEvent.record!("password_reset_completed", user:, request:)
      AuthMailer.password_changed(user).deliver_later
      redirect_to new_session_path, notice: "Password reset. Sign in with the new one."
    else
      redirect_to edit_password_path(params[:token]), inertia: { errors: user.errors }
    end
  end

  private

  def peeked_token
    AuthToken.peek_link(purpose: "password_reset", link_token: params[:token].to_s)
  end

  def invalid_link
    redirect_to new_password_path, alert: "That reset link is invalid or has expired. Request a new one."
  end
end
