# Email invitations into an org (organizations-users plan_3): owner
# sends one, invitee accepts via a magic link. Auto-approved on accept —
# the join-link + approval queue (Memberships::Enroll/Activate) is the
# other door, for people an owner didn't personally invite.
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
# Indexes
#
#  index_invitations_on_inviter_id                   (inviter_id)
#  index_invitations_on_org_and_email_while_pending  (organization_id,email) UNIQUE WHERE ((state)::text = 'pending'::text)
#  index_invitations_on_organization_id              (organization_id)
#  index_invitations_on_token_digest                 (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (inviter_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Invitation < ApplicationRecord
  STATES = %w[pending accepted expired revoked].freeze
  TTL = 14.days

  acts_as_tenant :organization
  belongs_to :inviter, class_name: "User"

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :state, inclusion: { in: STATES }
  # DB partial unique index is the real guard (race-proof); this makes
  # the common case a form error instead of a 500 (Organization#slug
  # sets the precedent).
  validate :no_other_pending_invite_for_email, on: :create

  scope :pending, -> { where(state: "pending") }
  # A reservation is "live" only while it's both pending and unexpired —
  # a token past its TTL holds no seat even before the sweep job
  # (config/recurring.yml) gets around to relabeling it (AuthToken sets
  # this precedent: redemption logic never trusts stale state alone).
  scope :reserving_seat, -> { pending.where("expires_at > ?", Time.current) }

  class << self
    Issued = Data.define(:invitation, :token)

    def invite!(organization:, inviter:, email:, owner: false, board_owner: false)
      ActsAsTenant.with_tenant(organization) do
        token = SecureRandom.urlsafe_base64(32)
        invitation = create!(
          organization:, inviter:, email:, owner:, board_owner:,
          token_digest: digest(token), expires_at: TTL.from_now, state: "pending"
        )
        Issued.new(invitation:, token:)
      end
    end

    # No org context yet — a tap from an email, same shape as
    # AuthToken.redeem_link/peek_link. The digest is the whole search
    # key (effectively unique across the table), so cross-tenant lookup
    # here is correct, not a leak.
    def find_by_token(token)
      ActsAsTenant.without_tenant { find_by(token_digest: digest(token.to_s)) }
    end

    def digest(value) = OpenSSL::Digest::SHA256.hexdigest(value)

    # config/recurring.yml — a global sweep, not one org's. Cosmetic —
    # see `reserving_seat` above for why correctness never depends on
    # this having run.
    def sweep_expired!
      ActsAsTenant.without_tenant { pending.where(expires_at: ...Time.current).update_all(state: "expired") }
    end
  end

  def redeemable?
    state == "pending" && expires_at.future?
  end

  def revoke!
    return false unless state == "pending"

    update!(state: "revoked")
    true
  end

  # Same row, fresh token — the old one stops working the instant this
  # digest overwrites it (member-management "resend").
  def resend!
    return nil unless state == "pending"

    token = SecureRandom.urlsafe_base64(32)
    update!(token_digest: self.class.digest(token), expires_at: TTL.from_now)
    token
  end

  private

  def no_other_pending_invite_for_email
    return if organization.nil? || email.blank?

    exists = ActsAsTenant.with_tenant(organization) do
      organization.invitations.pending.where(email:).exists?
    end
    errors.add(:email, "already has a pending invitation") if exists
  end
end
