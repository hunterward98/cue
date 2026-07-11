# frozen_string_literal: true

# The tier-limit seam (org plan_2). Everything that gates on plan tier —
# seat limits, board-owner counts, premium features — asks this module and
# nothing else, so billing plan_2 can swap in the real subscription-backed
# resolver by changing exactly one method.
#
# Until then this is a STUB: premium-everything in development, tier
# switchable in tests via the `with_tier` helper.
module Entitlements
  TIERS = {
    basic: { members: 15, board_owners: 2, features: [] },
    premium: { members: 200, board_owners: 10,
               features: %i[custom_theme cue_links custom_fields] },
    enterprise: { members: nil, board_owners: nil,
                  features: %i[custom_theme cue_links custom_fields] }
  }.freeze

  # Test-only dial (see spec/support/entitlements.rb). A class attribute,
  # not a thread-local, so the Capybara server thread sees it too.
  mattr_accessor :stubbed_tier, default: :premium

  def self.for(_organization) = StubResolver.new

  def self.stub? = true

  # Called from an initializer: a stub silently deciding production
  # gating is the failure mode (plan_2 critique), so it screams at boot.
  def self.warn_if_stub_in_production(env, logger)
    return unless env.production? && stub?

    logger.error(
      "Entitlements is still the premium-everything STUB — no tier is " \
      "actually enforced. Billing plan_2 must replace the resolver."
    )
  end

  class StubResolver
    def allows?(feature) = tier.fetch(:features).include?(feature)

    # nil means unlimited.
    def limit_for(metric) = tier.fetch(metric)

    def within_limit?(metric, count)
      limit = limit_for(metric)
      limit.nil? || count <= limit
    end

    private

    def tier = TIERS.fetch(Entitlements.stubbed_tier)
  end
end
