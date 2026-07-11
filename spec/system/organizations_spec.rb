# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizations", type: :system do
  it "creates an org from the switcher and lands inside it" do
    with_each_viewport do |viewport|
      user = create(:user, email_address: "founder-#{viewport}@example.com")

      visit new_session_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: "a-long-enough-password"
      click_button "Sign in"

      expect(page).to have_css("h1", text: "Your organizations")
      expect(page).to have_text("You don't belong to any organization yet")

      click_link "New organization"
      fill_in "Organization name", with: "Riverside Dental #{viewport}"
      # The slug auto-suggests from the name; accept it as-is.
      expect(find_field("Slug (in your join links — permanent)").value)
        .to eq("riverside-dental-#{viewport}")
      click_button "Create organization"

      expect(page).to have_css("h1", text: "Riverside Dental #{viewport}")
      expect(page).to have_text("You own this org.")

      click_link "Cue" # wordmark → back to the switcher
      expect(page).to have_css("h1", text: "Your organizations")
      expect(page).to have_text("Riverside Dental #{viewport}")
      expect(page).to have_text("Owner")
    end
  end
end
