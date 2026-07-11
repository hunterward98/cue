# frozen_string_literal: true

require "rails_helper"

# == Schema Information
#
# Table name: organizations
#
#  id           :uuid             not null, primary key
#  discarded_at :datetime
#  name         :string           not null
#  settings     :jsonb            not null
#  slug         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#
RSpec.describe Organization, type: :model do
  it "has a valid factory" do
    expect(build(:organization)).to be_valid
  end

  describe "name" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(80) }
  end

  describe "slug" do
    it { is_expected.to validate_presence_of(:slug) }

    it "accepts clean lowercase slugs" do
      %w[acme a1 two-words riverside-dental-2].each do |slug|
        expect(build(:organization, slug:)).to be_valid
      end
    end

    it "rejects malformed slugs", :negative do
      [ "Acme", "spaced out", "-lead", "trail-", "dots.host", "a", "x" * 41, "ünïcode" ].each do |slug|
        expect(build(:organization, slug:)).not_to be_valid
      end
    end

    it "rejects duplicate slugs case-insensitively (citext)", :negative do
      create(:organization, slug: "acme")
      expect(build(:organization, slug: "acme")).not_to be_valid
    end

    it "forbids slug changes after creation — join links must never break", :negative do
      organization = create(:organization)
      organization.slug = "renamed"
      expect(organization).not_to be_valid
      expect(organization.errors[:slug].join).to include("can't change")
    end

    it "rejects malformed slugs at the DB layer too", :negative do
      organization = create(:organization)
      expect do
        organization.update_column(:slug, "Bad Slug")
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe "#setting" do
    it "reads a stored setting" do
      organization = build(:organization, settings: { "visibility" => "restricted" })
      expect(organization.setting("visibility")).to eq("restricted")
    end

    it "falls back to the documented default for unset keys" do
      organization = build(:organization, settings: {})
      expect(organization.setting("visibility")).to eq("all_members")
      expect(organization.setting("join_link_enabled")).to be(true)
      expect(organization.setting("board_cap_default")).to eq(10)
    end
  end

  describe "soft delete (forever — no purge, ratified Q1)" do
    it "discards and restores" do
      organization = create(:organization)
      expect(organization).not_to be_discarded

      organization.discard!
      expect(organization.reload).to be_discarded
      expect(described_class.kept).not_to include(organization)

      organization.restore!
      expect(organization.reload).not_to be_discarded
      expect(described_class.kept).to include(organization)
    end

    it "keeps discard/restore idempotent" do
      organization = create(:organization, :discarded)
      original = organization.discarded_at
      organization.discard!
      expect(organization.discarded_at).to eq(original)

      organization.restore!
      organization.restore!
      expect(organization.discarded_at).to be_nil
    end
  end

  it "hard-deletes memberships without ceremony when an org is destroyed (test/console path)" do
    organization = create(:organization, :with_owner)
    expect { ActsAsTenant.with_tenant(organization) { organization.destroy! } }.to change {
      ActsAsTenant.without_tenant { Membership.count }
    }.by(-1)
  end
end
