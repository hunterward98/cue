# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user, email_address: "me@example.com") }

  describe "POST /session (password)" do
    it "signs in and records the event" do
      post session_path, params: { email_address: user.email_address, password: "a-long-enough-password" }

      expect(response).to redirect_to(root_url)
      expect(user.sessions.count).to eq(1)
      expect(AuthEvent.where(action: "login_succeeded", user:)).to exist
    end

    it "sends an unverified account to the verification gate after login" do
      unverified = create(:user, :unverified)
      sign_in unverified
      expect(response).to redirect_to(email_verification_path)
    end

    it "rejects a wrong password with the standard alert", :negative do
      post session_path, params: { email_address: user.email_address, password: "wrong-but-long-enough" }

      expect(user.sessions.count).to eq(0)
      expect(flash[:alert]).to eq(SessionsController::INVALID_LOGIN)
      expect(AuthEvent.where(action: "login_failed", user:)).to exist
    end

    it "responds to unknown emails exactly like wrong passwords", :negative do
      post session_path, params: { email_address: "ghost@example.com", password: "whatever-long-enough" }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq(SessionsController::INVALID_LOGIN)
    end

    it "rejects passwords aimed at passwordless accounts, identically", :negative do
      codes_user = create(:user, :passwordless)
      post session_path, params: { email_address: codes_user.email_address, password: "a-long-enough-password" }

      expect(codes_user.sessions.count).to eq(0)
      expect(flash[:alert]).to eq(SessionsController::INVALID_LOGIN)
    end
  end

  describe "DELETE /session" do
    it "signs out and kills the session record" do
      sign_in user
      expect { delete session_path }.to change { user.sessions.count }.to(0)
      expect(response).to redirect_to(new_session_path)

      get user_sessions_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "session expiry" do
    it "treats an 8-day-old session as dead", :negative do
      sign_in user

      travel_to(8.days.from_now) do
        get user_sessions_path
        expect(response).to redirect_to(new_session_path)
        expect(user.sessions.count).to eq(0)
      end
    end
  end

  describe "GET /session/new" do
    it "renders login for visitors and bounces the signed-in" do
      get new_session_path
      expect_inertia.to render_component("auth/login")

      sign_in user
      get new_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end
