# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id              :uuid             not null, primary key
#  board_owner     :boolean          default(FALSE), not null
#  owner           :boolean          default(FALSE), not null
#  state           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#  user_id         :uuid             not null
#
# Indexes
#
#  index_memberships_on_organization_id              (organization_id)
#  index_memberships_on_organization_id_and_user_id  (organization_id,user_id) UNIQUE
#  index_memberships_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (user_id => users.id)
#
class Membership < ApplicationRecord
  # No `invited`: invitees without accounts can't have a user row, so the
  # invited lifecycle lives on Invitation (org plan_3). Deny destroys the
  # pending row, so there's no `denied` either.
  STATES = %w[pending_approval active deactivated].freeze
  TRANSITIONS = {
    "pending_approval" => %w[active],
    "active" => %w[deactivated],
    "deactivated" => %w[active]
  }.freeze

  acts_as_tenant :organization
  belongs_to :user

  validates :state, inclusion: { in: STATES }
  validates_uniqueness_to_tenant :user_id
  validate :transition_allowed, on: :update
  # Roles are two booleans (plan_2 critique, ratified): requester = both
  # false; multiple owners are expected for larger customers.
  validate :keeps_an_active_owner, on: :update
  before_destroy :refuse_to_orphan_the_org

  scope :active, -> { where(state: "active") }
  scope :owners, -> { active.where(owner: true) }
  scope :board_owners, -> { active.where(board_owner: true) }

  def active? = state == "active"

  def requester? = !owner? && !board_owner?

  def activate!
    update!(state: "active")
  end

  def deactivate!
    update!(state: "deactivated")
  end

  private

  def transition_allowed
    return unless state_changed?
    return if TRANSITIONS.fetch(state_was, []).include?(state)

    errors.add(:state, "can't go from #{state_was} to #{state}")
  end

  # An org must always keep ≥1 active owner. Model-level guard; the
  # concurrent-double-removal race is accepted as untestably rare at this
  # org size (plan_2 critique).
  def keeps_an_active_owner
    return unless losing_owner_seat?
    return if other_active_owner_exists?

    errors.add(:base, "every org needs at least one active owner — promote someone first")
  end

  def losing_owner_seat?
    was_active_owner = owner_was && state_was == "active"
    was_active_owner && !(owner? && active?)
  end

  def other_active_owner_exists?
    organization.memberships.owners.where.not(id: id).exists?
  end

  def refuse_to_orphan_the_org
    return unless owner? && active?
    return if other_active_owner_exists?

    errors.add(:base, "every org needs at least one active owner — promote someone first")
    throw :abort
  end
end
