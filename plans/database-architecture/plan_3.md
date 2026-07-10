# database-architecture — Child Plan 3: Core Schema Coordination

- **Parent:** [plan_1.md](plan_1.md) · **Status:** IN_PROGRESS (docs + guards live 2026-07-10; schema-PR reviews ongoing through Phases 1–2)
- **Depends on:** plan_2; coordinates with organizations-users, cues,
  boards, billing plans (they own their tables; this plan owns coherence)
- **Last updated:** 2026-07-08

## Goal

One coherent entity map before feature plans write migrations, so naming,
ownership, and relationships don't drift. This is a coordination/document
plan — output is `docs/database.md`'s entity section + review gates, not
migrations.

## Entity map (v1)

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

Ownership: each table is created by its feature plan; this plan reviews
every migration PR in Phases 1–2 against the conventions checklist.

## Design rules to enforce in review

- Names: singular models, `*_events` for append-only logs, no `type`
  column without STI intent, join tables named after both sides
  (`cue_links`), `jsonb` columns documented with their shape in the model.
- Every tenant table carries `organization_id` even when reachable through
  a parent (query simplicity + tenancy cop compatibility) — denormalization
  is deliberate and documented (ADR).
- Append-only tables (`cue_events`, `support_events`, `auth_events`): no
  `updated_at`, no update/destroy in model (readonly after create,
  negative-tested).
- Counter caches: `boards.cues_count` (cap checks), others only when a
  measured need appears.
- Numbering sequences: `cue_number_sequences` (org_id, prefix, last_value)
  with row-lock increment — designed here, built in cues plan_2.

## Implementation steps

- [x] Publish entity section + rules in `docs/database.md`.
- [x] ADR: org_id denormalization + composite tenant FKs (ADR 0010, per critique).
- [x] Migration review checklist folded into PR template + db:schema_lint + conformance spec.
- [ ] Review each Phase 1–2 schema PR against it (ongoing checklist below).
  - [ ] organizations-users tables reviewed
  - [ ] auth tables reviewed
  - [ ] cues/boards tables reviewed
  - [ ] billing tables reviewed

## Tests

- Shared example `behaves_like "an append-only table"` (update/destroy
  raise) applied to all `_events` models.
- Schema conformance spec: every tenant table has org_id + FK + index
  (introspects schema, so new tables are auto-covered — a negative test
  that strengthens itself).

## Open questions

None blocking — this plan is convention enforcement; entity disputes
resolve in the owning feature plans.

## Critique

*Reviewed 2026-07-09.*

- **Upgrade worth adopting: composite tenant foreign keys.** Since every
  tenant table already carries `organization_id`, parents can expose
  `UNIQUE (id, organization_id)` and children FK on
  `(parent_id, organization_id)` — the database then *proves* a comment's
  org equals its cue's org, closing the cross-org-write hole that
  app-layer scoping can't fully close. Cost: wider indexes + explicit FK
  definitions. Apply to the hot spine only (cue→board, comment→cue,
  cue_event→cue, node→initiative), not dogmatically everywhere.
- The self-strengthening schema-conformance spec (every tenant table has
  org_id+FK+index) is the best idea in this plan — extend it to also
  assert the composite-FK rule on the spine tables above.
- No other critique; append-only shared examples and the org_id
  denormalization ADR are sound.

## Critique feedback:
Good critiques, maybe we should improve then. Do what you feel is appropriate.