# frozen_string_literal: true

# Test-framework generator defaults (uuid pk type lives in
# uuid_v7_primary_keys.rb; the blocks are additive).
Rails.application.config.generators do |g|
  g.test_framework :rspec,
                   view_specs: false, # views are exercised through system specs
                   helper_specs: false,
                   routing_specs: false
  g.fixture_replacement :factory_bot, dir: "spec/factories"
  g.helper false
  g.assets false
end
