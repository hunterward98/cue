# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitations::Revoke do
  let(:organization) { create(:organization) }

  it "revokes a pending invitation, freeing its seat reservation" do
    invitation = create(:invitation, organization:)

    result = described_class.call(invitation:)

    expect(result).to be_success
    expect(result.invitation.state).to eq("revoked")
  end

  it "refuses to revoke a non-pending invitation", :negative do
    invitation = create(:invitation, :accepted, organization:)

    result = described_class.call(invitation:)

    expect(result).not_to be_success
    expect(result.error).to include("Only pending invitations")
  end
end
