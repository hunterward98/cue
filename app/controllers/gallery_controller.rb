# frozen_string_literal: true

# The internal component gallery (theming plan_3): dev workbench,
# screenshot target for visual goldens, and the surface where taste
# decisions get judged. Never ships to production — the route constraint
# 404s it there (negative-tested).
class GalleryController < InertiaController
  allow_unauthenticated_access

  def show
    render inertia: "gallery/show"
  end
end
