# frozen_string_literal: true

# See Entitlements.warn_if_stub_in_production — the logic (and its tests)
# live in app/services; this is only the boot-time wiring.
Rails.application.config.after_initialize do
  Entitlements.warn_if_stub_in_production(Rails.env, Rails.logger)
end
