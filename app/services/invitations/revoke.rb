# frozen_string_literal: true

module Invitations
  # Revoking is how the O1 seat reservation gets given back before the
  # invitation would otherwise expire on its own.
  class Revoke
    def self.call(invitation:) = new(invitation:).call

    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      ActsAsTenant.with_tenant(@invitation.organization) do
        if @invitation.revoke!
          Result.new(invitation: @invitation, error: nil)
        else
          Result.new(invitation: nil, error: "Only pending invitations can be revoked.")
        end
      end
    end
  end
end
