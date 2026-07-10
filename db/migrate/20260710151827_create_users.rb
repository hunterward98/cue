class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "citext"

    create_table :users, id: :uuid do |t|
      t.citext :email_address, null: false
      # NULL for passwordless-mode users (ratified A1: login mode is a
      # per-user choice made at signup).
      t.string :password_digest
      t.datetime :verified_at
      t.string :login_mode, null: false, default: "password"
      t.boolean :staff, null: false, default: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_check_constraint :users, "login_mode IN ('password', 'passwordless')", name: "users_login_mode_check"
  end
end
