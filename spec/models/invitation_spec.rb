# frozen_string_literal: true

require "rails_helper"

# == Schema Information
#
# Table name: invitations
#
#  id              :uuid             not null, primary key
#  board_owner     :boolean          default(FALSE), not null
#  email           :citext           not null
#  expires_at      :datetime         not null
#  owner           :boolean          default(FALSE), not null
#  state           :string           default("pending"), not null
#  token_digest    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  inviter_id      :uuid             not null
#  organization_id :uuid             not null
#
RSpec.describe Invitation, type: :model do
  let(:organization) { create(:organization) }
  let(:inviter) { create(:user) }

  def in_org(&)
    ActsAsTenant.with_tenant(organization, &)
  end

  it "has a valid factory" do
    expect(create(:invitation, organization:)).to be_persisted
  end

  describe ".invite!" do
    it "creates a pending invitation with a hashed token and a 14-day expiry" do
      issued = in_org { described_class.invite!(organization:, inviter:, email: "New@Example.com") }

      expect(issued.invitation).to be_persisted
      expect(issued.invitation.email).to eq("new@example.com") # normalized
      expect(issued.invitation.state).to eq("pending")
      expect(issued.invitation.expires_at).to be_within(1.second).of(14.days.from_now)
      expect(issued.invitation.token_digest).not_to eq(issued.token)
      expect(issued.invitation.token_digest).to eq(described_class.digest(issued.token))
    end

    it "carries the invited role", :aggregate_failures do
      issued = in_org do
        described_class.invite!(organization:, inviter:, email: "board@example.com", board_owner: true)
      end
      expect(issued.invitation.board_owner?).to be(true)
      expect(issued.invitation.owner?).to be(false)
    end
  end

  describe "email" do
    it "rejects a malformed address", :negative do
      invitation = build(:invitation, organization:, email: "not-an-email")
      in_org { expect(invitation).not_to be_valid }
    end

    it "rejects a second pending invite to the same email at the model layer", :negative do
      create(:invitation, organization:, email: "dup@example.com")
      duplicate = build(:invitation, organization:, email: "dup@example.com")
      in_org { expect(duplicate).not_to be_valid }
    end

    it "rejects a second pending invite to the same email at the DB layer", :negative do
      create(:invitation, organization:, email: "dup@example.com")
      expect do
        in_org do
          duplicate = described_class.new(
            organization:, inviter:, email: "dup@example.com",
            token_digest: described_class.digest(SecureRandom.hex), expires_at: 1.day.from_now, state: "pending"
          )
          duplicate.save!(validate: false)
        end
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows re-inviting an email once the prior invitation is no longer pending" do
      create(:invitation, :accepted, organization:, email: "dup@example.com")
      fresh = build(:invitation, organization:, email: "dup@example.com")
      in_org { expect(fresh).to be_valid }
    end

    it "skips the pending-duplicate check without querying when there's no email yet", :negative do
      blank_email = build(:invitation, organization:, email: "")
      in_org { expect(blank_email).not_to be_valid }
      expect(blank_email.errors[:email]).not_to include("already has a pending invitation")
    end
  end

  describe "#redeemable?" do
    it "is true only while pending and unexpired" do
      expect(create(:invitation, organization:)).to be_redeemable
      expect(create(:invitation, :expired, organization:)).not_to be_redeemable
      expect(create(:invitation, :accepted, organization:)).not_to be_redeemable
      expect(create(:invitation, :revoked, organization:)).not_to be_redeemable
    end
  end

  describe "#revoke!" do
    it "moves a pending invitation to revoked, freeing its seat reservation" do
      invitation = create(:invitation, organization:)
      in_org { expect(invitation.revoke!).to be(true) }
      expect(invitation.reload.state).to eq("revoked")
    end

    it "refuses to revoke a non-pending invitation", :negative do
      invitation = create(:invitation, :accepted, organization:)
      in_org { expect(invitation.revoke!).to be(false) }
      expect(invitation.reload.state).to eq("accepted")
    end
  end

  describe "#resend!" do
    it "issues a fresh token and expiry on the same row" do
      invitation = create(:invitation, organization:, expires_at: 1.hour.from_now)
      old_digest = invitation.token_digest

      token = in_org { invitation.resend! }

      expect(token).to be_present
      expect(invitation.reload.token_digest).not_to eq(old_digest)
      expect(invitation.token_digest).to eq(described_class.digest(token))
      expect(invitation.expires_at).to be_within(1.second).of(14.days.from_now)
    end

    it "refuses to resend a non-pending invitation", :negative do
      invitation = create(:invitation, :revoked, organization:)
      in_org { expect(invitation.resend!).to be_nil }
    end
  end

  describe ".find_by_token" do
    it "finds the invitation without needing tenant context first (a tap from an email)" do
      issued = in_org { described_class.invite!(organization:, inviter:, email: "tap@example.com") }
      expect(described_class.find_by_token(issued.token)).to eq(issued.invitation)
    end

    it "finds nothing for a wrong token", :negative do
      create(:invitation, organization:)
      expect(described_class.find_by_token("not-a-real-token")).to be_nil
    end
  end

  describe ".sweep_expired!" do
    it "relabels timed-out pending invitations, leaving everything else alone" do
      timed_out = create(:invitation, organization:, expires_at: 1.minute.ago)
      live = create(:invitation, organization:, expires_at: 1.day.from_now)
      already_accepted = create(:invitation, :accepted, organization:, expires_at: 1.minute.ago)

      described_class.sweep_expired!

      expect(timed_out.reload.state).to eq("expired")
      expect(live.reload.state).to eq("pending")
      expect(already_accepted.reload.state).to eq("accepted")
    end
  end

  describe "states" do
    it "rejects states outside the machine", :negative do
      invitation = build(:invitation, organization:, state: "sent")
      in_org { expect(invitation).not_to be_valid }
    end
  end

  describe "tenancy (ADR 0010)" do
    it "scopes every query to the current tenant" do
      ours = create(:invitation, organization:)
      other_org = create(:organization)
      create(:invitation, organization: other_org)

      in_org { expect(described_class.all).to contain_exactly(ours) }
    end

    it "refuses tenant-model queries when no tenant is set", :negative do
      expect { described_class.count }.to raise_error(ActsAsTenant::Errors::NoTenantSet)
    end
  end
end
