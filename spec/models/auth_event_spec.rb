# frozen_string_literal: true

require "rails_helper"

# == Schema Information
#
# Table name: auth_events
#
#  id         :uuid             not null, primary key
#  action     :string           not null
#  ip_address :string
#  metadata   :jsonb            not null
#  user_agent :string
#  created_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_auth_events_on_action   (action)
#  index_auth_events_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe AuthEvent, type: :model do
  it "records an event with request context" do
    request = instance_double(ActionDispatch::Request, remote_ip: "203.0.113.7", user_agent: "RSpec")
    user = create(:user)

    event = described_class.record!("login_succeeded", user:, request:, metadata: { mode: "password" })

    expect(event).to be_persisted
    expect(event.ip_address).to eq("203.0.113.7")
    expect(event.metadata).to eq("mode" => "password")
  end

  it "records user-less events (failed probes for unknown emails)" do
    expect(described_class.record!("login_failed")).to be_persisted
  end

  it "rejects actions outside the catalog", :negative do
    expect { described_class.record!("made_up") }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it_behaves_like "an append-only table", attribute: :action, value: "logout" do
    let(:record) { create(:auth_event) }
  end
end
