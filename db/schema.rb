# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_11_190001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "auth_events", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "index_auth_events_on_action"
    t.index ["user_id"], name: "index_auth_events_on_user_id"
  end

  create_table "auth_tokens", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.integer "attempts_count", default: 0, null: false
    t.string "code_digest", null: false
    t.datetime "consumed_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "purpose", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["token_digest"], name: "index_auth_tokens_on_token_digest", unique: true
    t.index ["user_id", "purpose"], name: "index_auth_tokens_on_user_id_and_purpose"
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
    t.check_constraint "purpose::text = ANY (ARRAY['email_verification'::character varying, 'password_reset'::character varying, 'login_code'::character varying, 'second_factor'::character varying, 'unlock'::character varying]::text[])", name: "auth_tokens_purpose_check"
  end

  create_table "invitations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.boolean "board_owner", default: false, null: false
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.datetime "expires_at", null: false
    t.uuid "inviter_id", null: false
    t.uuid "organization_id", null: false
    t.boolean "owner", default: false, null: false
    t.string "state", default: "pending", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["organization_id", "email"], name: "index_invitations_on_org_and_email_while_pending", unique: true, where: "((state)::text = 'pending'::text)"
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["token_digest"], name: "index_invitations_on_token_digest", unique: true
    t.check_constraint "state::text = ANY (ARRAY['pending'::character varying, 'accepted'::character varying, 'expired'::character varying, 'revoked'::character varying]::text[])", name: "invitations_state_check"
  end

  create_table "memberships", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.boolean "board_owner", default: false, null: false
    t.datetime "created_at", null: false
    t.uuid "organization_id", null: false
    t.boolean "owner", default: false, null: false
    t.string "state", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
    t.check_constraint "state::text = ANY (ARRAY['pending_approval'::character varying, 'active'::character varying, 'deactivated'::character varying]::text[])", name: "memberships_state_check"
  end

  create_table "organizations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.citext "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.check_constraint "slug ~ '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'::citext AND length(slug::text) >= 2 AND length(slug::text) <= 40", name: "organizations_slug_format_check"
  end

  create_table "sessions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "last_active_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "email_address", null: false
    t.integer "failed_login_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "login_mode", default: "password", null: false
    t.string "password_digest"
    t.boolean "staff", default: false, null: false
    t.string "theme_preference", default: "system", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.check_constraint "login_mode::text = ANY (ARRAY['password'::character varying, 'passwordless'::character varying]::text[])", name: "users_login_mode_check"
    t.check_constraint "theme_preference::text = ANY (ARRAY['system'::character varying, 'light'::character varying, 'dark'::character varying]::text[])", name: "users_theme_preference_check"
  end

  add_foreign_key "auth_events", "users"
  add_foreign_key "auth_tokens", "users"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
