# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health", type: :request do
  describe "GET /up/full" do
    it "reports every layer green, including a Postgres-minted UUIDv7" do
      get full_health_check_path

      expect(response).to have_http_status(:ok)
      expect_inertia.to render_component("health/full")

      checks = inertia.props.fetch(:checks)
      expect(checks).to all(include(ok: true))
      expect(checks.map { |check| check.fetch(:label) })
        .to include("Rails", "Ruby", "Inertia Rails", /\APostgres/)

      db_check = checks.last
      expect(db_check.fetch(:value)).to match(/\Auuidv7\(\) → \h{8}-\h{4}-7\h{3}-\h{4}-\h{12}\z/)
    end

    it "fails the database check with a 503 when Postgres is unreachable", :negative do
      allow(ActiveRecord::Base.connection).to receive(:select_value)
        .and_raise(PG::ConnectionBad, "boom")

      get full_health_check_path

      expect(response).to have_http_status(:service_unavailable)
      db_check = inertia.props.fetch(:checks).last
      expect(db_check).to include(ok: false, value: "PG::ConnectionBad")
    end
  end

  describe "GET /" do
    it "serves the health page as the temporary root" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect_inertia.to render_component("health/full")
    end
  end
end
