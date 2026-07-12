# frozen_string_literal: true

# Signup (auth plan_2, ratified A1: the user picks password or
# passwordless while creating the account). Enumeration-proof by design:
# an existing email gets the identical "check your inbox" experience —
# the difference lives only in which email we send.
class RegistrationsController < InertiaController
  allow_unauthenticated_access

  def new
    render inertia: "auth/register", props: { email_address: params[:email_address] }
  end

  def create
    email = User.new(email_address: registration_params[:email_address]).email_address

    if (existing = User.find_by(email_address: email))
      AuthMailer.existing_account(existing).deliver_later
      session[:pending_verification_email] = email
      return redirect_to email_verification_path
    end

    invitation = pending_invitation_for(email)
    user = User.new(registration_params)
    user.verified_at = Time.current if invitation # ADR 0015

    unless user.save
      return redirect_to new_registration_path, inertia: { errors: user.errors }
    end

    AuthEvent.record!("signup", user:, request:)

    if invitation
      complete_invited_signup(invitation, user)
    else
      send_verification(user)
      session[:pending_verification_email] = email
      redirect_to email_verification_path
    end
  end

  private

  def registration_params
    params.permit(:email_address, :login_mode, :password)
  end

  def send_verification(user)
    issued = AuthToken.issue!(user:, purpose: "email_verification")
    AuthMailer.email_verification(user, code: issued.code, link_token: issued.link_token).deliver_later
  end

  # An email exactly matching a redeemable, session-stashed invitation
  # (org plan_3) is what makes this signup invitation-backed — a
  # different email in the form (or a stale/consumed token) just falls
  # through to the normal verify-by-code path below.
  def pending_invitation_for(email)
    token = session[:pending_invitation_token]
    return nil if token.blank?

    invitation = Invitation.find_by_token(token)
    invitation if invitation&.redeemable? && invitation.email == email
  end

  def complete_invited_signup(invitation, user)
    session.delete(:pending_invitation_token)
    outcome = Invitations::Accept.call(invitation:, user:)
    start_new_session_for(user)

    if outcome.success?
      redirect_to org_root_path(org_slug: invitation.organization.slug),
                  notice: "You're in. Welcome to #{invitation.organization.name}."
    else
      redirect_to organizations_path, alert: outcome.error
    end
  end
end
