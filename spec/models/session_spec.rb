# frozen_string_literal: true

require "rails_helper"

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
