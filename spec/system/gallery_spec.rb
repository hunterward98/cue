# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Component gallery", type: :system do
  it "has no automatic accessibility violations in either theme" do
    with_each_viewport do
      %w[light dark].each do |theme|
        emulate_color_scheme(theme)
        visit gallery_path
        expect(current_theme).to eq(theme)
        assert_no_axe_violations
      end
    end
  end

  it "matches the committed goldens for every theme and viewport" do
    with_each_viewport do |viewport|
      %w[light dark].each do |theme|
        emulate_color_scheme(theme)
        visit gallery_path
        expect(current_theme).to eq(theme)
        expect_gallery_visual_match("#{viewport}-#{theme}")
      end
    end
  end
end
