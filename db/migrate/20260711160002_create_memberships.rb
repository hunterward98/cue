class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      # Roles are two independent booleans, not an enum (plan_2 critique,
      # ratified): one source of truth for board-ownership, so "all board
      # owners" is a single-column query. Requester = both false.
      t.boolean :owner, null: false, default: false
      t.boolean :board_owner, null: false, default: false
      # No `invited` state: invitees without accounts can't have a
      # membership row, so the invited lifecycle lives on Invitation
      # (org plan_3). Deny destroys the pending row.
      t.string :state, null: false
      t.timestamps
    end
    add_index :memberships, [ :organization_id, :user_id ], unique: true
    add_check_constraint :memberships,
      "state IN ('pending_approval', 'active', 'deactivated')",
      name: "memberships_state_check"
  end
end
