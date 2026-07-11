# frozen_string_literal: true

module Memberships
  # Owner/board-owner flag changes. Granting board_owner claims one of the
  # tier's board-owner seats; the model's last-active-owner guard protects
  # the owner flag.
  class ChangeRoles
    include SeatChecks

    def self.call(**kwargs) = new(**kwargs).call

    def initialize(membership:, owner:, board_owner:)
      @membership = membership
      @owner = owner
      @board_owner = board_owner
    end

    def call
      ActsAsTenant.with_tenant(@membership.organization) { change }
    end

    private

    def change
      if gaining_board_owner? && !board_owner_seat_available?(@membership.organization)
        return Result.new(membership: nil, error: board_owner_seats_full_error(@membership.organization))
      end

      if @membership.update(owner: @owner, board_owner: @board_owner)
        Result.new(membership: @membership, error: nil)
      else
        Result.new(membership: nil, error: @membership.errors.full_messages.to_sentence)
      end
    end

    def gaining_board_owner? = @board_owner && !@membership.board_owner?
  end
end
