# Database conventions

For: anyone writing a migration or model.

## The rules (enforced, not aspirational)

- **Primary keys:** UUIDv7 via Postgres `uuidv7()` defaults (ADR 0003).
  Generators emit it; the adapter prepend backstops hand-written
  migrations; `spec/db/uuid_v7_primary_keys_spec.rb` proves it.
- **Every `_id` column gets a foreign key and an index** —
  `bin/rails db:schema_lint` fails CI otherwise.
- **NOT NULL by default**; allow NULL only with a reason in the migration.
- **Check constraints** for enums-with-meaning (Rails `enum` AND a DB
  constraint), `citext` for emails, `created_at/updated_at` everywhere
  except append-only tables.
- **`jsonb`** for genuinely flexible shapes only; document the shape in
  the model.
- **Migration safety:** strong_migrations gates dangerous operations.
- **N+1s fail tests:** `strict_loading_by_default` in dev/test + Bullet
  raising in test. Escape hatch: `.strict_loading!(false)` plus a
  justification comment.

## Tenancy (ADR 0010)

Single database, org-scoped rows. Every tenant table carries
`organization_id` — even when reachable through a parent (deliberate
denormalization: query simplicity, and it's what makes the conformance
spec and composite FKs possible).

- Runtime scoping: **acts_as_tenant** (`acts_as_tenant :organization` in
  tenant models; tenant set per-request from the authenticated
  membership — wired in auth/organizations plans).
- Structural guard: hot-spine children (cue→board, comment→cue,
  cue_event→cue, node→initiative) FK on `(parent_id, organization_id)`
  against the parent's `UNIQUE (id, organization_id)` so the DB proves
  parent and child share a tenant.
- Test guard: `spec/db/tenant_schema_conformance_spec.rb`
  (self-strengthening — any new table with organization_id is covered
  automatically) plus, once routes exist, a request-spec sweep asserting
  cross-org access → 404 on every org-scoped route.

## Naming

Singular models; `*_events` for append-only logs (no `updated_at`, model
readonly after create — use the "an append-only table" shared example);
join tables named after both sides (`cue_links`); no `type` column
without actual STI.

## Entity map (v1 — plan_3; each table built by its feature plan)

```
User ─┬─ Membership ──── Organization ──┬─ Board (per board_owner membership)
      │   (role, state)                 ├─ Cue ──┬─ Comment
      └─ staff flag (support)           │        ├─ CueEvent (append-only)
                                        │        ├─ CueLink (cue↔cue)
Session, AuthEvent (auth-security)      │        └─ Attachment (Active Storage)
Subscription / Plan (billing)           ├─ WorkCategory
Notification, NotificationPreference    ├─ Initiative ── InitiativeNode
SupportEvent (append-only, support)     └─ Invitation
```

Counter caches: `boards.cues_count` (board-cap checks read it
constantly); others only on measured need. Cue numbering:
`cue_number_sequences` (org_id, prefix, last_value) with row-lock
increment — built in cues plan_2.

## Encrypted columns registry (ADR 0011 — narrow encryption)

AR-encrypted columns, kept current as features land:

| Column     | Since | Why                                                        |
| ---------- | ----- | ---------------------------------------------------------- |
| _none yet_ |       | comment bodies + feedback bodies planned (auth/cues plans) |

Cue titles/descriptions stay plaintext — full-text search depends on it;
at-rest protection for those comes from encrypted backups (+ optional
host volume encryption). Retention: audit logs and completed cues keep
forever (v1; revisit at the first enterprise data-policy ask — D3).
