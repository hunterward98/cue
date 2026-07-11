# frozen_string_literal: true

require "rails_helper"

RSpec.describe Memberships::Enroll do
  let(:organization) { create(:organization) }

  it "enrolls an active member" do
    result = described_class.call(organization:, user: create(:user))

    expect(result).to be_success
    expect(result.membership).to be_active
    expect(result.membership.requester?).to be(true)
  end

  it "enrolls owners and board owners with their flags" do
    result = described_class.call(organization:, user: create(:user), owner: true, board_owner: true)

    expect(result.membership.owner?).to be(true)
    expect(result.membership.board_owner?).to be(true)
  end

  it "rejects the 16th active seat on basic tier", :negative do
    create_list(:membership, 15, organization:)

    with_tier :basic do
      result = described_class.call(organization:, user: create(:user))
      expect(result).not_to be_success
      expect(result.error).to include("seats 15 people")
    end
  end

  it "rejects a 3rd board owner on basic tier", :negative do
    create_list(:membership, 2, :board_owner, organization:)

    with_tier :basic do
      result = described_class.call(organization:, user: create(:user), board_owner: true)
      expect(result).not_to be_success
      expect(result.error).to include("2 board owners")
    end
  end

  it "lets a join request queue up even when the org is full — the seat check waits for approval" do
    create_list(:membership, 15, organization:)

    with_tier :basic do
      result = described_class.call(organization:, user: create(:user), state: "pending_approval")
      expect(result).to be_success
      expect(result.membership.state).to eq("pending_approval")
    end
  end

  it "surfaces model errors — a duplicate enrollment fails", :negative do
    existing = create(:membership, organization:)
    result = described_class.call(organization:, user: existing.user)

    expect(result).not_to be_success
    expect(result.error).to include("already been taken")
  end
end
