require "capybara/cuprite"

# Chrome for Testing lives under ~/.cache/puppeteer locally (installed via
# `pnpm dlx @puppeteer/browsers install chrome@stable`); CI images ship their
# own Chrome, which Ferrum autodetects when the glob finds nothing.
# CHROME_PATH overrides discovery either way.
chrome_path = ENV["CHROME_PATH"] ||
              Dir.glob(File.expand_path("~/.cache/puppeteer/chrome/*/chrome-linux64/chrome")).max

Capybara.register_driver(:cue_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: VIEWPORTS.fetch(:desktop),
    browser_path: chrome_path,
    browser_options: { "no-sandbox" => nil, "disable-gpu" => nil },
    process_timeout: 30,
    timeout: 15,
    js_errors: true, # a JS error is a failing test, not console noise
    headless: ENV.fetch("HEADLESS", "true") != "false"
  )
end

Capybara.default_max_wait_time = 5
Capybara.save_path = "tmp/capybara"
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :cue_cuprite
  end
end

RSpec.configure do |config|
  # System flows exercise real emails (verification codes); run jobs
  # inline so deliveries land synchronously in ActionMailer deliveries.
  config.around(:each, type: :system) do |example|
    previous = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    example.run
  ensure
    ActiveJob::Base.queue_adapter = previous
  end
end
