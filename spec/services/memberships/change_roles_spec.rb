# frozen_string_literal: true

require "rails_helper"

RSpec.describe Memberships::ChangeRoles do
  let(:organization) { create(:organization) }

  it "grants and revokes the board_owner flag" do
    create(:membership, :owner, organization:)
    membership = create(:membership, organization:)

    result = described_class.call(membership:, owner: false, board_owner: true)
    expect(result).to be_success
    expect(membership.reload.board_owner?).to be(true)

    result = described_class.call(membership:, owner: false, board_owner: false)
    expect(result).to be_success
    expect(membership.reload.requester?).to be(true)
  end

  it "promotes a member to owner — multiple owners are expected" do
    create(:membership, :owner, organization:)
    membership = create(:membership, organization:)

    result = described_class.call(membership:, owner: true, board_owner: false)

    expect(result).to be_success
    expect(membership.reload.owner?).to be(true)
  end

  it "rejects a board-owner grant past the tier limit", :negative do
    create_list(:membership, 2, :board_owner, organization:)
    membership = create(:membership, organization:)

    with_tier :basic do
      result = described_class.call(membership:, owner: false, board_owner: true)
      expect(result).not_to be_success
      expect(result.error).to include("2 board owners")
      expect(membership.reload.board_owner?).to be(false)
    end
  end

  it "keeps an existing board owner's flag without burning a new seat" do
    create_list(:membership, 1, :board_owner, organization:)
    membership = create(:membership, :board_owner, organization:)

    with_tier :basic do
      expect(described_class.call(membership:, owner: true, board_owner: true)).to be_success
    end
  end

  it "refuses to demote the last active owner", :negative do
    owner = create(:membership, :owner, organization:)

    result = described_class.call(membership: owner, owner: false, board_owner: false)

    expect(result).not_to be_success
    expect(result.error).to include("at least one active owner")
  end
end
