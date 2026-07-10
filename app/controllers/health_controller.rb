# frozen_string_literal: true

# Deep health check: proves the whole Rails → Inertia → React → Tailwind → DB
# round-trip (foundation plan_2). The generated /up route stays as the cheap
# liveness probe for load balancers; this page is for humans and deploy smoke
# tests, and returns 503 when any layer is unhappy.
class HealthController < InertiaController
  def full
    checks = [
      { label: "Rails", value: Rails.version, ok: true },
      { label: "Ruby", value: RUBY_VERSION, ok: true },
      { label: "Inertia Rails", value: InertiaRails::VERSION, ok: true },
      database_check
    ]

    render inertia: "health/full",
           props: { checks: checks, generated_at: Time.current.iso8601 },
           status: checks.all? { |check| check[:ok] } ? :ok : :service_unavailable
  end

  private

  # One query proves both connectivity and the PG18 uuidv7() function our
  # primary-key convention depends on.
  def database_check
    connection = ActiveRecord::Base.connection
    uuid = connection.select_value("SELECT uuidv7()")
    server_version = connection.select_value("SHOW server_version")
    { label: "Postgres #{server_version}", value: "uuidv7() → #{uuid}", ok: !uuid.nil? }
  rescue ActiveRecord::ActiveRecordError, PG::Error => error
    { label: "Postgres", value: error.class.name, ok: false }
  end
end
