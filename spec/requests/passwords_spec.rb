# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Password reset", type: :request do
  let(:user) { create(:user, email_address: "me@example.com") }

  def issue_reset(target = user)
    AuthToken.issue!(user: target, purpose: "password_reset")
  end

  describe "GET /passwords/new" do
    it "renders the forgot-password page" do
      get new_password_path
      expect_inertia.to render_component("auth/forgot_password")
    end
  end

  describe "POST /passwords" do
    it "emails reset instructions to password-mode accounts" do
      perform_enqueued_jobs { post passwords_path, params: { email_address: user.email_address } }

      expect(ActionMailer::Base.deliveries.sole.subject).to eq("Reset your Cue password")
      expect(AuthEvent.where(action: "password_reset_requested", user:)).to exist
    end

    it "sends nothing for passwordless or unknown emails, identical response", :negative do
      codes_user = create(:user, :passwordless)

      perform_enqueued_jobs { post passwords_path, params: { email_address: codes_user.email_address } }
      perform_enqueued_jobs { post passwords_path, params: { email_address: "ghost@example.com" } }

      expect(ActionMailer::Base.deliveries).to be_empty
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /passwords/:token/edit" do
    it "renders the reset form for a live token" do
      issued = issue_reset

      get edit_password_path(token: issued.link_token)

      expect_inertia.to render_component("auth/reset_password")
      expect(inertia.props[:token]).to eq(issued.link_token)
    end

    it "bounces dead links", :negative do
      get edit_password_path(token: "forged")
      expect(response).to redirect_to(new_password_path)
    end
  end

  describe "PATCH /passwords/:token" do
    it "resets the password, revokes every session, and notifies" do
      sign_in user
      issued = issue_reset

      perform_enqueued_jobs do
        patch password_path(token: issued.link_token), params: { password: "a-brand-new-password" }
      end

      expect(user.reload.authenticate("a-brand-new-password")).to be_truthy
      expect(user.sessions.count).to eq(0)
      expect(ActionMailer::Base.deliveries.map(&:subject)).to include("Your Cue password was changed")
      expect(AuthEvent.where(action: "password_reset_completed", user:)).to exist
    end

    it "keeps the token alive through a validation stumble, then consumes it" do
      issued = issue_reset

      patch password_path(token: issued.link_token), params: { password: "short" }
      expect(response).to redirect_to(edit_password_path(token: issued.link_token))

      patch password_path(token: issued.link_token), params: { password: "a-brand-new-password" }
      expect(user.reload.authenticate("a-brand-new-password")).to be_truthy
    end

    it "rejects a replayed token after a successful reset", :negative do
      issued = issue_reset
      patch password_path(token: issued.link_token), params: { password: "a-brand-new-password" }

      patch password_path(token: issued.link_token), params: { password: "attacker-chosen-pass" }

      expect(response).to redirect_to(new_password_path)
      expect(user.reload.authenticate("attacker-chosen-pass")).to be_falsey
    end

    it "rejects an expired token", :negative do
      issued = issue_reset

      travel_to(16.minutes.from_now) do
        patch password_path(token: issued.link_token), params: { password: "a-brand-new-password" }
        expect(response).to redirect_to(new_password_path)
      end
    end
  end
end
