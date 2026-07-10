# cues — Child Plan 2: Model, State Machine, Numbering, Audit, Permissions

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** organizations-users plan_2, database-architecture plan_2/3
- **Blocks:** every other cues child, boards, metrics
- **Last updated:** 2026-07-08

## Goal

The Cue model and its four load-bearing subsystems: status lifecycle,
ticket numbering, append-only audit events, and the permission layer.
Everything else in the product decorates this.

## Design

- **Schema (core):** org_id, board_id (nullable = backlog), requester_id
  (immutable), title, description (encrypted — AR Encryption per database
  plan), status enum + check constraint, resolved_substatus (null unless
  resolved; check constraint enforces the pairing), number + prefix
  (immutable once set), position (fractional, for backlog/column order),
  stake, deadlines, work_category_id, billable_hours — field details in
  plan_3; columns exist from the start to avoid migration churn.
- **Lifecycle:** `cued → in_progress → in_review → resolved(done|closed|
  infeasible)`. Backwards moves allowed within the active statuses
  (in_review → in_progress happens in real life); resolved is exit-only
  via explicit `reopen` (→ cued, audited, board-cap-checked by boards
  plan_2). Hand-rolled guarded transitions (`Cue#transition_to!`): each
  transition = one method running guards (role check, hook checks from
  plan_8, board rules from boards plan_2) + status write + CueEvent, in a
  transaction. No state-machine gem — the matrix is small and explicit
  beats DSL.
- **Numbering:** `cue_number_sequences` (org_id, prefix, last_value) with
  `SELECT … FOR UPDATE` increment. Prefix set per board owner config
  (plan_3; default: org-wide `CUE`). Assigned at creation, immutable,
  unique per org+prefix (DB constraint). Display: `PREFIX-N`.
- **CueEvent (append-only):** actor, action (created, transitioned,
  edited, commented, pulled, returned, linked…), `data` jsonb
  (from/to, changed fields), created_at. Written inside the same
  transaction as its mutation. Feeds: activity tab (plan_6), hooks
  (plan_8), metrics (metrics plan_2).
- **Permissions (policy objects — Q1):** modify (edit fields, transition)
  = board owner of the cue's board, or (per parent Q1 recommendation)
  the requester while status is `cued`; comment/read = active org members;
  pull/return = boards plan_2's rules; support staff = no content access
  (support-admin break-glass only). One policy class, exhaustively
  matrix-tested — the single source the UI and controllers both consult.

## Implementation steps

- [ ] Migrations (database plan_3 review) + model + factories (cue in
      every status — the suite's workhorse factories).
- [ ] Transition methods + guards + matrix specs.
- [ ] Numbering with concurrency spec (two threads, no dupes/gaps).
- [ ] CueEvent + append-only shared example + event emission from every
      mutation path.
- [ ] Policy layer + role × action matrix specs (all four personas).
- [ ] Reopen flow (cap-check hook point stubbed until boards plan_2).

## Tests

- Full transition matrix: (status × transition × role) — valid paths
  succeed with event emitted; invalid → error, no write, no event.
- Negative: resolved without substatus → DB rejects; substatus on
  non-resolved → DB rejects; requester transitions after `cued` (pending
  Q1 confirmation) → denied; edit by uninvolved member → denied; number
  mutation attempt → rejected; concurrent creation numbering race → no
  duplicates.

## Open questions

1. **Policy layer** — (a) Pundit **8/10**: tiny, boring, per-model policy
   classes fit this exactly; (b) ActionPolicy **7/10**: more features
   (caching, failure reasons) we may not need yet; (c) hand-rolled **5/10**:
   policies are exactly where conventions pay.
2. *(parent Q1 restated)* **Requester status rights** — (a) requester
   edits content + may cancel (resolve-closed) only while `cued`; board
   owner owns all transitions after work starts **8/10**: matches "may
   only be modified by board owner or original requester" while keeping
   the board owner in control of in-flight work; (b) requester can
   transition anytime **4/10**: requesters yanking in-review work creates
   chaos; (c) requester read-only after submit **5/10**: contradicts the
   master plan's modification grant.

## Critique

*Reviewed 2026-07-09.*

- **Blocked on D5 (encryption vs search)** — see database-architecture
  plan_1 critique. If D5 lands on the recommended narrow-encryption
  option, `description` stays plaintext and this plan proceeds as
  written minus the `encrypts` on description; if full encryption wins,
  plan_8's search design changes instead. Do not write the migration
  until D5 is answered.
- Hand-rolled guarded transitions over a state-machine gem: right at
  this matrix size. One design note: return a structured Result
  (already implied by "structured reason" in plan_8) from
  `transition_to!` rather than raising for hook-blocks — reserving
  exceptions for programmer error keeps controller code honest.
- Numbering via `SELECT … FOR UPDATE` on a sequences row: correct and
  boring. Under retry-happy jobs, ensure number assignment is inside
  the same transaction as the cue insert (it is, per the plan) — the
  known residual is *gaps on rollback*, which is fine (uniqueness
  matters, density doesn't); say so in the plan to preempt a future
  "why is CUE-7 missing" investigation.
- Policy layer: Pundit ranking stands. No further critique.
