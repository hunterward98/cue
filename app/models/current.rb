class Current < ActiveSupport::CurrentAttributes
  attribute :session, :organization, :membership
  delegate :user, to: :session, allow_nil: true
end
