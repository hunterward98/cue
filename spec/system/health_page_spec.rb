# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health page", type: :system do
  it "renders the Rails → Inertia → React → Tailwind → DB round-trip" do
    with_each_viewport do |viewport|
      visit full_health_check_path

      # React mounted and rendered the Inertia props.
      expect(page).to have_css("h1", text: "Cue system health")
      expect(page).to have_content("Every layer is answering.")

      # The DB answered: the page shows a UUID minted by Postgres uuidv7().
      expect(page).to have_content(/uuidv7\(\) → \h{8}-\h{4}-7\h{3}/)

      # Tailwind actually applied — computed style, not just class names.
      font_weight = page.evaluate_script(
        "getComputedStyle(document.querySelector('h1')).fontWeight"
      )
      expect(font_weight).to eq("600"), "expected Tailwind styling on h1 at #{viewport} viewport"
    end
  end
end
