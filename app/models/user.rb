# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email_address   :citext           not null
#  login_mode      :string           default("password"), not null
#  password_digest :string
#  staff           :boolean          default(FALSE), not null
#  verified_at     :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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

  def verified? = verified_at.present?

  def password_login? = login_mode == "password"

  def verify!
    update!(verified_at: Time.current) unless verified?
  end
end
