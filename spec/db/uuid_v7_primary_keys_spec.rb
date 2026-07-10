# frozen_string_literal: true

require "rails_helper"

# Proves the UUIDv7 pk convention end-to-end (ADR 0003) against a real
# table created and dropped inside the example's transaction: generators
# and hand-written migrations alike get a Postgres-minted, time-ordered id.
RSpec.describe "UUIDv7 primary keys" do
  let(:connection) { ActiveRecord::Base.connection }

  let(:probe_model) do
    Class.new(ApplicationRecord) { self.table_name = "uuid_probes" }
  end

  around do |example|
    connection.create_table(:uuid_probes, id: :uuid) { |t| t.string :name }
    example.run
  ensure
    connection.drop_table(:uuid_probes, if_exists: true)
  end

  it "defaults uuid primary keys to the database's uuidv7() function" do
    id_column = connection.columns(:uuid_probes).find { |column| column.name == "id" }

    expect(id_column.sql_type).to eq("uuid")
    expect(id_column.default_function).to eq("uuidv7()")
  end

  it "generates time-ordered ids so consecutive inserts sort by creation" do
    first = probe_model.create!(name: "first")
    second = probe_model.create!(name: "second")

    expect([ first.id, second.id ].sort).to eq([ first.id, second.id ])
  end

  it "rejects an explicit nil id rather than silently skipping the default", :negative do
    insert = lambda do
      # Savepoint keeps the expected DB error from poisoning the example's
      # wrapping transaction.
      connection.transaction(requires_new: true) do
        connection.execute("INSERT INTO uuid_probes (id, name) VALUES (NULL, 'nope')")
      end
    end

    expect { insert.call }.to raise_error(ActiveRecord::NotNullViolation)
  end
end
