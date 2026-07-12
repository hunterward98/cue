require "chunky_png"

# Pixel-diffs a Capybara screenshot against a committed golden (theming
# plan_3). Deliberately dependency-light — pure-Ruby PNG decode, no
# native image libs — since screenshots only need to stay stable within
# a single Chrome-for-testing build (pinned via `pnpm dlx
# @puppeteer/browsers`) rendering self-hosted webfonts, the same build
# both locally and in CI. `UPDATE_GOLDENS=1` regenerates the goldens
# instead of comparing — a deliberate, reviewed diff, never automatic.
module VisualRegressionHelpers
  GOLDEN_DIR = Rails.root.join("spec/goldens/gallery")
  MAX_DIFFERING_PIXEL_RATIO = 0.01
  CHANNEL_TOLERANCE = 24

  def expect_gallery_visual_match(name, selector: "#gallery-root")
    golden_path = GOLDEN_DIR.join("#{name}.png")
    actual_path = Rails.root.join("tmp/capybara/gallery-#{name}.png")
    FileUtils.mkdir_p(actual_path.dirname)
    # React mounts async — save_screenshot has no auto-wait of its own,
    # so without this it can race a still-empty #app and 500 on a null
    # getBoundingClientRect.
    expect(page).to have_css(selector)
    page.save_screenshot(actual_path.to_s, selector:)

    if ENV["UPDATE_GOLDENS"]
      FileUtils.mkdir_p(golden_path.dirname)
      FileUtils.cp(actual_path, golden_path)
      return
    end

    unless golden_path.exist?
      raise "No golden for '#{name}' at #{golden_path}. Generate it with " \
            "UPDATE_GOLDENS=1 bundle exec rspec #{RSpec.current_example.metadata[:location]}"
    end

    golden = ChunkyPNG::Image.from_file(golden_path)
    actual = ChunkyPNG::Image.from_file(actual_path)

    if [ actual.width, actual.height ] != [ golden.width, golden.height ]
      raise "#{name}: golden is #{golden.width}x#{golden.height}, actual is " \
            "#{actual.width}x#{actual.height} — regenerate with UPDATE_GOLDENS=1"
    end

    differing_pixels = count_differing_pixels(golden, actual)
    ratio = differing_pixels.to_f / (golden.width * golden.height)

    expect(ratio).to(
      be <= MAX_DIFFERING_PIXEL_RATIO,
      "#{name}: #{(ratio * 100).round(2)}% of pixels differ from the golden " \
      "(allowed #{(MAX_DIFFERING_PIXEL_RATIO * 100).round}%) — review " \
      "#{actual_path}, then UPDATE_GOLDENS=1 to accept the change"
    )
  end

  private

  def count_differing_pixels(golden, actual)
    count = 0
    golden.height.times do |y|
      golden.width.times do |x|
        count += 1 if pixel_delta(golden[x, y], actual[x, y]) > CHANNEL_TOLERANCE
      end
    end
    count
  end

  def pixel_delta(a, b)
    a_bytes = ChunkyPNG::Color.to_truecolor_alpha_bytes(a)
    b_bytes = ChunkyPNG::Color.to_truecolor_alpha_bytes(b)
    a_bytes.zip(b_bytes).map { |x, y| (x - y).abs }.max
  end
end

RSpec.configure do |config|
  config.include VisualRegressionHelpers, type: :system
end
