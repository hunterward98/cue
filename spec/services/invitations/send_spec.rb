# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitations::Send do
  let(:organization) { create(:organization) }
  let(:inviter) { create(:membership, :owner, organization:).user }

  it "creates a pending invitation and mails it" do
    result = nil
    perform_enqueued_jobs { result = described_class.call(organization:, inviter:, email: "New@Example.com") }

    expect(result).to be_success
    expect(result.invitation.email).to eq("new@example.com")
    expect(result.invitation.state).to eq("pending")

    mail = ActionMailer::Base.deliveries.sole
    expect(mail.to).to eq([ "new@example.com" ])
    expect(mail.subject).to include(organization.name)
  end

  it "carries the invited role onto the invitation" do
    result = described_class.call(organization:, inviter:, email: "board@example.com", board_owner: true)
    expect(result.invitation.board_owner?).to be(true)
  end

  it "rejects the 16th reserved seat on basic tier — the invite itself, not just acceptance", :negative do
    create_list(:membership, 15, organization:)

    with_tier :basic do
      result = nil
      perform_enqueued_jobs { result = described_class.call(organization:, inviter:, email: "unlucky@example.com") }
      expect(result).not_to be_success
      expect(result.error).to include("seats 15 people")
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  it "counts outstanding pending invitations against the same limit — 'prevents 20 invites on a 15-seat org'", :negative do
    create_list(:membership, 14, organization:)
    create(:invitation, organization:) # the 15th seat, already reserved

    with_tier :basic do
      result = described_class.call(organization:, inviter:, email: "sixteenth@example.com")
      expect(result).not_to be_success
      expect(result.error).to include("seats 15 people")
    end
  end

  it "rejects a 3rd board-owner invite on basic tier", :negative do
    create_list(:membership, 2, :board_owner, organization:)

    with_tier :basic do
      result = described_class.call(organization:, inviter:, email: "board3@example.com", board_owner: true)
      expect(result).not_to be_success
      expect(result.error).to include("2 board owners")
    end
  end

  it "surfaces model errors — a second invite to an already-pending email fails", :negative do
    create(:invitation, organization:, email: "dup@example.com")

    result = described_class.call(organization:, inviter:, email: "dup@example.com")
    expect(result).not_to be_success
    expect(result.error).to include("already has a pending invitation")
  end
end
