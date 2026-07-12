# Parent Plan: Boards & Workflow

- **Status:** NOT_STARTED (blocked on cues, which is unreviewed; all
  four plans' critique feedback incorporated into their designs
  2026-07-11 so implementation can start the moment cues unblocks)
- **Phase:** 2
- **Depends on:** cues, organizations-users
- **Blocks:** metrics-insights (consumes board events)
- **Last updated:** 2026-07-11

## Objective

The Jira-simplification at Cue's heart: one org-wide **backlog**, plus one
**cue'd board per board owner**, with a hard cap on board items to force
prioritization. No sprints, no agile ceremony.

## Scope (from master_plan.md)

- Exactly one backlog per organization (DB-enforced).
- Multiple cue'd boards; each belongs to an individual board owner.
- Configurable max items per board regardless of status, default **10**.
- Only board owners move items from the backlog, and only onto **their own**
  board.
- Board owners have complete control of their board while staying focused;
  each board is searchable.
- Requesters submit cues → cues land in the backlog.

## Key decisions

### Recommended

1. **Model:** `Board` (one per board owner, created with the role grant) with
   `max_items` (default 10, owner-configurable). Backlog is not a Board row —
   it's simply cues with `board_id: NULL` in the org (simplest true model;
   "one backlog per org" becomes structural rather than enforced).
2. **Board cap enforced transactionally** at pull-time counting all
   non-completed cues on the board; resolved-to-completed frees a slot.
   Negative test: pulling an 11th cue fails; cap change below current count is
   allowed but blocks further pulls (no forced eviction).
3. **Board UI: status columns** (cue'd / in progress / in review) with
   drag-and-drop on desktop and tap-to-move on mobile; resolved cues animate
   off to completed. Backlog is a prioritized list, not columns.
4. **Ordering:** manual sort within backlog and columns via fractional
   indexing (single `position` column, no reorder storms).
5. **Board search** scoped to the board + its completed history (Postgres
   FTS from cues plan_8).
6. Real-time updates deferred: Inertia partial reloads + polling on board
   view. Solid Cable exists if demand appears. (Documented decision — cheap
   beats slick at this scale.)

## Child plans to create

- `plan_2.md` — Board model, cap logic, pull/return-to-backlog actions,
  authorization (only-own-board), audit events.
- `plan_3.md` — Backlog UI: prioritized list, filters (category, stake,
  requester), pull affordance for board owners.
- `plan_4.md` — Board UI: columns, drag-and-drop + mobile interactions,
  in-board search, board settings (cap, name).

## Implementation order

1. [ ] plan_2 model + rules (blocking).
2. [ ] plan_3 backlog UI.
3. [ ] plan_4 board UI.
4. [ ] End-to-end system test: requester submits → owner pulls → works →
   resolves → appears in completed. This test is the MVP acceptance test.

## Test strategy

- Negative tests: requester pulls a cue → fail; owner pulls onto someone
  else's board → fail; 11th item → fail; second backlog cannot exist by
  construction (assert model invariant).
- Concurrency test: two simultaneous pulls at cap-1 admit exactly one.
- Mobile-viewport system tests for the board and backlog.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Model + rules shipped
- [ ] Backlog UI shipped
- [ ] Board UI shipped
- [ ] MVP acceptance system test green

## Open questions

1. When a board owner is deactivated/removed, what happens to their board's
   cues? (Recommendation: bulk-return to backlog with an audit event.)
   Answer: Bulk return, board progress saved and can be undone.
2. Can an org admin see all boards in one overview? (Recommendation: yes,
   read-only "all boards" view — likely a popular Jira feature worth keeping;
   flag as a feature suggestion.)
   Answer: Yes, board owners can also see other boards, but is a setting that they set (board owner determines privacy among other board owners). Requesters can only see "counts" of items on boards to gauge how busy someone is.
3. Is `max_items` also org-configurable as a policy ceiling for all boards,
   or purely per-owner? Master plan says "maximum configurable amount he can
   have" — recommendation: per-owner setting, org admin can set a default.
   Answer: owner.


## Critique

*Reviewed 2026-07-09.*

- Backlog-as-null-board_id (structural single backlog) remains the
  cleanest decision in the product plans — no critique.
- **One master-plan reading to double-check with you:** "maximum
  configurable amount of items he can have on his board, regardless of
  item/ticket/cue status" — we interpret the cap as counting *residents*
  (cued/in-progress/in-review; resolved cues leave the board). A
  stricter literal reading would count resolved-but-recent items too,
  which would punish finishing work — almost certainly not intended,
  but it's an interpretation; flagging per the ⚠ convention rather than
  silently assuming. (No question ID — confirm with a word if our
  reading matches your intent.)
  *Resolved 2026-07-11 (Critique feedback: "do what you feel is
  appropriate"): going with the recommended residents-only reading —
  the critique's own reasoning ("punishes finishing work") is decisive,
  and it matches Q1's "board progress saved" framing (a resolved cue has
  already left active board state). If real usage says otherwise, this
  is a one-line change to the cap query's status filter, not a schema
  change — cheap to revisit.*
- W6 (org-owner read-only all-boards overview) is the one add-on here
  that risks Jira-creep — it's justified as *visibility*, but hold the
  line: read-only, no cross-board dragging, or the per-owner focus
  model erodes.
  *Resolved 2026-07-11: Q2's answer already narrows this further than
  the critique anticipated — visibility between board owners is
  opt-in per owner (a privacy setting each board owner controls, not an
  org-admin override), and requesters only ever see counts, never
  board contents. Both are still strictly read-only with no
  cross-board dragging, so the critique's guardrail holds either way.*

## Critique feedback:
Good critiques, maybe we should improve then. Do what you feel is appropriate.