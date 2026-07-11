# frozen_string_literal: true

module Org
  # The org landing page. A placeholder surface until cues land — its real
  # job today is proving the tenancy wiring end-to-end.
  class HomeController < BaseController
    def show
      render inertia: "org/home", props: {
        organization: {
          name: Current.organization.name,
          slug: Current.organization.slug
        },
        membership: {
          owner: Current.membership.owner?,
          board_owner: Current.membership.board_owner?
        }
      }
    end
  end
end
