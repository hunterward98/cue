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

  describe "signing up via an invitation link (org plan_3, ADR 0015)" do
    let(:organization) { create(:organization, :with_owner) }

    def stash_invitation_token(email)
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email:)
      end
      get accept_invitation_path(token: issued.token) # stashes session[:pending_invitation_token]
      issued
    end

    it "creates an already-verified account, accepts the invitation, and signs in — no code round-trip" do
      stash_invitation_token("invitee@example.com")

      expect do
        post registration_path, params: {
          email_address: "invitee@example.com", login_mode: "password", password: "a-long-enough-password"
        }
      end.to change(User, :count).by(1)

      user = User.find_by!(email_address: "invitee@example.com")
      expect(user).to be_verified
      expect(response).to redirect_to(org_root_path(org_slug: organization.slug))
      expect(ActionMailer::Base.deliveries).to be_empty # no verification email sent

      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user:) }
      expect(membership).to be_active
    end

    it "falls through to the normal verify-by-code path when the submitted email doesn't match the stashed invitation", :negative do
      stash_invitation_token("invitee@example.com")

      expect do
        perform_enqueued_jobs do
          post registration_path, params: {
            email_address: "someone-else@example.com", login_mode: "password", password: "a-long-enough-password"
          }
        end
      end.to change(User, :count).by(1)

      user = User.find_by!(email_address: "someone-else@example.com")
      expect(user).not_to be_verified
      expect(response).to redirect_to(email_verification_path)
    end

    it "falls through to the normal path when the stashed token no longer resolves to any invitation", :negative do
      issued = stash_invitation_token("invitee@example.com")
      issued.invitation.update!(token_digest: Invitation.digest("superseded")) # e.g. resent since

      expect do
        perform_enqueued_jobs do
          post registration_path, params: {
            email_address: "invitee@example.com", login_mode: "password", password: "a-long-enough-password"
          }
        end
      end.to change(User, :count).by(1)

      user = User.find_by!(email_address: "invitee@example.com")
      expect(user).not_to be_verified
      expect(response).to redirect_to(email_verification_path)
    end

    it "still creates and signs in the (already-verified) account when the seat vanished, surfacing the error", :negative do
      stash_invitation_token("invitee@example.com")
      create_list(:membership, 15, organization:) # someone else filled every seat in the meantime

      with_tier(:basic) do
        post registration_path, params: {
          email_address: "invitee@example.com", login_mode: "password", password: "a-long-enough-password"
        }
      end

      user = User.find_by!(email_address: "invitee@example.com")
      expect(user).to be_verified
      expect(response).to redirect_to(organizations_path)
      expect(ActsAsTenant.with_tenant(organization) { organization.memberships.exists?(user:) }).to be(false)
    end
  end
end
