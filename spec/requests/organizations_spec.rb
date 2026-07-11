# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizations (switcher + creation)", type: :request do
  describe "GET /organizations" do
    it_behaves_like "a route requiring a verified user" do
      let(:perform_request) { get organizations_path }
    end

    it "lists only the caller's active memberships in kept orgs" do
      user = create(:user)
      mine = create(:organization, name: "Mine", slug: "mine")
      create(:membership, organization: mine, user:, owner: true)

      deactivated_org = create(:organization, slug: "left-behind")
      create(:membership, :deactivated, organization: deactivated_org, user:)

      discarded_org = create(:organization, :discarded, slug: "gone")
      create(:membership, organization: discarded_org, user:)

      create(:organization, :with_owner, slug: "not-mine")

      sign_in user
      get organizations_path

      expect_inertia.to render_component("organizations/index")
      rows = inertia.props.fetch(:organizations)
      expect(rows).to contain_exactly(
        { "name" => "Mine", "slug" => "mine", "owner" => true, "board_owner" => false }
      )
    end
  end

  describe "GET /organizations/new" do
    it_behaves_like "a route requiring a verified user" do
      let(:perform_request) { get new_organization_path }
    end

    it "renders the form" do
      sign_in create(:user)
      get new_organization_path
      expect_inertia.to render_component("organizations/new")
    end
  end

  describe "POST /organizations" do
    it_behaves_like "a route requiring a verified user" do
      let(:perform_request) { post organizations_path, params: { name: "X", slug: "x-office" } }
    end

    it "creates the org and lands on its home" do
      user = sign_in create(:user)

      post organizations_path, params: { name: "Riverside Dental", slug: "riverside" }

      expect(response).to redirect_to(org_root_path(org_slug: "riverside"))
      organization = Organization.find_by!(slug: "riverside")
      membership = ActsAsTenant.with_tenant(organization) { organization.memberships.sole }
      expect(membership.user).to eq(user)
      expect(membership.owner?).to be(true)
    end

    it "rejects an invalid slug with form errors, creating nothing", :negative do
      sign_in create(:user)

      post organizations_path, params: { name: "Riverside", slug: "Not A Slug" }

      expect(response).to redirect_to(new_organization_path)
      expect(Organization.count).to eq(0)
    end
  end
end
