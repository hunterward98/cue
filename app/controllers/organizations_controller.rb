# frozen_string_literal: true

# The org switcher and front door: list your orgs, make a new one. Sits
# outside /o/:org_slug — the one legitimately cross-tenant user surface,
# hence the explicit without_tenant.
class OrganizationsController < InertiaController
  def index
    memberships = ActsAsTenant.without_tenant do
      Current.user.memberships.active.includes(:organization)
        .merge(Organization.kept).order("organizations.name")
    end

    render inertia: "organizations/index", props: {
      organizations: memberships.map do |membership|
        organization = membership.organization
        {
          name: organization.name,
          slug: organization.slug,
          owner: membership.owner?,
          board_owner: membership.board_owner?
        }
      end
    }
  end

  def new
    render inertia: "organizations/new"
  end

  def create
    result = Organizations::CreateWithOwner.call(
      user: Current.user,
      name: organization_params[:name].to_s,
      slug: organization_params[:slug].to_s
    )

    if result.success?
      redirect_to org_root_path(org_slug: result.organization.slug)
    else
      redirect_to new_organization_path, inertia: { errors: result.errors }
    end
  end

  private

  def organization_params
    params.permit(:name, :slug)
  end
end
