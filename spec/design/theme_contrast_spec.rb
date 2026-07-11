# frozen_string_literal: true

require "rails_helper"

# The theme contrast gate (theming plan_2): parses the REAL theme file and
# computes WCAG ratios, so a failing pair is a failing build — in both
# themes, including the color-coding set (the critique's addition: badges
# are where stark colors meet cream).
RSpec.describe "Theme contrast (WCAG AA)" do
  def tokens_file = Rails.root.join("app/frontend/entrypoints/tokens.css")

  # text on background, 4.5:1 (AA normal text)
  def text_pairs
    [
      %w[ink surface], %w[ink surface-raised],
      %w[ink-muted surface], %w[ink-muted surface-raised],
      %w[accent surface], %w[destructive surface],
      %w[accent-ink accent], %w[destructive-ink destructive],
      %w[accent-ink accent-hover], %w[destructive-ink destructive-hover],
      %w[success-ink success-surface], %w[danger-ink danger-surface],
      %w[success-ink surface], %w[danger-ink surface],
      *%w[scarlet ochre moss teal indigo plum].flat_map do |hue|
        [ [ "coding-#{hue}-ink", "coding-#{hue}-surface" ], [ "coding-#{hue}-ink", "surface" ] ]
      end
    ]
  end

  # non-text UI, 3:1 (focus rings, input borders)
  def ui_pairs
    [ %w[focus surface], %w[border-strong surface], %w[border-strong surface-raised] ]
  end

  def themes
    css = tokens_file.read
    light = css[/:root,\s*html\[data-theme='light'\]\s*\{(.*?)\}/m, 1]
    dark = css[/html\[data-theme='dark'\]\s*\{(.*?)\}/m, 1]
    { "light" => parse_tokens(light), "dark" => parse_tokens(dark) }
  end

  def parse_tokens(block)
    block.scan(/--([a-z0-9-]+):\s*(#\h{6})\s*;/).to_h
  end

  def relative_luminance(hex)
    r, g, b = hex.delete("#").scan(/../).map { |c| c.to_i(16) / 255.0 }
    lr, lg, lb = [ r, g, b ].map do |channel|
      channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4
    end
    (0.2126 * lr) + (0.7152 * lg) + (0.0722 * lb)
  end

  def contrast(hex_a, hex_b)
    la, lb = [ relative_luminance(hex_a), relative_luminance(hex_b) ].sort.reverse
    (la + 0.05) / (lb + 0.05)
  end

  def failures_for(pairs, minimum)
    themes.flat_map do |theme_name, tokens|
      pairs.filter_map do |foreground, background|
        fg = tokens.fetch(foreground) { raise "missing token --#{foreground} in #{theme_name}" }
        bg = tokens.fetch(background) { raise "missing token --#{background} in #{theme_name}" }
        ratio = contrast(fg, bg)
        next if ratio >= minimum

        format("%s: %s on %s = %.2f (needs %.1f)", theme_name, foreground, background, ratio, minimum)
      end
    end
  end

  it "keeps every text pair at or above 4.5:1 in both themes" do
    expect(failures_for(text_pairs, 4.5)).to be_empty
  end

  it "keeps focus rings and input borders at or above 3:1 in both themes" do
    expect(failures_for(ui_pairs, 3.0)).to be_empty
  end

  it "fails when a pair drops below AA — the gate itself is load-bearing", :negative do
    # Prove the math bites: near-identical colors must be reported.
    expect(contrast("#f6f1e5", "#fcf9f0")).to be < 1.2
  end
end
