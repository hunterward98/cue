# frozen_string_literal: true

require "rails_helper"

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
RSpec.describe Session, type: :model do
  it "expires 7 days after creation, absolutely" do
    session = create(:session)

    travel_to(6.days.from_now) { expect(session).not_to be_expired }
    travel_to(8.days.from_now) do
      expect(session).to be_expired
      expect(described_class.active).not_to include(session)
    end
  end

  it "fails to extend its life through activity", :negative do
    session = create(:session)

    travel_to(8.days.from_now) do
      session.record_activity!
      expect(session.reload).to be_expired
    end
  end

  describe "#record_activity!" do
    it "throttles bookkeeping writes to the activity resolution" do
      session = create(:session)
      original = session.last_active_at

      travel_to(1.minute.from_now) do
        session.record_activity!
        expect(session.reload.last_active_at).to eq(original)
      end

      travel_to(6.minutes.from_now) do
        session.record_activity!
        expect(session.reload.last_active_at).to be > original
      end
    end
  end
end
