# frozen_string_literal: true

module Memberships
  # Denying a join request destroys the pending row — no tombstone state,
  # the requester can ask again (org plan_3 owns the neutral email).
  class Deny
    def self.call(membership:) = new(membership:).call

    def initialize(membership:)
      @membership = membership
    end

    def call
      unless @membership.state == "pending_approval"
        return Result.new(membership: nil, error: "Only pending join requests can be denied.")
      end

      ActsAsTenant.with_tenant(@membership.organization) { @membership.destroy! }
      Result.new(membership: @membership, error: nil)
    end
  end
end
