# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizations::CreateWithOwner do
  let(:user) { create(:user) }

  it "creates the org with its creator as first active owner, atomically" do
    result = described_class.call(user:, name: "Riverside Dental", slug: "riverside")

    expect(result).to be_success
    organization = result.organization
    expect(organization.setting("visibility")).to eq("all_members")

    membership = ActsAsTenant.with_tenant(organization) { organization.memberships.sole }
    expect(membership.user).to eq(user)
    expect(membership.owner?).to be(true)
    expect(membership).to be_active
  end

  it "returns the org's validation errors without writing anything", :negative do
    result = described_class.call(user:, name: "", slug: "Bad Slug")

    expect(result).not_to be_success
    expect(result.errors[:name]).to be_present
    expect(result.errors[:slug]).to be_present
    expect(Organization.count).to eq(0)
    expect(ActsAsTenant.without_tenant { Membership.count }).to eq(0)
  end
end
