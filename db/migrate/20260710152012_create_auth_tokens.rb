class CreateAuthTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :auth_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :purpose, null: false
      # Secrets never stored in the clear: SHA-256 digests of the 6-digit
      # code and its magic-link twin (auth plan_2 token discipline).
      t.string :code_digest, null: false
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.integer :attempts_count, null: false, default: 0

      t.timestamps
    end
    add_index :auth_tokens, [ :user_id, :purpose ]
    add_index :auth_tokens, :token_digest, unique: true
    add_check_constraint :auth_tokens,
      "purpose IN ('email_verification', 'password_reset', 'login_code', 'second_factor')",
      name: "auth_tokens_purpose_check"
  end
end
