# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Org members", type: :request do
  let(:organization) { create(:organization) }
  let(:owner_membership) { create(:membership, :owner, organization:) }
  let(:owner) { owner_membership.user }

  describe "GET /o/:org_slug/members" do
    it "renders the roster for an owner" do
      create(:invitation, organization:)
      requester = create(:membership, organization:).user
      sign_in owner

      get org_members_path(org_slug: organization.slug)

      expect_inertia.to render_component("org/members/index")
      emails = inertia.props.fetch(:members).map { |m| m.fetch(:email) }
      expect(emails).to contain_exactly(owner.email_address, requester.email_address)
      expect(inertia.props.fetch(:invitations).length).to eq(1)
    end

    it "404s for a non-owner, not 403", :negative do
      sign_in create(:membership, organization:).user
      get org_members_path(org_slug: organization.slug)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /o/:org_slug/members/:id" do
    it "changes roles as an owner" do
      requester = create(:membership, organization:)
      sign_in owner

      patch org_member_path(org_slug: organization.slug, id: requester.id), params: { board_owner: "true" }

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(requester.reload.board_owner?).to be(true)
    end

    it "treats an absent checkbox as false, not a validation crash" do
      board_owner_membership = create(:membership, :board_owner, organization:)
      sign_in owner

      patch org_member_path(org_slug: organization.slug, id: board_owner_membership.id), params: {}

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      expect(board_owner_membership.reload.board_owner?).to be(false)
    end

    it "refuses to strip the last owner, surfacing the guard as a flash alert", :negative do
      sign_in owner

      patch org_member_path(org_slug: organization.slug, id: owner_membership.id), params: { owner: "false" }

      expect(response).to redirect_to(org_members_path(org_slug: organization.slug))
      follow_redirect!
      expect(response.body).to include("at least one active owner")
      expect(owner_membership.reload.owner?).to be(true)
    end

    it "404s for a non-owner", :negative do
      requester = create(:membership, organization:)
      sign_in create(:membership, organization:).user

      patch org_member_path(org_slug: organization.slug, id: requester.id), params: { board_owner: "true" }

      expect(response).to have_http_status(:not_found)
      expect(requester.reload.board_owner?).to be(false)
    end
  end

  describe "PATCH /o/:org_slug/members/:id/activate" do
    it "approves a join request" do
      pending_request = create(:membership, :pending, organization:)
      sign_in owner

      patch activate_org_member_path(org_slug: organization.slug, id: pending_request.id)

      expect(pending_request.reload.state).to eq("active")
    end

    it "reactivates a deactivated member" do
      deactivated = create(:membership, :deactivated, organization:)
      sign_in owner

      patch activate_org_member_path(org_slug: organization.slug, id: deactivated.id)

      expect(deactivated.reload.state).to eq("active")
    end

    it "rejects approval past the seat limit, leaving the request pending", :negative do
      create_list(:membership, 15, organization:)
      pending_request = create(:membership, :pending, organization:)
      sign_in owner

      with_tier :basic do
        patch activate_org_member_path(org_slug: organization.slug, id: pending_request.id)
      end

      expect(pending_request.reload.state).to eq("pending_approval")
    end

    it "404s for a non-owner", :negative do
      pending_request = create(:membership, :pending, organization:)
      sign_in create(:membership, organization:).user

      patch activate_org_member_path(org_slug: organization.slug, id: pending_request.id)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /o/:org_slug/members/:id/deactivate" do
    it "deactivates an active member" do
      requester = create(:membership, organization:)
      sign_in owner

      patch deactivate_org_member_path(org_slug: organization.slug, id: requester.id)

      expect(requester.reload.state).to eq("deactivated")
    end

    it "refuses to deactivate the last active owner", :negative do
      sign_in owner

      patch deactivate_org_member_path(org_slug: organization.slug, id: owner_membership.id)

      expect(owner_membership.reload.state).to eq("active")
    end
  end

  describe "DELETE /o/:org_slug/members/:id" do
    it "denies a join request, destroying the row" do
      pending_request = create(:membership, :pending, organization:)
      sign_in owner

      delete org_member_path(org_slug: organization.slug, id: pending_request.id)

      expect(ActsAsTenant.with_tenant(organization) { Membership.exists?(pending_request.id) }).to be(false)
    end

    it "refuses to deny an active membership", :negative do
      requester = create(:membership, organization:)
      sign_in owner

      delete org_member_path(org_slug: organization.slug, id: requester.id)

      expect(requester.reload).to be_persisted
      expect(requester.reload.state).to eq("active")
    end

    it "404s for a non-owner", :negative do
      pending_request = create(:membership, :pending, organization:)
      sign_in create(:membership, organization:).user

      delete org_member_path(org_slug: organization.slug, id: pending_request.id)

      expect(response).to have_http_status(:not_found)
    end
  end
end
