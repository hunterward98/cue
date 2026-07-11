class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      # citext: join links get typed by hand; "Acme" and "acme" must be the
      # same org. Immutable after creation (org plan_4 Q2, ratified).
      t.citext :slug, null: false
      # Documented shape in Organization::DEFAULT_SETTINGS; typed form
      # object arrives with org plan_4's settings surface.
      t.jsonb :settings, null: false, default: {}
      # Soft-delete forever (org plan_2 Q1, ratified): no purge job.
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :organizations, :slug, unique: true
    add_check_constraint :organizations,
      "slug ~ '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$' AND length(slug) BETWEEN 2 AND 40",
      name: "organizations_slug_format_check"
  end
end
