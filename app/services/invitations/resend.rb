# frozen_string_literal: true

module Invitations
  # Same row, fresh token, re-mailed — the old link stops working the
  # moment this runs (Invitation#resend! overwrites the digest).
  class Resend
    def self.call(invitation:) = new(invitation:).call

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      ActsAsTenant.with_tenant(@invitation.organization) do
        token = @invitation.resend!
        if token
          InvitationMailer.invite(@invitation, token:).deliver_later
          Result.new(invitation: @invitation, error: nil)
        else
          Result.new(invitation: nil, error: "Only pending invitations can be resent.")
        end
      end
    end
  end
end
