# frozen_string_literal: true

# Resolves /o/:org_slug into Current.organization + Current.membership and
# sets the acts_as_tenant tenant for the request (ADR 0010). Anything that
# doesn't resolve — unknown slug, discarded org, no membership, inactive
# membership, staff flag without a membership — raises RecordNotFound and
# renders 404: never 403, which would confirm the org exists.
module OrganizationScoping
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  private

  def set_current_organization
    organization = Organization.kept.find_by!(slug: params[:org_slug])
    membership = ActsAsTenant.with_tenant(organization) do
      organization.memberships.active.find_by!(user: Current.user)
    end

    Current.organization = organization
    Current.membership = membership
    ActsAsTenant.current_tenant = organization
  end
end
