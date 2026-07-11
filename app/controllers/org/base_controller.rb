# frozen_string_literal: true

module Org
  # Everything under /o/:org_slug inherits from here: authenticated,
  # verified (ApplicationController gates), and org-scoped.
  class BaseController < InertiaController
    include OrganizationScoping
  end
end
