# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Org invitations", type: :request do
  let(:organization) { create(:organization) }
  let(:owner) { create(:membership, :owner, organization:).user }

  describe "POST /o/:org_slug/invitations" do
    it "sends an invitation as an owner" do
      sign_in owner

      perform_enqueued_jobs do
        post org_invitations_path(org_slug: organization.slug), params: { email: "new@example.com" }
      end

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(ActsAsTenant.without_tenant { Invitation.find_by(email: "new@example.com") }).to be_present
      expect(ActionMailer::Base.deliveries.sole.to).to eq([ "new@example.com" ])
    end

    it "404s for a non-owner member, not 403", :negative do
      requester = create(:membership, organization:).user
      sign_in requester

      post org_invitations_path(org_slug: organization.slug), params: { email: "new@example.com" }

      expect(response).to have_http_status(:not_found)
      expect(ActsAsTenant.without_tenant { Invitation.count }).to eq(0)
    end

    it "404s for a non-member entirely", :negative do
      sign_in create(:user)

      post org_invitations_path(org_slug: organization.slug), params: { email: "new@example.com" }

      expect(response).to have_http_status(:not_found)
    end

    it "surfaces a failed send (already-pending email) as a flash alert, not a crash", :negative do
      create(:invitation, organization:, email: "dup@example.com")
      sign_in owner

      post org_invitations_path(org_slug: organization.slug), params: { email: "dup@example.com" }

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(ActsAsTenant.without_tenant { Invitation.where(email: "dup@example.com").count }).to eq(1)
    end

    it_behaves_like "a route requiring a verified user" do
      let(:perform_request) do
        post org_invitations_path(org_slug: organization.slug), params: { email: "new@example.com" }
      end
    end
  end

  describe "DELETE /o/:org_slug/invitations/:id" do
    it "revokes a pending invitation as an owner" do
      invitation = create(:invitation, organization:)
      sign_in owner

      delete org_invitation_path(org_slug: organization.slug, id: invitation.id)

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(invitation.reload.state).to eq("revoked")
    end

    it "404s for a non-owner", :negative do
      invitation = create(:invitation, organization:)
      sign_in create(:membership, organization:).user

      delete org_invitation_path(org_slug: organization.slug, id: invitation.id)

      expect(response).to have_http_status(:not_found)
      expect(invitation.reload.state).to eq("pending")
    end

    it "404s reaching into another org's invitation", :negative do
      other_org = create(:organization, :with_owner)
      invitation = create(:invitation, organization: other_org)
      sign_in owner

      delete org_invitation_path(org_slug: organization.slug, id: invitation.id)

      expect(response).to have_http_status(:not_found)
      expect(invitation.reload.state).to eq("pending")
    end

    it "surfaces a failed revoke (already revoked) as a flash alert, not a crash", :negative do
      invitation = create(:invitation, :revoked, organization:)
      sign_in owner

      delete org_invitation_path(org_slug: organization.slug, id: invitation.id)

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(invitation.reload.state).to eq("revoked")
    end
  end

  describe "POST /o/:org_slug/invitations/:id/resend" do
    it "resends as an owner" do
      invitation = create(:invitation, organization:)
      sign_in owner

      perform_enqueued_jobs do
        post resend_org_invitation_path(org_slug: organization.slug, id: invitation.id)
      end

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(ActionMailer::Base.deliveries.sole.to).to eq([ invitation.email ])
    end

    it "404s for a non-owner", :negative do
      invitation = create(:invitation, organization:)
      sign_in create(:membership, organization:).user

      post resend_org_invitation_path(org_slug: organization.slug, id: invitation.id)

      expect(response).to have_http_status(:not_found)
    end

    it "surfaces a failed resend (already accepted) as a flash alert, not a crash", :negative do
      invitation = create(:invitation, :accepted, organization:)
      sign_in owner

      post resend_org_invitation_path(org_slug: organization.slug, id: invitation.id)

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end
end
