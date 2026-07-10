# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /registration/new" do
    it "renders the signup page" do
      get new_registration_path
      expect_inertia.to render_component("auth/register")
    end
  end

  describe "POST /registration" do
    let(:params) do
      { email_address: "new@example.com", login_mode: "password", password: "a-long-enough-password" }
    end

    it "creates an unverified user, emails a verification code, and lands on the gate" do
      expect do
        perform_enqueued_jobs { post registration_path, params: }
      end.to change(User, :count).by(1)

      user = User.find_by!(email_address: "new@example.com")
      expect(user).not_to be_verified
      expect(response).to redirect_to(email_verification_path)
      expect(ActionMailer::Base.deliveries.sole.subject).to match(/verification code: \d{6}/)
      expect(AuthEvent.where(action: "signup", user:)).to exist
    end

    it "creates passwordless accounts without a digest" do
      post registration_path, params: { email_address: "codes@example.com", login_mode: "passwordless" }

      expect(User.find_by!(email_address: "codes@example.com").password_digest).to be_nil
    end

    it "gives an existing email the identical response but a different email", :negative do
      existing = create(:user, email_address: "taken@example.com")

      expect do
        perform_enqueued_jobs do
          post registration_path, params: params.merge(email_address: "taken@example.com")
        end
      end.not_to change(User, :count)

      expect(response).to redirect_to(email_verification_path)
      expect(ActionMailer::Base.deliveries.sole.subject).to eq("You already have a Cue account")
      expect(ActionMailer::Base.deliveries.sole.to).to eq([ existing.email_address ])
    end

    it "rejects invalid signups without creating anything", :negative do
      expect do
        post registration_path, params: params.merge(password: "short")
      end.not_to change(User, :count)

      expect(response).to redirect_to(new_registration_path)
    end
  end
end
