# frozen_string_literal: true

# Auth-endpoint throttling (auth plan_3). Store decision (critique): an
# unconfigured store can silently no-op, so it's set explicitly.
# MemoryStore is per-process — effective limits multiply by puma worker
# count (~3 in production), and the numbers below are chosen with that
# math in mind. Swap to Solid Cache only if counter accuracy ever earns
# its Postgres write cost.
class Rack::Attack
  AUTH_PATHS = %w[/session /registration /login_code /passwords /email_verification /unlock].freeze

  def self.auth_request?(request)
    (request.post? || request.patch?) && AUTH_PATHS.any? { |path| request.path.start_with?(path) }
  end

  self.cache.store = ActiveSupport::Cache::MemoryStore.new

  safelist("health checks") { |request| request.path == "/up" || request.path == "/up/full" }

  throttle("auth/ip", limit: 10, period: 60) do |request|
    request.ip if auth_request?(request)
  end

  throttle("auth/email", limit: 5, period: 60) do |request|
    if auth_request?(request)
      request.params["email_address"].to_s.strip.downcase.presence
    end
  end

  self.throttled_responder = lambda do |_request|
    [ 429, { "content-type" => "text/plain" },
     [ "Easy there. Too many attempts — wait a minute and try again.\n" ] ]
  end
end

# Individual specs flip this on with a fresh store to prove the throttles
# actually trip (the negative test the critique demanded).
Rack::Attack.enabled = !Rails.env.test?
