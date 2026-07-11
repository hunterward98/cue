# frozen_string_literal: true

# Dials the Entitlements stub to a tier for a block (org plan_2):
#
#   with_tier :basic do
#     expect(result.error).to match(/seats/)
#   end
module EntitlementsHelpers
  def with_tier(tier)
    previous = Entitlements.stubbed_tier
    Entitlements.stubbed_tier = tier
    yield
  ensure
    Entitlements.stubbed_tier = previous
  end
end

RSpec.configure do |config|
  config.include EntitlementsHelpers

  # A leaked dial would corrupt unrelated examples; reset defensively.
  config.after { Entitlements.stubbed_tier = :premium }
end
