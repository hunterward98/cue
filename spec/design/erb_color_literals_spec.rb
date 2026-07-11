# frozen_string_literal: true

require "rails_helper"

# The token law for server-rendered ERB (theming plan_2): no color
# literals outside the mailer views. Emails are the sanctioned exception —
# clients need inline styles, so mailer templates carry light-theme
# literal values by design (notifications plan_2 owns that layout).
RSpec.describe "ERB color literals" do
  def mailer_views = %r{app/views/(auth_mailer|layouts/mailer)}
  def color_literal = /#\h{3,8}\b|rgb\(|rgba\(|hsl\(|oklch\(|style="[^"]*color/

  it "keeps hex/rgb/hsl literals out of non-mailer views" do
    offenders = Rails.root.glob("app/views/**/*.erb").filter_map do |path|
      relative = path.relative_path_from(Rails.root).to_s
      next if relative.match?(mailer_views)

      matches = path.read.scan(color_literal)
      "#{relative}: #{matches.uniq.join(", ")}" if matches.any?
    end

    expect(offenders).to be_empty, offenders.join("\n")
  end
end
