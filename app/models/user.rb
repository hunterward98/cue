# == Schema Information
#
# Table name: users
#
#  id                    :uuid             not null, primary key
#  email_address         :citext           not null
#  failed_login_attempts :integer          default(0), not null
#  locked_at             :datetime
#  login_mode            :string           default("password"), not null
#  password_digest       :string
#  staff                 :boolean          default(FALSE), not null
#  verified_at           :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  LOGIN_MODES = %w[password passwordless].freeze
  PASSWORD_LENGTH = 12..72 # bcrypt truncates past 72 bytes

  # validations: false — passwordless-mode users have no digest at all;
  # the rules below cover the password mode (ratified A1).
  has_secure_password validations: false

  has_many :sessions, dependent: :destroy
  has_many :auth_tokens, dependent: :destroy
  # No dependent option: the last-owner guard must arbitrate whether a
  # membership can go, and a real account-deletion feature (with org
  # handoff) doesn't exist yet — until it does, the FK restricts deletion.
  has_many :memberships
  # auth_events intentionally carries no dependent option: the log is
  # append-only and the FK restricts user deletion until a real
  # account-deletion feature decides what happens to history.
  has_many :auth_events

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :login_mode, inclusion: { in: LOGIN_MODES }
  validates :password, presence: true, on: :create, if: :password_login?
  validates :password, length: { in: PASSWORD_LENGTH }, allow_nil: true
  validates :password_digest, absence: true, unless: :password_login?
  validate :password_not_breached, if: -> { password.present? }

  LOCKOUT_THRESHOLD = 10

  def verified? = verified_at.present?

  def locked? = locked_at.present?

  # Consecutive failures; the threshold locks the account until the
  # emailed unlock link is used (auth plan_3). Callers handle the email.
  def register_failed_login!
    increment!(:failed_login_attempts)
    return false if locked? || failed_login_attempts < LOCKOUT_THRESHOLD

    update!(locked_at: Time.current)
    true
  end

  def register_successful_login!
    update!(failed_login_attempts: 0) if failed_login_attempts.positive?
  end

  def unlock!
    update!(locked_at: nil, failed_login_attempts: 0)
  end

  def password_login? = login_mode == "password"

  def verify!
    update!(verified_at: Time.current) unless verified?
  end

  private

  # Gated by config so the suite runs offline; enabled in dev/prod
  # (auth plan_3; the service itself fails open on API trouble).
  def password_not_breached
    return unless Rails.configuration.x.password_breach_check
    return unless PasswordBreachCheck.breached?(password)

    errors.add(:password, "has appeared in a public data breach — pick a different one")
  end
end
