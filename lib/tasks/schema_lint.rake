# frozen_string_literal: true

# Schema hygiene (database-architecture plan_2): every _id column gets a
# real foreign key and an index. Runs in CI; self-strengthening — new
# tables are covered automatically.
namespace :db do
  desc "Fail if any _id column lacks a foreign key or an index"
  task schema_lint: :environment do
    connection = ActiveRecord::Base.connection
    skip_tables = %w[schema_migrations ar_internal_metadata]
    failures = []

    (connection.tables - skip_tables).each do |table|
      fk_columns = connection.foreign_keys(table).map { |fk| fk.options[:column] || "#{fk.to_table.to_s.singularize}_id" }
      indexed = connection.indexes(table).flat_map { |index| index.columns.first(1) }

      connection.columns(table).each do |column|
        next unless column.name.end_with?("_id")

        failures << "#{table}.#{column.name}: no foreign key" unless fk_columns.include?(column.name)
        failures << "#{table}.#{column.name}: no index" unless indexed.include?(column.name)
      end
    end

    abort(failures.map { |f| "db:schema_lint — #{f}" }.join("\n")) if failures.any?
    puts "db:schema_lint — every _id column has a foreign key and an index"
  end
end
