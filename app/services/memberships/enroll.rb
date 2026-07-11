# frozen_string_literal: true

module Memberships
  # Creates a membership. Active enrollments consume a seat now;
  # pending_approval ones don't — the approval (Activate) is where the
  # seat check happens for join requests, so a full org's approval queue
  # can still exist.
  class Enroll
    include SeatChecks

    def self.call(**kwargs) = new(**kwargs).call

    def initialize(organization:, user:, state: "active", owner: false, board_owner: false)
      @organization = organization
      @user = user
      @state = state
      @owner = owner
      @board_owner = board_owner
    end

    # Establishes its own tenant: callers outside /o/ scope (invitation
    # accept, org creation) have none set.
    def call
      ActsAsTenant.with_tenant(@organization) { enroll }
    end

    private

    def enroll
      if @state == "active" && !seat_available?(@organization)
        return Result.new(membership: nil, error: seats_full_error(@organization))
      end
      if @board_owner && !board_owner_seat_available?(@organization)
        return Result.new(membership: nil, error: board_owner_seats_full_error(@organization))
      end

      membership = @organization.memberships.new(
        user: @user, state: @state, owner: @owner, board_owner: @board_owner
      )
      if membership.save
        Result.new(membership:, error: nil)
      else
        Result.new(membership: nil, error: membership.errors.full_messages.to_sentence)
      end
    end
  end
end
