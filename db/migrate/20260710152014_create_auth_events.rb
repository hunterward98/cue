class CreateAuthEvents < ActiveRecord::Migration[8.1]
  def change
    # Append-only audit log: no updated_at on purpose; the model is
    # readonly after create. The action list grows with features, so it is
    # validated in the model rather than pinned by a DB check constraint.
    create_table :auth_events, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid
      t.string :action, null: false
      t.string :ip_address
      t.string :user_agent
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end
    add_index :auth_events, :action
  end
end
