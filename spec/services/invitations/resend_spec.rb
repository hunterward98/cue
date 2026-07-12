# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitations::Resend do
  let(:organization) { create(:organization) }

  it "issues a fresh token and re-mails the invitation" do
    invitation = create(:invitation, organization:)
    old_digest = invitation.token_digest

    result = nil
    perform_enqueued_jobs { result = described_class.call(invitation:) }

    expect(result).to be_success
    expect(invitation.reload.token_digest).not_to eq(old_digest)
    expect(ActionMailer::Base.deliveries.sole.to).to eq([ invitation.email ])
  end

  it "refuses to resend a non-pending invitation, sending nothing", :negative do
    invitation = create(:invitation, :revoked, organization:)

    result = described_class.call(invitation:)

    expect(result).not_to be_success
    expect(result.error).to include("Only pending invitations")
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
