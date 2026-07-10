# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Email verification", type: :request do
  def sign_up(email = "new@example.com")
    post registration_path,
         params: { email_address: email, login_mode: "password", password: "a-long-enough-password" }
    User.find_by!(email_address: email)
  end

  def issued_for(user, purpose: "email_verification")
    AuthToken.issue!(user:, purpose:)
  end

  describe "GET /email_verification" do
    it "shows the check-inbox screen for a pending signup" do
      sign_up
      get email_verification_path

      expect_inertia.to render_component("auth/check_inbox")
      expect(inertia.props[:email]).to eq("new@example.com")
    end

    it "bounces visitors with nothing pending to the login screen", :negative do
      get email_verification_path
      expect(response).to redirect_to(new_session_path)
    end

    it "shows the gate to a signed-in unverified user with no signup pending" do
      unverified = create(:user, :unverified)
      sign_in unverified

      get email_verification_path

      expect_inertia.to render_component("auth/check_inbox")
      expect(inertia.props[:email]).to eq(unverified.email_address)
    end

    it "sends already-verified visitors home", :negative do
      sign_in create(:user)
      get email_verification_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /email_verification" do
    it "verifies with a correct code and signs the user in" do
      user = sign_up
      issued = issued_for(user)

      patch email_verification_path, params: { code: issued.code }

      expect(user.reload).to be_verified
      expect(response).to redirect_to(root_path)
      expect(user.sessions.count).to eq(1)
      expect(AuthEvent.where(action: "email_verified", user:)).to exist
    end

    it "rejects a wrong code and stays unverified", :negative do
      user = sign_up
      issued_for(user)

      patch email_verification_path, params: { code: "000000" }

      expect(user.reload).not_to be_verified
      expect(response).to redirect_to(email_verification_path)
      expect(flash[:alert]).to include("didn't work")
    end

    it "verifies a signed-in user in place without minting a second session" do
      unverified = create(:user, :unverified)
      sign_in unverified
      issued = issued_for(unverified)

      patch email_verification_path, params: { code: issued.code }

      expect(unverified.reload).to be_verified
      expect(unverified.sessions.count).to eq(1)
    end

    it "rejects an expired code", :negative do
      user = sign_up
      issued = issued_for(user)

      travel_to(16.minutes.from_now) do
        patch email_verification_path, params: { code: issued.code }
        expect(user.reload).not_to be_verified
      end
    end

    it "responds identically when nothing is pending at all", :negative do
      patch email_verification_path, params: { code: "123456" }
      expect(response).to redirect_to(email_verification_path)
      expect(flash[:alert]).to include("didn't work")
    end
  end

  describe "POST /email_verification/resend" do
    it "re-issues and invalidates the old code" do
      user = sign_up
      stale = issued_for(user)

      perform_enqueued_jobs { post resend_email_verification_path }

      expect(ActionMailer::Base.deliveries.sole.subject).to include('verification code')
      patch email_verification_path, params: { code: stale.code }
      expect(user.reload).not_to be_verified
    end

    it "sends nothing when nothing is pending, with the identical response", :negative do
      perform_enqueued_jobs { post resend_email_verification_path }

      expect(ActionMailer::Base.deliveries).to be_empty
      expect(response).to redirect_to(email_verification_path)
    end
  end

  describe "GET /email_verification/:token (magic link)" do
    it "verifies and signs in with one tap" do
      user = sign_up
      issued = issued_for(user)

      get confirm_email_verification_path(token: issued.link_token)

      expect(user.reload).to be_verified
      expect(response).to redirect_to(root_path)
    end

    it "rejects a replayed link", :negative do
      user = sign_up
      issued = issued_for(user)

      get confirm_email_verification_path(token: issued.link_token)
      delete session_path
      get confirm_email_verification_path(token: issued.link_token)

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to include("invalid or has expired")
    end

    it "rejects garbage tokens", :negative do
      get confirm_email_verification_path(token: "forged")
      expect(response).to redirect_to(new_session_path)
    end
  end
end
