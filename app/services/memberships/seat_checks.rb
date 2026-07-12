# frozen_string_literal: true

# The single choke-point for tier limits (org plan_2): every membership
# mutation flows through a Memberships service, and these checks are the
# only place seat math meets Entitlements. Counts are active memberships
# plus live pending invitations (org plan_3 O1: invites reserve seats at
# send time, so a full org can't be over-invited past its limit — the
# invitee finds out at send, not at the worse moment, accept).
module Memberships
  module SeatChecks
    private

    def seat_available?(organization)
      Entitlements.for(organization)
                  .within_limit?(:members, reserved_member_seats(organization) + 1)
    end

    def board_owner_seat_available?(organization)
      Entitlements.for(organization)
                  .within_limit?(:board_owners, reserved_board_owner_seats(organization) + 1)
    end

    def seats_full_error(organization)
      limit = Entitlements.for(organization).limit_for(:members)
      "Your plan seats #{limit} people, and every seat is taken."
    end

    def board_owner_seats_full_error(organization)
      limit = Entitlements.for(organization).limit_for(:board_owners)
      "Your plan allows #{limit} board owners, and you have them."
    end

    def reserved_member_seats(organization)
      organization.memberships.active.count + organization.invitations.reserving_seat.count
    end

    def reserved_board_owner_seats(organization)
      organization.memberships.board_owners.count +
        organization.invitations.reserving_seat.where(board_owner: true).count
    end
  end
end
