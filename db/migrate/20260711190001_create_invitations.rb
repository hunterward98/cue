class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :inviter, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.citext :email, null: false
      # Same two-boolean role shape as Membership (ADR 0012) — the
      # invitation carries the role the invitee will get on acceptance.
      t.boolean :owner, null: false, default: false
      t.boolean :board_owner, null: false, default: false
      # Hashed, not stored in the clear (auth plan_2 token discipline) —
      # a single magic-link token, no typed code: acceptance is always a
      # one-tap-from-email action, never cross-device.
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.string :state, null: false, default: "pending"
      t.timestamps
    end
    add_index :invitations, :token_digest, unique: true
    # A resend reuses this row (new token, same email) instead of
    # creating a second one, so "at most one pending invite per email"
    # only needs a partial uniqueness index, not app-level locking.
    add_index :invitations, [ :organization_id, :email ], unique: true,
      where: "state = 'pending'", name: "index_invitations_on_org_and_email_while_pending"
    add_check_constraint :invitations,
      "state IN ('pending', 'accepted', 'expired', 'revoked')",
      name: "invitations_state_check"
  end
end
