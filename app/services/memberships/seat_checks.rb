# frozen_string_literal: true

# The single choke-point for tier limits (org plan_2): every membership
# mutation flows through a Memberships service, and these checks are the
# only place seat math meets Entitlements. Counts are of active
# memberships; org plan_3's Invitation adds pending-invite reservations.
module Memberships
  module SeatChecks
    private

    def seat_available?(organization)
      Entitlements.for(organization)
                  .within_limit?(:members, organization.memberships.active.count + 1)
    end

    def board_owner_seat_available?(organization)
      Entitlements.for(organization)
                  .within_limit?(:board_owners, organization.memberships.board_owners.count + 1)
    end

    def seats_full_error(organization)
      limit = Entitlements.for(organization).limit_for(:members)
      "Your plan seats #{limit} people, and every seat is taken."
    end

    def board_owner_seats_full_error(organization)
      limit = Entitlements.for(organization).limit_for(:board_owners)
      "Your plan allows #{limit} board owners, and you have them."
    end
  end
end
