# Parent Plan: Database Architecture

- **Status:** NOT_STARTED
- **Phase:** 0
- **Depends on:** foundation
- **Blocks:** auth-security, organizations-users, cues, billing
- **Last updated:** 2026-07-08

## Objective

Choose the database and establish schema conventions, caching, and query
hygiene so the data layer never becomes the expensive part. The master plan
deferred this decision until full scope was understood — the full scope is now
understood, so this plan makes the call.

## Decision: PostgreSQL

The scope is decisively relational and one Postgres instance serves every need
without additional infrastructure:

- **Relational core:** orgs → users → boards → cues → comments/links/audit
  logs, plus billing entitlements. Foreign keys and constraints enforce the
  design (max board owners per tier, one backlog per org) at the DB layer —
  these become negative tests.
- **`jsonb`** covers the flexible parts (custom ticket fields on premium,
  hook configurations, theme presets) without reaching for NoSQL.
- **Built-in full-text search** covers the searchable "completed" section and
  board search — no Elasticsearch cost.
- **Rails Solid stack** (queue/cache/cable) runs on Postgres — no Redis.
- Containerizes trivially for local dev; managed Postgres is the future
  scaling path. 5,000 DAU of ticket traffic is far below one instance's
  capacity.

MySQL would also work but Postgres's jsonb + FTS + check constraints fit
better. NoSQL is rejected: the data is joins all the way down.

## Scope

- Local Postgres via Docker Compose (from foundation plan).
- Schema conventions: UUIDv7 primary keys (sortable, non-enumerable — matters
  for privacy since cue URLs must not be guessable), `NOT NULL` by default,
  FK constraints always, check constraints for enums-with-meaning,
  `created_at/updated_at` everywhere.
- Multi-tenancy model: **single database, org-scoped rows** with a
  `organization_id` on every tenant table, enforced by a Rails default-scope
  mechanism + a negative test proving cross-org reads fail. (Separate schemas
  per tenant is over-engineering for this scale.)
- N+1 prevention: `strict_loading` on by default in development/test; Bullet
  gem raising errors in test; both are foundation-level gates.
- Caching: Solid Cache; counter caches for board item counts (the max-items
  rule reads this constantly); Russian-doll fragment caching only where
  measurements justify.
- Data privacy: encryption-at-rest for sensitive columns via Rails
  `encrypts` (Active Record Encryption) — cue descriptions/comments/uploads
  are declared sensitive by master plan.

## Child plans to create

- `plan_2.md` — Conventions + tenancy enforcement (generators, default
  scoping, strict_loading, Bullet, negative tests for cross-tenant access).
- `plan_3.md` — Core schema migration set (written jointly with the
  organizations-users and cues plans; this plan owns conventions, they own
  their tables).
- `plan_4.md` — Backup/restore + encryption key management runbook.

## Implementation order

1. [ ] Ratify Postgres decision + UUIDv7 keys + single-db tenancy.
2. [ ] plan_2: conventions and tenancy guardrails in place with tests.
3. [ ] plan_3: schema conventions doc published for downstream plans.
4. [ ] plan_4: backup strategy live before real user data exists.

## Test strategy

- Negative tests: cross-org query without scoping raises; missing FK rejected
  by migration linter; N+1 in any controller action fails the test suite.
- Every model spec asserts DB-level constraints (null, FK, check), not just
  ActiveRecord validations.

## Progress

- [x] Decision ratified (Postgres + single-db org-scoped tenancy, 2026-07-08)
- [x] Child plans authored (2026-07-08)
- [ ] Tenancy guardrails merged
- [ ] Backup runbook exists

## Open questions

1. ~~Confirm PostgreSQL + single-database org-scoped tenancy.~~
   **RATIFIED 2026-07-08.**
2. Retention policy for audit logs and completed cues (forever? configurable?)
   — affects table partitioning choices, though partitioning itself is
   deferred as a "tomorrow" problem.

## Critique

*Reviewed 2026-07-09.*

- **Postgres choice: validated**, and improved — Postgres 18's native
  `uuidv7()` replaces the planned app-side generation (see foundation
  plan_2 critique; adopt PG18 from day one).
- **⚠ DESIGN CONFLICT (this plan vs cues plan_8): Active Record
  Encryption on cue descriptions breaks full-text search.** AR-encrypted
  columns store ciphertext, so the planned `tsvector` over
  title+description cannot exist. Nobody caught this until now because
  the two decisions live in different plans — exactly what this critique
  pass is for. Additionally, on a single VPS the encryption keys (Rails
  credentials) sit on the same host as the DB, so AR encryption's real
  protection reduces to stolen-backup scenarios — which our
  age-encrypted backups already cover. Options (new question **D5** in
  questions.md):
  1. **(Recommended)** Encrypt narrowly: comment bodies + feedback bodies
     (never searched, most likely to hold secrets like "my password is
     X"), leave cue titles/descriptions plaintext in the DB, rely on
     encrypted backups + strict access control + (optionally) LUKS
     volume encryption at the host. Keeps search whole; honest about the
     single-host threat model.
  2. Encrypt everything, search only title+number via a separate
     plaintext `search_text` column (title is the least sensitive
     field). Loses description search; keeps maximal at-rest posture.
  3. Encrypt everything + blind-index/deterministic tokens for search —
     real engineering cost, weak search quality; defer unless enterprise
     compliance demands it.
- Retention (parent Q, now D3): keep-forever v1 stands; revisit at first
  enterprise data-policy ask.
