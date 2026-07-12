# Drives the OS-level `prefers-color-scheme` media feature so specs can
# exercise the app's no-flash script without needing a signed-in user.
module ColorSchemeHelpers
  def emulate_color_scheme(value)
    page.driver.browser.page.command(
      "Emulation.setEmulatedMedia",
      features: [ { name: "prefers-color-scheme", value: } ]
    )
  end

  def current_theme
    page.evaluate_script("document.documentElement.dataset.theme")
  end
end

RSpec.configure do |config|
  config.include ColorSchemeHelpers, type: :system
end
