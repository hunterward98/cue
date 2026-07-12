# frozen_string_literal: true

module Org
  # Everything under /o/:org_slug inherits from here: authenticated,
  # verified (ApplicationController gates), and org-scoped.
  class BaseController < InertiaController
    include OrganizationScoping

    private

    # Owner-only surfaces (invitations, member management): same 404,
    # not 403, philosophy as OrganizationScoping — a same-org requester
    # gets no signal that an owner-only route exists at all.
    def require_owner!
      raise ActiveRecord::RecordNotFound unless Current.membership.owner?
    end
  end
end
