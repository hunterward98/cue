# frozen_string_literal: true

module Memberships
  # pending_approval → active (join-request approval) and
  # deactivated → active (reactivation): both claim a seat, so both
  # re-check the limit at the seam.
  class Activate
    include SeatChecks

    def self.call(membership:) = new(membership:).call

    def initialize(membership:)
      @membership = membership
    end

    def call
      ActsAsTenant.with_tenant(@membership.organization) { activate }
    end

    private

    def activate
      organization = @membership.organization
      unless seat_available?(organization)
        return Result.new(membership: nil, error: seats_full_error(organization))
      end
      if @membership.board_owner? && !board_owner_seat_available?(organization)
        return Result.new(membership: nil, error: board_owner_seats_full_error(organization))
      end

      # Every state the machine can reach transitions to active validly
      # (pending/deactivated → active), so this can't fail today; update!
      # keeps that assumption loud instead of hiding it in a dead branch.
      @membership.activate!
      Result.new(membership: @membership, error: nil)
    end
  end
end
