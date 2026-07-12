# frozen_string_literal: true

require "rails_helper"

RSpec.describe Memberships::Deny do
  let(:organization) { create(:organization) }

  it "destroys a pending join request — no tombstone, they can ask again — and mails a neutral notice" do
    membership = create(:membership, :pending, organization:)
    requester = membership.user

    result = nil
    perform_enqueued_jobs { result = described_class.call(membership:) }

    expect(result).to be_success
    expect(ActsAsTenant.with_tenant(organization) { Membership.exists?(membership.id) }).to be(false)
    mail = ActionMailer::Base.deliveries.sole
    expect(mail.to).to eq([ requester.email_address ])
    expect(mail.subject).to include(organization.name)
  end

  it "refuses to deny anything but a pending request", :negative do
    membership = create(:membership, organization:)

    result = described_class.call(membership:)

    expect(result).not_to be_success
    expect(result.error).to include("Only pending join requests")
    expect(membership.reload).to be_active
  end
end
