# Master plan: mobile-first. Every user-facing system flow runs at both
# viewports via with_each_viewport; the Cue/SystemSpecViewportMatrix cop
# fails any system spec that skips it.
VIEWPORTS = {
  mobile: [ 375, 812 ],
  desktop: [ 1280, 800 ]
}.freeze

module ViewportHelpers
  # Runs the block once per viewport, resizing first. Yields the viewport
  # name so expectations can differ (mobile nav vs desktop nav).
  def with_each_viewport
    VIEWPORTS.each do |name, (width, height)|
      # Each viewport pass is a fresh browser: cookies and session state
      # from the previous pass would otherwise leak into this one.
      Capybara.reset_session!
      page.driver.resize(width, height)
      yield name
    end
  end
end

RSpec.configure do |config|
  config.include ViewportHelpers, type: :system
end
