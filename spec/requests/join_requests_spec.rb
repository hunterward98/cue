# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Join requests", type: :request do
  let(:organization) { create(:organization, :with_owner) }

  describe "GET /join/:org_slug" do
    it "shows the request form for a signed-in non-member" do
      sign_in create(:user)
      get join_organization_path(org_slug: organization.slug)

      expect_inertia.to render_component("org/join")
      expect(inertia.props.fetch(:status)).to eq("none")
    end

    it "redirects an already-active member straight into the org" do
      user = create(:user)
      ActsAsTenant.with_tenant(organization) { create(:membership, organization:, user:) }
      sign_in user

      get join_organization_path(org_slug: organization.slug)

      expect(response).to redirect_to(org_root_path(org_slug: organization.slug))
    end

    it "shows pending status for an outstanding join request" do
      user = create(:user)
      ActsAsTenant.with_tenant(organization) { create(:membership, :pending, organization:, user:) }
      sign_in user

      get join_organization_path(org_slug: organization.slug)

      expect(inertia.props.fetch(:status)).to eq("pending_approval")
    end

    it "shows a neutral status for a deactivated member rather than self-service reactivating them", :negative do
      user = create(:user)
      ActsAsTenant.with_tenant(organization) { create(:membership, :deactivated, organization:, user:) }
      sign_in user

      get join_organization_path(org_slug: organization.slug)

      expect(inertia.props.fetch(:status)).to eq("deactivated")
    end

    it "sends a signed-out visitor to sign in first, remembering where they were headed" do
      get join_organization_path(org_slug: organization.slug)
      expect(response).to redirect_to(new_session_path)
    end

    it "treats a disabled join link the same as an unknown slug — no oracle", :negative do
      organization.update!(settings: organization.settings.merge("join_link_enabled" => false))
      sign_in create(:user)

      get join_organization_path(org_slug: organization.slug)
      disabled_body = response.location

      get join_organization_path(org_slug: "does-not-exist")
      unknown_body = response.location

      expect(disabled_body).to eq(unknown_body)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /join/:org_slug" do
    it "creates a pending_approval membership for a signed-in non-member" do
      user = create(:user)
      sign_in user

      post join_organization_path(org_slug: organization.slug)

      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.find_by(user:) }
      expect(membership.state).to eq("pending_approval")
      expect(response).to redirect_to(join_organization_path(org_slug: organization.slug))
    end

    it "does not create a second row for someone who already requested", :negative do
      user = create(:user)
      ActsAsTenant.with_tenant(organization) { create(:membership, :pending, organization:, user:) }
      sign_in user

      expect do
        post join_organization_path(org_slug: organization.slug)
      end.not_to(change { ActsAsTenant.with_tenant(organization) { organization.memberships.count } })
    end

    it "surfaces a failed enroll as a flash alert instead of a crash", :negative do
      # The only realistic way Enroll fails here is a same-user double
      # request racing past the existing-membership guard — simulate the
      # failure directly rather than trying to win that race in a test.
      user = create(:user)
      sign_in user
      allow(Memberships::Enroll).to receive(:call)
        .and_return(Memberships::Result.new(membership: nil, error: "already been taken"))

      post join_organization_path(org_slug: organization.slug)

      expect(response).to redirect_to(join_organization_path(org_slug: organization.slug))
    end

    it "treats an unavailable join link the same on POST as on GET", :negative do
      sign_in create(:user)
      post join_organization_path(org_slug: "does-not-exist")
      expect(response).to redirect_to(root_path)
    end

    it "redirects signed-out visitors to sign in instead of creating anything", :negative do
      post join_organization_path(org_slug: organization.slug)

      expect(response).to redirect_to(new_session_path)
      expect(ActsAsTenant.with_tenant(organization) { organization.memberships.count }).to eq(1) # just the owner
    end
  end

  describe "full loop: signing in mid-flow lands back on the join page" do
    it "returns to the join request after login" do
      user = create(:user, password: "a-long-enough-password")

      get join_organization_path(org_slug: organization.slug)
      post session_path, params: { email_address: user.email_address, password: "a-long-enough-password" }

      expect(response).to redirect_to(join_organization_path(org_slug: organization.slug))
    end
  end
end
