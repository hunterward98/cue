# frozen_string_literal: true

module Invitations
  # Auto-approved membership creation (unlike the join-link door, which
  # queues for owner approval). Flips the invitation to accepted *before*
  # enrolling so its own seat reservation isn't double-counted against
  # itself in the same seat check (Memberships::SeatChecks).
  class Accept
    Outcome = Data.define(:membership, :error) do
      def success? = error.nil?
    end

    def self.call(invitation:, user:) = new(invitation:, user:).call

    def initialize(invitation:, user:)
      @invitation = invitation
      @user = user
    end

    def call
      return Outcome.new(membership: nil, error: "This invitation is no longer valid.") unless @invitation.redeemable?

      membership = nil
      ActsAsTenant.with_tenant(@invitation.organization) do
        ActiveRecord::Base.transaction do
          @invitation.update!(state: "accepted")
          enrolled = Memberships::Enroll.call(
            organization: @invitation.organization, user: @user, state: "active",
            owner: @invitation.owner?, board_owner: @invitation.board_owner?
          )
          raise ActiveRecord::Rollback unless enrolled.success?

          membership = enrolled.membership
        end
      end

      if membership
        Outcome.new(membership:, error: nil)
      else
        Outcome.new(membership: nil, error: "That seat isn't available anymore — ask an org owner.")
      end
    end
  end
end
