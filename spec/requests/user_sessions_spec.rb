# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Session management", type: :request do
  it_behaves_like "a route requiring a verified user" do
    let(:perform_request) { get user_sessions_path }
  end

  it "lists active sessions with the current one flagged" do
    user = create(:user)
    stale = create(:session, user:, created_at: 8.days.ago, last_active_at: 8.days.ago)
    other = create(:session, user:)
    sign_in user

    get user_sessions_path

    expect_inertia.to render_component("sessions/index")
    ids = inertia.props[:sessions].map { |s| s[:id] }
    expect(ids).to include(other.id)
    expect(ids).not_to include(stale.id)
    expect(inertia.props[:sessions].find { |s| s[:current] }).to be_present
  end

  it "revokes another device's session" do
    user = create(:user)
    other = create(:session, user:)
    sign_in user

    delete user_session_path(other)

    expect(user.sessions.where(id: other.id)).not_to exist
    expect(response).to redirect_to(user_sessions_path)
  end

  it "signs out fully when revoking the current session" do
    user = create(:user)
    sign_in user
    current = user.sessions.sole

    delete user_session_path(current)

    expect(response).to redirect_to(new_session_path)
    get user_sessions_path
    expect(response).to redirect_to(new_session_path)
  end

  it "forbids revoking a stranger's session", :negative do
    user = create(:user)
    stranger_session = create(:session)
    sign_in user

    delete user_session_path(stranger_session)

    expect(response).to have_http_status(:not_found)
    expect(Session.where(id: stranger_session.id)).to exist
  end
end
