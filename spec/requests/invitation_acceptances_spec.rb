# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Invitation acceptances", type: :request do
  let(:organization) { create(:organization, :with_owner) }

  describe "GET /invitations/:token" do
    it "accepts immediately for a signed-in user with the matching email" do
      user = create(:user, email_address: "invitee@example.com")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end
      sign_in user

      get accept_invitation_path(token: issued.token)

      expect(response).to redirect_to(org_root_path(org_slug: organization.slug))
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user:) }
      expect(membership).to be_active
      expect(issued.invitation.reload.state).to eq("accepted")
    end

    it "shows a switch-account screen for a signed-in user with a different email" do
      current_user = create(:user, email_address: "current@example.com")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end
      sign_in current_user

      get accept_invitation_path(token: issued.token)

      expect_inertia.to render_component("auth/switch_account")
      expect(inertia.props.fetch(:current_email)).to eq("current@example.com")
      expect(inertia.props.fetch(:invited_email)).to eq("invitee@example.com")
    end

    it "sends a signed-out visitor with an existing account to sign in" do
      create(:user, email_address: "invitee@example.com")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end

      get accept_invitation_path(token: issued.token)

      expect(response).to redirect_to(new_session_path(email_address: "invitee@example.com"))
    end

    it "sends a signed-out visitor with no account to registration" do
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "brandnew@example.com")
      end

      get accept_invitation_path(token: issued.token)

      expect(response).to redirect_to(new_registration_path(email_address: "brandnew@example.com"))
    end

    it "rejects a bad token", :negative do
      get accept_invitation_path(token: "not-a-real-token")
      expect(response).to redirect_to(organizations_path)
    end

    it "rejects an expired invitation, creating no membership", :negative do
      user = create(:user, email_address: "invitee@example.com")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end
      issued.invitation.update!(expires_at: 1.minute.ago)
      sign_in user

      get accept_invitation_path(token: issued.token)

      expect(response).to redirect_to(organizations_path)
      expect(ActsAsTenant.with_tenant(organization) { organization.memberships.exists?(user:) }).to be(false)
    end

    it "rejects an already-accepted invitation on a second visit", :negative do
      user = create(:user, email_address: "invitee@example.com")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end
      sign_in user
      get accept_invitation_path(token: issued.token)

      get accept_invitation_path(token: issued.token)

      expect(response).to redirect_to(organizations_path)
    end

    it "surfaces a failed accept (seat vanished since the invite) as a flash alert, not a crash", :negative do
      user = create(:user, email_address: "invitee@example.com")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end
      create_list(:membership, 15, organization:) # someone else filled every seat in the meantime
      sign_in user

      with_tier(:basic) { get accept_invitation_path(token: issued.token) }

      expect(response).to redirect_to(organizations_path)
      expect(ActsAsTenant.with_tenant(organization) { organization.memberships.exists?(user:) }).to be(false)
    end
  end

  describe "DELETE /invitations/:token/session" do
    it "signs out and returns to the invitation" do
      current_user = create(:user)
      sign_in current_user

      delete switch_account_for_invitation_path(token: "some-token")

      expect(response).to redirect_to(accept_invitation_path(token: "some-token"))
      get organizations_path
      expect(response).to redirect_to(new_session_path)
    end

    it "is a harmless no-op when there was no session to sign out of" do
      delete switch_account_for_invitation_path(token: "some-token")
      expect(response).to redirect_to(accept_invitation_path(token: "some-token"))
    end
  end

  describe "full loop: existing user signs in mid-flow and lands accepted" do
    it "accepts the invitation right after login" do
      user = create(:user, email_address: "invitee@example.com", password: "a-long-enough-password")
      issued = ActsAsTenant.with_tenant(organization) do
        Invitation.invite!(organization:, inviter: organization.memberships.owners.first.user, email: "invitee@example.com")
      end

      get accept_invitation_path(token: issued.token) # stashes the token, redirects to login
      post session_path, params: { email_address: user.email_address, password: "a-long-enough-password" }
      expect(response).to redirect_to(accept_invitation_path(token: issued.token))

      follow_redirect! # lands back on the invitation, now signed in — this hop does the accepting

      expect(response).to redirect_to(org_root_path(org_slug: organization.slug))
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user:) }
      expect(membership).to be_active
    end
  end
end
