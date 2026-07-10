# cues — Child Plan 3: Fields & Configuration

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; organizations-users plan_4 (org defaults home)
- **Last updated:** 2026-07-08

## Goal

The optional-field system and board-owner configuration: which fields
appear on cues (org default, board-owner override), work categories,
priority levels, stake, deadlines, billable hours, and numbering prefixes.

## Design

- **Two-layer toggles:** org `settings.cue_fields` defines the baseline
  (all ON except billable_hours, per master plan); each board owner's
  `BoardConfig` may override per field for cues on their board. Effective
  config = org default merged with owner override. A disabled field is
  absent from forms AND rejected on write for affected cues
  (negative-tested at the controller/form-object layer — UI hiding is not
  enforcement).
- **Work categories:** org-scoped `WorkCategory` (name, color from the
  color-coding token set — a token reference, never a hex; archived flag
  instead of delete once used). Managed by board owners (any board owner
  may manage the shared org list — master plan says "they can manage
  their list"; interpreted as shared org list, see Q1). Seeds by org
  flavor at creation: design (Social graphic, Flyer, Ad, Photo edit…),
  marketing, IT (Password reset, Hardware, Access…) — picked from an
  org-type question at signup, all editable after.
- **Priorities (stake):** master plan: stake is low/medium/high AND
  owners "set how many priorities they have to choose from (for example,
  just low and high)". Interpretation: stake remains the single
  priority-ish field; owners configure which stake levels are offered
  (2 = low/high, 3 = +medium). See Q2 to confirm the collapse.
- **Deadlines:** `priority_deadline` (when the requester hopes) and
  `acceptable_deadline` (drop-dead), both dates (parent Q2 rec 8/10 vs
  datetimes 3/10 — this audience thinks in days); validation:
  acceptable ≥ priority; overdue states computed, surfaced in UI +
  metrics, never auto-transition anything.
- **Billable hours:** simple decimal, owner-entered, OFF by default;
  surfaced in metrics later. Not a time tracker (documented non-goal).
- **BoardConfig (owner settings home):** field overrides, offered stake
  levels, numbering prefix (uniqueness per org; changing prefix affects
  only future cues — old numbers immutable), category management entry.

## Implementation steps

- [ ] BoardConfig model + effective-config resolver (pure, heavily
      unit-tested merge logic).
- [ ] Field toggle enforcement in the cue form object (single write path
      shared by create/edit — plan_6 consumes).
- [ ] WorkCategory CRUD + archival + org-flavor seeds.
- [ ] Stake level configuration + validation.
- [ ] Deadline validations + overdue computation.
- [ ] Owner settings UI (docks in their board settings, boards plan_4).

## Tests

- Negative: write to disabled field → rejected; unknown stake level for
  that board's config → rejected; acceptable < priority deadline →
  rejected; category from another org → rejected (tenancy); prefix
  collision → rejected; hex color on category (API tamper) → rejected,
  token references only.
- Merge-logic table tests: org default × owner override matrix.

## Open questions

1. **Category list scope** — (a) one shared org list, any board owner
   manages **7/10**: requesters pick categories at submit time (before a
   board is known), so the list must be org-visible anyway; (b) per-owner
   lists **4/10**: master plan's literal reading, but requesters can't
   know which owner will pull their cue; (c) org list + per-owner hidden
   categories **5/10**: later refinement if owners clash.
2. **Stake vs priorities collapse** — (a) one field: stake, with
   configurable offered levels **8/10**: master plan's priority example
   ("just low and high") reads like stake config; two near-identical
   fields would confuse; (b) two separate fields (stake AND priority)
   **4/10**: literal but duplicative. Needs your confirmation since it's
   an interpretation.

## Critique

*Reviewed 2026-07-09.*

- **Per-board stake-level configuration creates cross-board semantic
  drift**: "high" on Charlie's board (of 2 levels) and "high" on Dana's
  (of 3) mean different things, and org insights (metrics plan_2)
  aggregate them as if comparable. Two cleaner shapes:
  1. **(Recommended)** Make offered-stake-levels an **org-level**
     setting (org owners configure once; board owners inherit) — the
     master plan's "they can set how many priorities" reads plausibly as
     board-owner *input* to an org decision, and comparability survives.
  2. Keep per-board config but store stake on a fixed 3-point scale and
     only vary which levels are *offered* — presentation varies, data
     stays comparable. (Middle ground, slightly confusing to explain.)
  Folded into C6's resolution — decide together.
- **`confidential` flag lands here** (O8; from the parent critique) as a
  toggleable field — default ON for IT-flavored orgs, OFF otherwise, if
  we want to be clever; or just always available. Keep it simple:
  always available, badge on the cue, policy branch in plan_2.
- Effective-config two-layer merge: fine; keep the resolver pure and
  table-tested as planned. No further critique.
