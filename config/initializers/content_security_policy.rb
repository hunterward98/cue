# frozen_string_literal: true

# Strict CSP (auth plan_3). The full policy applies in production AND
# test — the system suite runs a real browser under the real policy, so
# an inline-script regression fails CI, not prod. Development relaxes
# only what Vite dev/HMR needs.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.script_src  :self
    policy.style_src   :self
    policy.img_src     :self, :data
    policy.font_src    :self
    policy.connect_src :self
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
  end

  if Rails.env.development?
    vite = "http://localhost:3036"
    vite_ws = "ws://localhost:3036"
    config.content_security_policy do |policy|
      policy.default_src :none
      policy.script_src  :self, :unsafe_inline, vite
      policy.style_src   :self, :unsafe_inline, vite
      policy.img_src     :self, :data
      policy.font_src    :self, vite
      policy.connect_src :self, vite, vite_ws
      policy.base_uri    :self
      policy.form_action :self
      policy.frame_ancestors :none
    end
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
