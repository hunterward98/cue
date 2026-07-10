# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Security headers", type: :request do
  it "serves the strict CSP on every response" do
    get new_session_path

    csp = response.headers["Content-Security-Policy"]
    expect(csp).to include("default-src 'none'")
    expect(csp).to include("frame-ancestors 'none'")
    expect(csp).to include("script-src 'self' 'nonce-")
    expect(csp).to include("form-action 'self'")
  end

  it "keeps session cookies httponly and lax" do
    user = create(:user)
    sign_in user

    cookie = Array(response.headers["Set-Cookie"]).join("; ")
    expect(cookie).to include("httponly")
    expect(cookie.downcase).to include("samesite=lax")
  end

  it "publishes security.txt at the well-known path" do
    get "/.well-known/security.txt"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Contact:")
  end
end
