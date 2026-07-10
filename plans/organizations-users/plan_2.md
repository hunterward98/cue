# organizations-users — Child Plan 2: Models & Tenancy Wiring

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** auth-security plan_2, database-architecture plan_2
- **Last updated:** 2026-07-08

## Goal

The tenancy backbone: Organization and Membership models with the ratified
role model (`owner` / `board_owner` / `requester`), wired into
`Current.organization`, with the entitlements seam stubbed so tier limits
are enforceable from the first line.

## Design

- **Organization:** name, unique slug (immutable after creation at v1 —
  slugs appear in join links), `settings` jsonb (documented shape: field
  defaults for cues, board cap default, notification fan-out choice),
  logo (Active Storage, arrives with theming plan_4), soft-delete
  (`discarded_at`) — see Q1.
- **Membership:** user + org unique pair; `role` enum (owner, board_owner,
  requester) with DB check constraint; `board_owner_also` boolean on
  owner rows (ratified: owners may also be board owners); `state` enum
  (invited, pending_approval, active, deactivated). Org must always have
  ≥1 active owner (DB-level: deferred constraint is overkill — model
  validation + destroy guard, negative-tested).
- **Support is not a membership:** negative test asserts the role enum
  can never hold a staff/support value and staff flag grants no org access
  by itself (support-admin owns the flag).
- **Current wiring:** authenticated user + org slug in path
  (`/o/:org_slug/...`) resolve to a membership; no active membership → 404
  (never 403 — don't confirm org existence, parent rule).
- **Entitlements seam (stub now, billing plan_2 fills):**
  `Entitlements.for(org)` → `#allows?(feature)`, `#limit_for(metric)`,
  `#within_limit?(metric, count)`. Stub returns premium-everything in dev,
  configurable in tests — so cues/boards code written in Phase 2 calls the
  real seam from day one.
- Membership mutations (add member, grant board_owner) call
  `within_limit?` — the single choke-point for the 15/2, 200/10, ≥100
  tier rules.

## Implementation steps

- [ ] Migrations (reviewed against database plan_3 checklist).
- [ ] Models + validations + state transitions (invited→active,
      pending→active/removed, active→deactivated→active).
- [ ] Route scoping `/o/:org_slug` + Current resolution + 404 behavior.
- [ ] Entitlements stub module + test helpers (`with_tier :basic`).
- [ ] Membership mutation service objects enforcing limits at the seam.
- [ ] Factories: org-with-owner, full-org (owner + 2 board owners + N
      requesters) — the personas every later spec will use.
- [ ] Seeds: demo org for development.

## Tests

- Negative: duplicate membership rejected (DB + model); last-owner
  deactivation blocked; 3rd board owner `with_tier :basic` fails at the
  seam; non-member org URL → 404; deactivated member → 404 instantly;
  support-flagged user with no membership → 404 on org routes; role
  parameter tampering on any mutation endpoint → rejected.
- State machine matrix for membership transitions.

## Open questions

1. **Org deletion** — (a) soft-delete with 30-day purge grace + owner
   email **9/10**: recovery from rage-quits, billing-friendly; (b) hard
   delete immediately **3/10**: support nightmare; (c) soft-delete forever
   **4/10**: conflicts with privacy expectations. (Purge job details in Q1
   follow-up when built.)
2. *(restating parent Q2)* **Requester visibility** — (a) members see all
   org boards/cues **7/10**: simple, matches small-office trust reality;
   (b) requesters see only their own requests + completed section **5/10**:
   more private but breaks "look what Charlie's working on" transparency
   that makes small teams like these tools; (c) per-board visibility
   config **4/10** now / good later: post-MVP option if a customer asks.

## Critique

*Reviewed 2026-07-09.*

- **The `role` enum + `board_owner_also` boolean creates two ways to be
  a board owner — a query-bug farm.** Every "all board owners" query
  must check `role = 'board_owner' OR (role = 'owner' AND
  board_owner_also)`, and someone will forget. Better: **drop the enum;
  model roles as two booleans** — `owner` and `board_owner` on the
  membership (requester = both false). One representation, queries
  become single-column, the tier limit counts `WHERE board_owner`, and
  a CHECK constraint plus the existing state machine keep it honest.
  Same expressiveness, fewer moving parts. Alternative if the enum
  stays: make `board_owner` its own boolean regardless of role, and
  never encode it in the enum — the point is *one* source of truth for
  board-ownership.
- Entitlements stub defaulting to premium-everything in dev is right,
  but have the stub **log loudly at boot in production** if it (rather
  than billing plan_2's real service) is ever the resolver — a stub
  silently gating production is the failure mode.
- Org-must-have-one-owner via model validation + destroy guard: fine;
  accept the known race (two concurrent owner-removals) as untestably
  rare at 15-person orgs, or take the advisory-lock pattern from boards
  plan_2 if it ever fires.
- Otherwise no critique — membership state machine, 404-not-403, and
  seat checks at the seam are right.
