# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Theme switching", type: :system do
  def emulate_color_scheme(value)
    page.driver.browser.page.command(
      "Emulation.setEmulatedMedia",
      features: [ { name: "prefers-color-scheme", value: } ]
    )
  end

  def current_theme
    page.evaluate_script("document.documentElement.dataset.theme")
  end

  it "follows the OS preference before any choice is made" do
    with_each_viewport do
      emulate_color_scheme("dark")
      visit new_session_path
      expect(page).to have_css("h1", text: "Sign in")
      expect(current_theme).to eq("dark")

      emulate_color_scheme("light")
      visit new_session_path
      expect(current_theme).to eq("light")
    end
  end

  it "cycles the toggle, persists on the account, and survives reload" do
    with_each_viewport do |viewport|
      user = create(:user, email_address: "themer-#{viewport}@example.com")
      emulate_color_scheme("light")
      visit new_session_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: "a-long-enough-password"
      click_button "Sign in"
      expect(page).to have_css("h1", text: "Your organizations")

      click_button "Theme: system"
      expect(page).to have_button("Theme: light")
      expect(current_theme).to eq("light")

      click_button "Theme: light"
      expect(page).to have_button("Theme: dark")
      expect(current_theme).to eq("dark")

      # The choice must arrive server-side and win on a cold load —
      # the no-flash script, not React, applies it.
      expect(user.reload.theme_preference).to eq("dark")
      visit organizations_path
      expect(page).to have_css("h1", text: "Your organizations")
      expect(current_theme).to eq("dark")
    end
  end
end
