# frozen_string_literal: true

# Signup (auth plan_2, ratified A1: the user picks password or
# passwordless while creating the account). Enumeration-proof by design:
# an existing email gets the identical "check your inbox" experience —
# the difference lives only in which email we send.
class RegistrationsController < InertiaController
  allow_unauthenticated_access

  def new
    render inertia: "auth/register"
  end

  def create
    email = User.new(email_address: registration_params[:email_address]).email_address

    if (existing = User.find_by(email_address: email))
      AuthMailer.existing_account(existing).deliver_later
    else
      user = User.new(registration_params)
      unless user.save
        return redirect_to new_registration_path, inertia: { errors: user.errors }
      end

      AuthEvent.record!("signup", user:, request:)
      send_verification(user)
    end

    session[:pending_verification_email] = email
    redirect_to email_verification_path
  end

  private

  def registration_params
    params.permit(:email_address, :login_mode, :password)
  end

  def send_verification(user)
    issued = AuthToken.issue!(user:, purpose: "email_verification")
    AuthMailer.email_verification(user, code: issued.code, link_token: issued.link_token).deliver_later
  end
end
