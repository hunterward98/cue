class AddThemePreferenceToUsers < ActiveRecord::Migration[8.1]
  # Required for the two-step constraint validation below.
  disable_ddl_transaction!

  def change
    # "system" follows prefers-color-scheme; explicit light/dark override
    # it (theming plan_2). Pre-login devices use localStorage instead.
    add_column :users, :theme_preference, :string, null: false, default: "system"
    # Two-step per strong_migrations: NOT VALID skips the table scan under
    # a lock, the separate validate checks existing rows without one.
    add_check_constraint :users,
      "theme_preference IN ('system', 'light', 'dark')",
      name: "users_theme_preference_check", validate: false
    validate_check_constraint :users, name: "users_theme_preference_check"
  end
end
