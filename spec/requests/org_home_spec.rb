# frozen_string_literal: true

require "rails_helper"

# The tenancy walls (org plan_2): everything under /o/:org_slug resolves
# through an active membership or 404s — never 403, which would confirm
# the org exists.
RSpec.describe "Org home", type: :request do
  let(:organization) { create(:organization, name: "Acme", slug: "acme") }

  it_behaves_like "a route requiring a verified user" do
    let(:perform_request) { get org_root_path(org_slug: organization.slug) }
  end

  it "shows the org to an active member with their roles" do
    user = create(:user)
    create(:membership, organization:, user:, owner: true, board_owner: true)

    sign_in user
    get org_root_path(org_slug: "acme")

    expect_inertia.to render_component("org/home")
    expect(inertia.props.fetch(:organization)).to eq({ "name" => "Acme", "slug" => "acme" })
    expect(inertia.props.fetch(:membership)).to eq({ "owner" => true, "board_owner" => true })
  end

  it "404s a non-member — indistinguishable from a nonexistent org", :negative do
    create(:membership, :owner, organization:)
    sign_in create(:user)

    get org_root_path(org_slug: "acme")
    membership_missing = response.status

    get org_root_path(org_slug: "never-existed")
    org_missing = response.status

    expect(membership_missing).to eq(404)
    expect(org_missing).to eq(404)
  end

  it "404s a deactivated member immediately", :negative do
    user = create(:user)
    create(:membership, :owner, organization:)
    membership = create(:membership, organization:, user:)
    sign_in user

    get org_root_path(org_slug: "acme")
    expect(response).to have_http_status(:ok)

    Memberships::Deactivate.call(membership:)
    get org_root_path(org_slug: "acme")
    expect(response).to have_http_status(:not_found)
  end

  it "404s a pending join request — asking is not belonging", :negative do
    user = create(:user)
    create(:membership, :pending, organization:, user:)

    sign_in user
    get org_root_path(org_slug: "acme")

    expect(response).to have_http_status(:not_found)
  end

  it "404s every member of a discarded org", :negative do
    user = create(:user)
    create(:membership, organization:, user:, owner: true)
    organization.discard!

    sign_in user
    get org_root_path(org_slug: "acme")

    expect(response).to have_http_status(:not_found)
  end

  it "404s support staff without a membership — the flag grants no org access", :negative do
    create(:membership, :owner, organization:)

    sign_in create(:user, :staff)
    get org_root_path(org_slug: "acme")

    expect(response).to have_http_status(:not_found)
  end

  it "404s malformed slugs at the routing layer", :negative do
    sign_in create(:user)

    get "/o/Not%20A%20Slug"

    expect(response).to have_http_status(:not_found)
  end
end
