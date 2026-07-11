# frozen_string_literal: true

module Memberships
  # active → deactivated. Frees the seat; the model's last-active-owner
  # guard is what can refuse.
  class Deactivate
    def self.call(membership:) = new(membership:).call

    def initialize(membership:)
      @membership = membership
    end

    def call
      ActsAsTenant.with_tenant(@membership.organization) do
        if @membership.update(state: "deactivated")
          Result.new(membership: @membership, error: nil)
        else
          Result.new(membership: nil, error: @membership.errors.full_messages.to_sentence)
        end
      end
    end
  end
end
