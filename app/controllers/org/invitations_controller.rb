# frozen_string_literal: true

module Org
  # Owner-only actions on pending invitations. No index of its own — the
  # members page (Org::MembersController) renders the whole roster,
  # invitations included.
  class InvitationsController < BaseController
    before_action :require_owner!

    def create
      result = Invitations::Send.call(
        organization: Current.organization, inviter: Current.user,
        email: invitation_params[:email].to_s,
        owner: bool_param(:owner), board_owner: bool_param(:board_owner)
      )

      if result.success?
        redirect_to org_members_path(org_slug: Current.organization.slug), notice: "Invitation sent to #{result.invitation.email}."
      else
        redirect_to org_members_path(org_slug: Current.organization.slug), alert: result.error
      end
    end

    def destroy
      result = Invitations::Revoke.call(invitation: find_invitation)
      redirect_to org_members_path(org_slug: Current.organization.slug),
                  result.success? ? { notice: "Invitation revoked." } : { alert: result.error }
    end

    def resend
      result = Invitations::Resend.call(invitation: find_invitation)
      redirect_to org_members_path(org_slug: Current.organization.slug),
                  result.success? ? { notice: "Invitation resent." } : { alert: result.error }
    end

    private

    def find_invitation
      Current.organization.invitations.find(params[:id])
    end

    def invitation_params
      params.permit(:email, :owner, :board_owner)
    end

    # An absent checkbox param means false, not "no opinion" — the DB
    # column agrees (NOT NULL, default false); casting an absent param
    # straight through would try to write a null and fail the insert.
    def bool_param(key) = ActiveModel::Type::Boolean.new.cast(invitation_params[key]) || false
  end
end
