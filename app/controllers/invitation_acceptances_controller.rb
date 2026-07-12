# frozen_string_literal: true

# The invitation door (org plan_3): a tap from an email. Auto-approved —
# unlike the join-link door (JoinRequestsController), which queues.
class InvitationAcceptancesController < InertiaController
  allow_unauthenticated_access

  def show
    invitation = redeemable_invitation
    return render_invalid unless invitation

    if Current.user
      handle_signed_in(invitation)
    else
      handle_signed_out(invitation)
    end
  end

  # The mismatched-email screen's "sign out and continue" action.
  def switch_account
    terminate_session if Current.session
    redirect_to accept_invitation_path(token: params[:token])
  end

  private

  def redeemable_invitation
    invitation = Invitation.find_by_token(params[:token])
    invitation if invitation&.redeemable?
  end

  def handle_signed_in(invitation)
    if Current.user.email_address == invitation.email
      accept(invitation)
    else
      render inertia: "auth/switch_account", props: {
        organization_name: invitation.organization.name,
        current_email: Current.user.email_address,
        invited_email: invitation.email,
        token: params[:token]
      }
    end
  end

  def handle_signed_out(invitation)
    session[:pending_invitation_token] = params[:token]
    organization_name = invitation.organization.name

    if User.exists?(email_address: invitation.email)
      redirect_to new_session_path(email_address: invitation.email),
                  notice: "Sign in to accept your invitation to #{organization_name}."
    else
      redirect_to new_registration_path(email_address: invitation.email),
                  notice: "Create your account to accept the invitation to #{organization_name}."
    end
  end

  def accept(invitation)
    outcome = Invitations::Accept.call(invitation:, user: Current.user)
    if outcome.success?
      redirect_to org_root_path(org_slug: invitation.organization.slug),
                  notice: "You're in. Welcome to #{invitation.organization.name}."
    else
      redirect_to organizations_path, alert: outcome.error
    end
  end

  def render_invalid
    redirect_to organizations_path, alert: "That invitation link is invalid or has expired."
  end
end
