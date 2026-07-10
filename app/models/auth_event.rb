# Append-only auth audit log (auth plan_2): consumed by hardening
# (lockout decisions) and the future support console. History does not
# get edited — the model is readonly once persisted.
class AuthEvent < ApplicationRecord
  ACTIONS = %w[
    signup email_verified verification_resent
    login_succeeded login_failed logout
    login_code_requested
    password_reset_requested password_reset_completed
  ].freeze

  belongs_to :user, optional: true

  validates :action, inclusion: { in: ACTIONS }

  def readonly? = persisted?

  def self.record!(action, user: nil, request: nil, metadata: {})
    create!(
      action:, user:, metadata:,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end
end
