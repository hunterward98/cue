# Parent Plan: Cues (Tickets)

- **Status:** NOT_STARTED
- **Phase:** 2
- **Depends on:** organizations-users, theming-design-system, database-architecture
- **Blocks:** boards-workflow, initiatives, metrics-insights, billing gating
- **Last updated:** 2026-07-08

## Objective

The core domain object. A cue is a prompt to take action — this plan covers
its lifecycle, fields, permissions, comments, linking, hooks, and audit log.

## Scope (from master_plan.md)

- **Statuses:** `cued` (todo) → `in_progress` → `in_review` → `resolved`.
  Resolved carries a sub-status: `done`, `closed`, or `infeasible`, and moves
  the cue into a searchable **completed** section (off the board).
- **Fields (all optional, toggleable by org or board owner; default ON except
  billable hours):** stake (low/medium/high), priority deadline, acceptable
  deadline, work category, file uploads, billable hours.
- **Comments** with @-tagging → tagged users notified by email.
- **Board-owner configuration:** ticket number generation scheme, work
  category list, number of priority levels (e.g. just low/high), hooks
  (e.g. "moving to done requires a comment"), audit log visibility.
- **Permissions:** a cue may be modified only by its board owner or original
  requester. (Everyone else in the org: read + comment.)
- **Linking:** cues link to other cues with easy back-and-forth navigation
  (premium/enterprise only — billing gate).
- **Custom ticket fields** for board owners (premium/enterprise only).
- Basic tier limits enforced here: 2MB/upload, 100 active cues org-wide.
(Cue limit changed by user upon review)

## Key decisions

### Recommended

1. **State machine in the model** (AASM or hand-rolled — prefer hand-rolled
   `enum` + guarded transitions, fewer dependencies) with transitions emitting
   audit events and running hooks. Invalid transitions are negative-tested.
2. **Ticket numbers:** per-board-owner configurable prefix + org-scoped
   sequence (e.g. `CHAR-42`). Sequence stored per prefix, generated in a
   transaction (no gaps race). Immutable once assigned.
3. **Field toggles as two layers:** org defaults (organizations-users
   settings) overridden per board owner. A disabled field is hidden AND
   rejected on write (negative test).
4. **Custom fields (premium):** `jsonb` column with a per-board schema
   definition (field name, type: text/select/number/date). No dynamic tables.
5. **Uploads:** Active Storage, disk in dev, S3-compatible object storage in
   prod (cheapest: Cloudflare R2 — no egress fees). Size limits enforced
   server-side per tier. Direct uploads to keep the app server thin.
   Virus-scanning deferred, documented as a security-plan follow-up.
6. **Hooks v1 = a small set of built-in toggles** (require-comment-on-done,
   require-category, notify-requester-on-status-change), not a scripting
   system. Cheap, safe, covers the stated example. Extensible enum design.
7. **Audit log:** append-only `cue_events` table (actor, action, changeset,
   timestamp) written by the state machine and mutations; doubles as the data
   source for metrics-insights (time-in-status).
8. **Linking:** join table `cue_links` (bidirectional uniqueness), badge UI +
   linked-cues panel for navigation.

## Child plans to create

- `plan_2.md` — Cue model, state machine, ticket numbering, audit events,
  permissions. (Largest child plan; blocks everything.)
- `plan_3.md` — Fields & configuration: toggles, categories, priorities,
  deadlines, stake; org/board-owner settings UI.
- `plan_4.md` — Comments + @-tagging (email handoff to notifications plan).
- `plan_5.md` — File uploads (R2, direct upload, tier limits).
- `plan_6.md` — Cue detail + create/edit UI (mobile-first — the requester's
  primary flow; minimal clicks from login to cue).
- `plan_7.md` — Linking + custom fields (premium features, land with billing
  gates available).
- `plan_8.md` — Hooks v1 + completed section with full-text search.
- `plan_9.md` — Request templates: board owners templatize a cue,
  requesters fill in only the blanks (added 2026-07-11, from the O8
  critique thread on organizations-users plan_1 — a template is the
  actual fix for "requesters won't know to use `confidential`").

## Implementation order

1. [ ] plan_2 model/state machine/audit (blocking).
2. [ ] plan_6 create/view UI early — enables end-to-end demo with boards.
3. [ ] plan_3 field configuration.
4. [ ] plan_9 request templates (Hunter-prioritized — do this soon after
   plan_6, don't let it drift to the end).
5. [ ] plan_4 comments/tagging.
6. [ ] plan_5 uploads.
7. [ ] plan_8 hooks + completed search.
8. [ ] plan_7 linking + custom fields (with billing).

## Test strategy

- Exhaustive state-machine matrix: every (status, transition, role)
  combination, valid and invalid.
- Negative tests: requester edits someone else's cue → fail; disabled field
  write → fail; 3MB upload on basic → fail; 51st active cue on basic → fail;
  comment-required hook blocks done without comment.
- Permission tests run as all four personas (admin, board owner, requester,
  non-member).

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Model + state machine shipped
- [ ] UI shipped (mobile verified)
- [ ] Comments, uploads, hooks, search shipped
- [ ] Premium features shipped behind gates
- [ ] Privacy policy updated (uploads, comments retention)

## Open questions

1. Can a requester move their own cue's status (e.g. cancel it), or only the
   board owner? Master plan says both may "modify" — recommendation:
   requester can edit content and close-as-cancelled while `cued`; only board
   owner transitions after work starts.
2. Are deadlines (priority/acceptable) dates or datetimes? (Recommendation:
   dates — this audience thinks in days.)
3. Default work categories to seed for design/marketing/IT orgs?

## Critique

*Reviewed 2026-07-09.*

- **Add the `confidential` cue flag to this parent's scope** (from the
  organizations-users plan_1 critique; question **O8**). The master plan
  names IT password resets as a use case — those cues cannot be
  org-readable under the recommended transparency default. One boolean +
  policy branch resolves it; plan_3 (fields) is its natural home.
- **Request templates added as plan_9** (organizations-users plan_1
  critique feedback, 2026-07-11): the `confidential` flag alone doesn't
  help a requester who doesn't know it exists. A board owner-authored
  template — fixed fields (including `confidential`) stamped
  automatically, requester only fills in the blanks — is the actual
  fix. Prioritized explicitly by Hunter; sequenced right after plan_6 in
  the implementation order above, not left to drift to the end.
- **The encryption/search conflict lives under this plan** (detailed in
  database-architecture plan_1 critique, question **D5**): encrypted
  descriptions (plan_2) and the tsvector over descriptions (plan_8)
  cannot both exist. Resolve D5 before plan_2 migrations are written.
- Language nit that will confuse users: "cue'd" is simultaneously the
  board name, a status, and (implicitly) the backlog state. The status
  of a backlog cue and of an un-started board cue are both `cued`,
  distinguished only by board residency — the UI copy must never say
  "cue'd" to mean "in backlog" (voice guide entry, cheap now, confusing
  forever if missed).
- Hooks-as-toggles over scripting, jsonb custom fields, append-only
  events feeding metrics: all validated, no critique.
