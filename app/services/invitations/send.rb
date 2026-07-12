# frozen_string_literal: true

module Invitations
  # An owner's "invite" action: checks the seat this invitation would
  # reserve (O1: pending invites count against limits at send time, not
  # at the worse moment — accept), creates the token, mails the link.
  class Send
    include Memberships::SeatChecks

    def self.call(**kwargs) = new(**kwargs).call

    def initialize(organization:, inviter:, email:, owner: false, board_owner: false)
      @organization = organization
      @inviter = inviter
      @email = email
      @owner = owner
      @board_owner = board_owner
    end

    def call
      ActsAsTenant.with_tenant(@organization) { send_invite }
    end

    private

    def send_invite
      return Result.new(invitation: nil, error: seats_full_error(@organization)) unless seat_available?(@organization)

      if @board_owner && !board_owner_seat_available?(@organization)
        return Result.new(invitation: nil, error: board_owner_seats_full_error(@organization))
      end

      issued = Invitation.invite!(
        organization: @organization, inviter: @inviter, email: @email, owner: @owner, board_owner: @board_owner
      )
      InvitationMailer.invite(issued.invitation, token: issued.token).deliver_later
      Result.new(invitation: issued.invitation, error: nil)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(invitation: nil, error: e.record.errors.full_messages.to_sentence)
    end
  end
end
