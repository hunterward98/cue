# == Schema Information
#
# Table name: sessions
#
#  id             :uuid             not null, primary key
#  ip_address     :string
#  last_active_at :datetime         not null
#  user_agent     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Session < ApplicationRecord
  # Ratified (auth plan_1 Q2): 7 days for every role, absolute — resuming
  # activity does not extend it.
  LIFETIME = 7.days
  # last_active_at is bookkeeping for the "your sessions" screen, not a
  # sliding expiry; throttle writes to one per interval.
  ACTIVITY_RESOLUTION = 5.minutes

  belongs_to :user

  before_validation(on: :create) { self.last_active_at ||= Time.current }

  scope :active, -> { where(created_at: LIFETIME.ago..) }

  def expired? = created_at < LIFETIME.ago

  def record_activity!
    return if last_active_at > ACTIVITY_RESOLUTION.ago

    update_column(:last_active_at, Time.current)
  end
end
