# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Gallery", type: :request do
  describe "GET /gallery" do
    it "renders the component gallery outside production" do
      get "/gallery"

      expect(response).to have_http_status(:ok)
      expect_inertia.to render_component("gallery/show")
    end

    it "404s in production so the dev workbench never ships", :negative do
      allow(Rails.env).to receive(:production?).and_return(true)

      get "/gallery"

      expect(response).to have_http_status(:not_found)
    end
  end
end
