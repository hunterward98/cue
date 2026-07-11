# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Login codes", type: :request do
  let(:codes_user) { create(:user, :passwordless, email_address: "codes@example.com") }

  describe "POST /login_code" do
    it "emails a code to passwordless accounts and flips login to code entry" do
      perform_enqueued_jobs { post login_code_path, params: { email_address: codes_user.email_address } }

      expect(ActionMailer::Base.deliveries.sole.subject).to match(/sign-in code: \d{6}/)
      follow_redirect!
      expect(inertia.props[:code_sent]).to eq(codes_user.email_address)
    end

    it "nudges password-mode accounts instead, with the identical response", :negative do
      password_user = create(:user)

      perform_enqueued_jobs { post login_code_path, params: { email_address: password_user.email_address } }

      expect(ActionMailer::Base.deliveries.sole.subject).to include("signs in with a password")
      expect(response).to redirect_to(new_session_path)
    end

    it "sends nothing for unknown emails, with the identical response", :negative do
      perform_enqueued_jobs { post login_code_path, params: { email_address: "ghost@example.com" } }

      expect(ActionMailer::Base.deliveries).to be_empty
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "POST /session (code)" do
    def request_code_for(user)
      perform_enqueued_jobs { post login_code_path, params: { email_address: user.email_address } }
      ActionMailer::Base.deliveries.last.subject[/\d{6}/]
    end

    it "signs in with a valid code and verifies the account by proof of inbox" do
      unverified = create(:user, :passwordless, :unverified)
      code = request_code_for(unverified)

      post session_path, params: { code: }

      expect(response).to redirect_to(organizations_url)
      expect(unverified.reload).to be_verified
      expect(unverified.sessions.count).to eq(1)
    end

    it "rejects wrong codes with the standard alert", :negative do
      request_code_for(codes_user)

      post session_path, params: { code: "000000" }

      expect(codes_user.sessions.count).to eq(0)
      expect(flash[:alert]).to eq(SessionsController::INVALID_LOGIN)
    end

    it "rejects a code from a browser that never requested one", :negative do
      code = request_code_for(codes_user)
      # A different client (fresh cookie jar) replays the stolen code.
      reset!

      post session_path, params: { code: }

      expect(codes_user.sessions.count).to eq(0)
      expect(flash[:alert]).to eq(SessionsController::INVALID_LOGIN)
    end

    it "rejects a verification code smuggled in as a login code", :negative do
      request_code_for(codes_user)
      smuggled = AuthToken.issue!(user: codes_user, purpose: "email_verification")

      post session_path, params: { code: smuggled.code }

      expect(codes_user.sessions.count).to eq(0)
    end
  end

  describe "GET /login_code/:token (magic link)" do
    it "signs in with one tap" do
      issued = AuthToken.issue!(user: codes_user, purpose: "login_code")

      get confirm_login_code_path(token: issued.link_token)

      expect(response).to redirect_to(organizations_path)
      expect(codes_user.sessions.count).to eq(1)
    end

    it "rejects replayed and garbage links", :negative do
      issued = AuthToken.issue!(user: codes_user, purpose: "login_code")

      get confirm_login_code_path(token: issued.link_token)
      delete session_path
      get confirm_login_code_path(token: issued.link_token)
      expect(codes_user.sessions.count).to eq(0)

      get confirm_login_code_path(token: "forged")
      expect(response).to redirect_to(new_session_path)
    end
  end
end
