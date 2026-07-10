class AddLockoutToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :failed_login_attempts, :integer, null: false, default: 0
    add_column :users, :locked_at, :datetime

    # New token purpose for unlock links. Pre-production, so swapping the
    # constraint in place is safe (no traffic, tiny table).
    safety_assured do
      remove_check_constraint :auth_tokens, name: "auth_tokens_purpose_check"
      add_check_constraint :auth_tokens,
        "purpose IN ('email_verification', 'password_reset', 'login_code', 'second_factor', 'unlock')",
        name: "auth_tokens_purpose_check"
    end
  end
end
