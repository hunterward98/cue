# frozen_string_literal: true

module AuthenticationHelpers
  # Request-spec sign-in through the real endpoint — no backdoors, so the
  # login path itself stays load-bearing in every spec that uses this.
  def sign_in(user, password: "a-long-enough-password")
    post session_path, params: { email_address: user.email_address, password: }
    user
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
