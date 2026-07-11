# frozen_string_literal: true

require "rails_helper"

RSpec.describe Memberships::Deactivate do
  let(:organization) { create(:organization) }

  it "deactivates a member" do
    create(:membership, :owner, organization:)
    membership = create(:membership, organization:)

    result = described_class.call(membership:)

    expect(result).to be_success
    expect(membership.reload.state).to eq("deactivated")
  end

  it "refuses to deactivate the last active owner", :negative do
    owner = create(:membership, :owner, organization:)

    result = described_class.call(membership: owner)

    expect(result).not_to be_success
    expect(result.error).to include("at least one active owner")
    expect(owner.reload).to be_active
  end
end
