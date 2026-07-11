# frozen_string_literal: true

require "rails_helper"

RSpec.describe Memberships::Deny do
  let(:organization) { create(:organization) }

  it "destroys a pending join request — no tombstone, they can ask again" do
    membership = create(:membership, :pending, organization:)

    result = described_class.call(membership:)

    expect(result).to be_success
    expect(ActsAsTenant.with_tenant(organization) { Membership.exists?(membership.id) }).to be(false)
  end

  it "refuses to deny anything but a pending request", :negative do
    membership = create(:membership, organization:)

    result = described_class.call(membership:)

    expect(result).not_to be_success
    expect(result.error).to include("Only pending join requests")
    expect(membership.reload).to be_active
  end
end
