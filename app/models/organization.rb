# frozen_string_literal: true

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
class Organization < ApplicationRecord
  # Mirrors the DB check constraint; validated here too so slug errors are
  # form errors, not 500s.
  SLUG_FORMAT = /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?\z/
  SLUG_LENGTH = 2..40

  # The documented shape of `settings` (org plan_2). Values here are the
  # org-wide defaults; plan_4's typed form object is the only writer.
  # - visibility: who sees boards/cues — "all_members" (default, ratified
  #   org plan_1 Q2) or "restricted" (requesters see own requests +
  #   completed only; cues plan consumes).
  # - join_link_enabled: the /join/:slug door (org plan_3 consumes).
  # - board_cap_default: default per-board active-cue cap (boards plan_2
  #   consumes).
  DEFAULT_SETTINGS = {
    "visibility" => "all_members",
    "join_link_enabled" => true,
    "board_cap_default" => 10
  }.freeze

  # delete_all, not destroy: cascading destroy would trip each
  # membership's last-owner guard. Hard org deletion is a test/console-only
  # operation anyway — the product soft-deletes forever.
  has_many :memberships, dependent: :delete_all
  has_many :users, through: :memberships

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true,
                   format: { with: SLUG_FORMAT, message: "only lowercase letters, numbers, and hyphens (no leading/trailing hyphen)" },
                   length: { in: SLUG_LENGTH }
  validate :slug_immutable, on: :update

  scope :kept, -> { where(discarded_at: nil) }

  def setting(key) = settings.fetch(key) { DEFAULT_SETTINGS.fetch(key) }

  def discarded? = discarded_at.present?

  # Soft-delete forever (Q1, ratified): recoverable at any time, no purge.
  def discard!
    update!(discarded_at: Time.current) unless discarded?
  end

  def restore!
    update!(discarded_at: nil) if discarded?
  end

  private

  # Join links and bookmarks never break (org plan_4 Q2, ratified);
  # renames become a support-console operation with an audit trail.
  def slug_immutable
    errors.add(:slug, "can't change — it lives in your join links") if slug_changed?
  end
end
