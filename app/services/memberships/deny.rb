# frozen_string_literal: true

module Memberships
  # Denying a join request destroys the pending row — no tombstone state,
  # the requester can ask again. The neutral email (org plan_3) is the
  # only record it happened at all.
  class Deny
    def self.call(membership:) = new(membership:).call

    def initialize(membership:)
      @membership = membership
    end

    def call
      unless @membership.state == "pending_approval"
        return Result.new(membership: nil, error: "Only pending join requests can be denied.")
      end

      user = @membership.user
      organization = @membership.organization
      ActsAsTenant.with_tenant(organization) { @membership.destroy! }
      MembershipMailer.join_request_denied(user, organization).deliver_later
      Result.new(membership: @membership, error: nil)
    end
  end
end
