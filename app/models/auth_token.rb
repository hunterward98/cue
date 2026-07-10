# One-time secrets for verification, resets, login codes, and second
# factors (auth plan_2 token discipline): stored as digests, single-use,
# purpose-scoped, short-lived, invalidated by newer issuance. Every token
# is minted as a 6-digit code plus a magic-link twin in the same email —
# code for cross-device typing, link for one tap on the phone.
class AuthToken < ApplicationRecord
  PURPOSES = %w[email_verification password_reset login_code second_factor].freeze
  TTLS = {
    "email_verification" => 15.minutes,
    "password_reset" => 15.minutes,
    "login_code" => 15.minutes,
    "second_factor" => 5.minutes
  }.freeze
  MAX_ATTEMPTS = 3

  Issued = Data.define(:token, :code, :link_token)

  belongs_to :user

  validates :purpose, inclusion: { in: PURPOSES }

  scope :consumable, -> { where(consumed_at: nil).where(expires_at: Time.current..) }

  class << self
    def issue!(user:, purpose:)
      transaction do
        # Newer issuance invalidates anything outstanding.
        where(user:, purpose:).consumable.update_all(consumed_at: Time.current)

        code = format("%06d", SecureRandom.random_number(1_000_000))
        link_token = SecureRandom.urlsafe_base64(32)
        token = create!(
          user:, purpose:,
          code_digest: digest(code),
          token_digest: digest(link_token),
          expires_at: TTLS.fetch(purpose).from_now
        )
        Issued.new(token:, code:, link_token:)
      end
    end

    # Code redemption is scoped to a known user (they typed it on a screen
    # that knows who they are). Wrong guesses burn attempts; MAX_ATTEMPTS
    # burns the token entirely — re-issue is the only way forward.
    def redeem_code(user:, purpose:, code:)
      token = where(user:, purpose:).consumable.order(created_at: :desc).first
      return nil unless token

      token.increment!(:attempts_count)
      return nil if token.attempts_count > MAX_ATTEMPTS
      return nil unless secure_match?(token.code_digest, code.to_s)

      token.consume!
    end

    # Link redemption arrives with no user context (a tap from an email).
    def redeem_link(purpose:, link_token:)
      peek_link(purpose:, link_token:)&.consume!
    end

    # Looks a link token up without consuming it — for flows that must
    # only burn the token when their side effect succeeds (password reset
    # saves the new password first).
    def peek_link(purpose:, link_token:)
      consumable.find_by(token_digest: digest(link_token.to_s), purpose:)
    end

    def digest(value)
      OpenSSL::Digest::SHA256.hexdigest(value)
    end

    private

    def secure_match?(stored_digest, submitted)
      ActiveSupport::SecurityUtils.secure_compare(stored_digest, digest(submitted))
    end
  end

  def consume!
    update!(consumed_at: Time.current)
    self
  end
end
