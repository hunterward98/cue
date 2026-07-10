# frozen_string_literal: true

require "rails_helper"

# Self-strengthening tenancy guard (database-architecture plans 2–3):
# any table that carries organization_id — present or future — must
# foreign-key it, index it, and reject NULLs. New tenant tables are
# covered the moment they're migrated, with no spec changes.
RSpec.describe "Tenant schema conformance" do
  let(:connection) { ActiveRecord::Base.connection }

  let(:tenant_tables) do
    (connection.tables - %w[schema_migrations ar_internal_metadata organizations])
      .select { |table| connection.columns(table).any? { |column| column.name == "organization_id" } }
  end

  it "gives every tenant table a NOT NULL organization_id with FK and index" do
    offenders = tenant_tables.flat_map do |table|
      column = connection.columns(table).find { |c| c.name == "organization_id" }
      has_fk = connection.foreign_keys(table).any? { |fk| fk.to_table == "organizations" }
      has_index = connection.indexes(table).any? { |index| index.columns.include?("organization_id") }

      [
        (column.null ? "#{table}.organization_id allows NULL" : nil),
        (has_fk ? nil : "#{table}.organization_id has no FK to organizations"),
        (has_index ? nil : "#{table}.organization_id is unindexed")
      ].compact
    end

    expect(offenders).to be_empty, offenders.join("\n")
  end
end
