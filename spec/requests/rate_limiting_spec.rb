# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rate limiting", type: :request do
  # Rack::Attack is off for the rest of the suite; these specs flip it on
  # with a fresh store to prove the throttles actually trip — the
  # critique's warning was that an unconfigured store silently no-ops.
  around do |example|
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rack::Attack.enabled = false
  end

  it "throttles the 6th rapid attempt against one email", :negative do
    5.times do
      post session_path, params: { email_address: "victim@example.com", password: "guess-guess-guess" }
      expect(response).to have_http_status(:redirect)
    end

    post session_path, params: { email_address: "victim@example.com", password: "guess-guess-guess" }

    expect(response).to have_http_status(:too_many_requests)
    expect(response.body).to include("Easy there.")
  end

  it "throttles the 11th auth request from one IP across emails", :negative do
    10.times do |n|
      post session_path, params: { email_address: "probe-#{n}@example.com", password: "guess-guess-guess" }
    end

    post session_path, params: { email_address: "probe-11@example.com", password: "guess-guess-guess" }

    expect(response).to have_http_status(:too_many_requests)
  end

  it "never throttles the health probes" do
    15.times { get rails_health_check_path }
    expect(response).to have_http_status(:ok)

    get full_health_check_path
    expect(response).to have_http_status(:ok)
  end

  it "throttles the 21st invitation send from one sender within an hour", :negative do
    organization = create(:organization)
    owner = create(:membership, :owner, organization:).user
    sign_in owner

    20.times do |n|
      post org_invitations_path(org_slug: organization.slug), params: { email: "invitee-#{n}@example.com" }
      expect(response).to have_http_status(:redirect)
    end

    post org_invitations_path(org_slug: organization.slug), params: { email: "invitee-20@example.com" }

    expect(response).to have_http_status(:too_many_requests)
  end
end
