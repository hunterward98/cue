# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitations::Accept do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  it "enrolls the user as an active member and marks the invitation accepted" do
    invitation = create(:invitation, organization:, email: user.email_address)

    result = described_class.call(invitation:, user:)

    expect(result).to be_success
    expect(result.membership).to be_active
    expect(invitation.reload.state).to eq("accepted")
  end

  it "carries the invited role onto the new membership" do
    invitation = create(:invitation, :board_owner, organization:, email: user.email_address)

    result = described_class.call(invitation:, user:)

    expect(result.membership.board_owner?).to be(true)
  end

  it "rejects an already-accepted invitation, creating no membership", :negative do
    invitation = create(:invitation, :accepted, organization:, email: user.email_address)

    result = described_class.call(invitation:, user:)

    expect(result).not_to be_success
    expect(result.error).to include("no longer valid")
    expect(ActsAsTenant.with_tenant(organization) { organization.memberships.count }).to eq(0)
  end

  it "rejects a revoked invitation", :negative do
    invitation = create(:invitation, :revoked, organization:, email: user.email_address)

    result = described_class.call(invitation:, user:)

    expect(result).not_to be_success
    expect(result.error).to include("no longer valid")
  end

  it "rejects an expired invitation even if its state is still nominally pending", :negative do
    invitation = create(:invitation, organization:, email: user.email_address, expires_at: 1.minute.ago)

    result = described_class.call(invitation:, user:)

    expect(result).not_to be_success
    expect(result.error).to include("no longer valid")
  end

  it "leaves the invitation pending (not burned) when the seat vanished between invite and accept", :negative do
    invitation = create(:invitation, organization:, email: user.email_address)
    create_list(:membership, 15, organization:) # someone else filled every seat in the meantime

    result = with_tier(:basic) { described_class.call(invitation:, user:) }

    expect(result).not_to be_success
    expect(invitation.reload.state).to eq("pending")
    expect(invitation).to be_redeemable
  end
end
