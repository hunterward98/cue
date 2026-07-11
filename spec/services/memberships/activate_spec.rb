# frozen_string_literal: true

require "rails_helper"

RSpec.describe Memberships::Activate do
  let(:organization) { create(:organization) }

  it "approves a pending join request" do
    membership = create(:membership, :pending, organization:)
    result = described_class.call(membership:)

    expect(result).to be_success
    expect(membership.reload).to be_active
  end

  it "reactivates a deactivated member" do
    membership = create(:membership, :deactivated, organization:)
    expect(described_class.call(membership:)).to be_success
  end

  it "re-checks the seat limit at approval time", :negative do
    membership = create(:membership, :pending, organization:)
    create_list(:membership, 15, organization:)

    with_tier :basic do
      result = described_class.call(membership:)
      expect(result).not_to be_success
      expect(result.error).to include("seats 15 people")
      expect(membership.reload.state).to eq("pending_approval")
    end
  end

  it "re-checks board-owner seats when reactivating a board owner", :negative do
    membership = create(:membership, :deactivated, organization:, board_owner: true)
    create_list(:membership, 2, :board_owner, organization:)

    with_tier :basic do
      result = described_class.call(membership:)
      expect(result).not_to be_success
      expect(result.error).to include("2 board owners")
    end
  end
end
