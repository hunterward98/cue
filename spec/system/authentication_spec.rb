# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication flows", type: :system do
  def latest_code
    ActionMailer::Base.deliveries.last.subject[/\d{6}/]
  end

  it "signs up, verifies by emailed code, signs out, and signs back in" do
    with_each_viewport do |viewport|
      email = "flow-#{viewport}@example.com"

      visit new_registration_path
      fill_in "Email", with: email
      fill_in "Password (12+ characters)", with: "a-long-enough-password"
      click_button "Create account"

      expect(page).to have_css("h1", text: "Check your inbox")
      fill_in "Verification code", with: latest_code
      click_button "Verify"
      expect(page).to have_css("h1", text: "Cue system health") # verified users land on root

      visit user_sessions_path
      expect(page).to have_css("h1", text: "Your sessions")
      click_button "Sign out"
      expect(page).to have_css("h1", text: "Sign in")
      # The flash pipeline end-to-end: Rails flash → Inertia page → banner.
      expect(page).to have_text("Signed out. The cues will wait.")

      fill_in "Email", with: email
      fill_in "Password", with: "a-long-enough-password"
      click_button "Sign in"
      expect(page).to have_css("h1", text: "Cue system health") # login landed

      visit user_sessions_path
      expect(page).to have_css("h1", text: "Your sessions")
    end
  end

  it "walls an unverified account off from the app", :negative do
    with_each_viewport do |viewport|
      email = "walled-#{viewport}@example.com"

      visit new_registration_path
      fill_in "Email", with: email
      fill_in "Password (12+ characters)", with: "a-long-enough-password"
      click_button "Create account"

      visit user_sessions_path
      expect(page).to have_css("h1", text: "Sign in")

      fill_in "Email", with: email
      fill_in "Password", with: "a-long-enough-password"
      click_button "Sign in"
      expect(page).to have_css("h1", text: "Check your inbox")
    end
  end

  it "signs in passwordless users with an emailed code" do
    with_each_viewport do |viewport|
      user = create(:user, :passwordless, email_address: "codes-#{viewport}@example.com")

      visit new_session_path
      fill_in "Email", with: user.email_address
      click_button "Email me a sign-in code instead"

      expect(page).to have_css("h1", text: "Enter your sign-in code")
      fill_in "Sign-in code", with: latest_code
      click_button "Sign in"
      expect(page).to have_css("h1", text: "Cue system health") # login landed

      visit user_sessions_path
      expect(page).to have_css("h1", text: "Your sessions")
    end
  end
end
