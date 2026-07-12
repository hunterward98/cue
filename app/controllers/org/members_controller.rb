# frozen_string_literal: true

module Org
  # The whole roster in one place (owner-only): active/pending/deactivated
  # memberships and pending invitations together, so seats reserved by
  # invitations are never an invisible mystery (plan_3 critique).
  class MembersController < BaseController
    before_action :require_owner!

    def index
      render inertia: "org/members/index", props: {
        org_slug: Current.organization.slug,
        members: serialized_memberships,
        invitations: serialized_invitations,
        seat_limit: Entitlements.for(Current.organization).limit_for(:members),
        board_owner_limit: Entitlements.for(Current.organization).limit_for(:board_owners)
      }
    end

    # Role changes on an active membership (owner/board_owner checkboxes).
    def update
      result = Memberships::ChangeRoles.call(
        membership: find_membership, owner: bool_param(:owner), board_owner: bool_param(:board_owner)
      )
      redirect_back_with(result)
    end

    # pending_approval → active (join-request approval), or
    # deactivated → active (reactivation) — same seat-checked transition.
    def activate
      redirect_back_with(Memberships::Activate.call(membership: find_membership))
    end

    def deactivate
      redirect_back_with(Memberships::Deactivate.call(membership: find_membership))
    end

    # Denies a join request — the only thing DELETE means here; an
    # active/deactivated membership never reaches this action from the UI.
    def destroy
      redirect_back_with(Memberships::Deny.call(membership: find_membership), notice: "Request denied.")
    end

    private

    def find_membership
      Current.organization.memberships.find(params[:id])
    end

    # An absent checkbox param means false, not "no opinion" — the same
    # reasoning as Org::InvitationsController's bool_param.
    def bool_param(key) = ActiveModel::Type::Boolean.new.cast(params[key]) || false

    def redirect_back_with(result, notice: "Updated.")
      path = org_members_path(org_slug: Current.organization.slug)
      redirect_to path, result.success? ? { notice: } : { alert: result.error }
    end

    def serialized_memberships
      Current.organization.memberships.includes(:user).order(:created_at).map do |membership|
        {
          id: membership.id,
          email: membership.user.email_address,
          state: membership.state,
          owner: membership.owner?,
          board_owner: membership.board_owner?,
          is_you: membership.user_id == Current.user.id
        }
      end
    end

    def serialized_invitations
      Current.organization.invitations.pending.includes(:inviter).order(created_at: :desc).map do |invitation|
        {
          id: invitation.id,
          email: invitation.email,
          owner: invitation.owner?,
          board_owner: invitation.board_owner?,
          invited_by: invitation.inviter.email_address,
          expires_at: invitation.expires_at.iso8601,
          live: invitation.redeemable?
        }
      end
    end
  end
end
