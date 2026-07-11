# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Theme preferences", type: :request do
  it_behaves_like "a route requiring a verified user" do
    let(:perform_request) { patch theme_preference_path, params: { theme: "dark" } }
  end

  it "persists the choice on the account" do
    user = sign_in create(:user)

    patch theme_preference_path, params: { theme: "dark" }

    expect(response).to have_http_status(:redirect)
    expect(user.reload.theme_preference).to eq("dark")
  end

  it "rejects values outside system/light/dark", :negative do
    user = sign_in create(:user)

    patch theme_preference_path, params: { theme: "papyrus" }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(user.reload.theme_preference).to eq("system")
  end
end
