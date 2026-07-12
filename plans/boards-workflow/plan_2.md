# boards-workflow — Child Plan 2: Board Model, Cap & Movement Rules

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** cues plan_2, organizations-users plan_2
- **Last updated:** 2026-07-11

## Goal

The board rules that define Cue's opinion: one backlog (structural),
per-owner boards with a hard item cap, and pull/return as the only ways
cues cross the line — owner-only, own-board-only.

## Design

- **Board:** belongs to a board_owner membership (unique — one board per
  owner, DB constraint), name (default: owner's first name — "Charlie's
  board"), `max_items` (default from org setting, else 10; bounds 1–100),
  `cues_count` counter cache. Backlog = cues with `board_id: NULL`
  (parent's structural one-backlog decision; a negative spec asserts no
  Board row can represent a backlog).
- **Pull (backlog → own board):** single service:
  policy check (owner + own board) → per-board advisory lock →
  cap check (real row count of resident cues < max_items, counted
  **inside the lock from the cues table itself — never from
  `cues_count`**, per critique: a counter cache is display-only, the
  authoritative count is a real query the same transaction that holds
  the lock can trust; residency = cued/in_progress/in_review, resolved
  cues leave the board — plan_1 critique's reading, ratified there) →
  pull-gating hooks (cues plan_8: require_category/deadline)
  → set board_id + position → CueEvent(pulled). Advisory lock keyed on
  board id makes the concurrent-pull race deterministic (parent's
  concurrency test).
- **Return (board → backlog):** owner-only, own-board-only; status must
  be `cued` or `in_progress`-with-confirm (in_review work sliding back to
  backlog silently would gaslight requesters — confirm dialog + event +
  requester notification); clears board_id, re-enters backlog at top.
- **Cap changes:** owner sets max_items; lowering below current residency
  allowed — blocks pulls until under (no eviction, parent decision).
- **Owner offboarding:** membership deactivation → bulk-return all board
  cues to backlog (single transaction, one CueEvent each + one summary
  event), board archived (kept for history/metrics), org owners notified
  **and each affected requester notified individually** (critique: reuse
  the existing per-cue `cue_returned` notification rather than inventing
  a bulk-specific one — a requester watching "on Charlie's board"
  shouldn't have to guess why it moved). (Parent Q1 recommendation,
  implemented here; see Q1 for edge.)
- **Resolution:** resolved cues drop board residency (board_id →
  a `resolved_from_board_id` retained for metrics/completed filters) —
  freeing a slot is the reward loop for finishing.

## Implementation steps

- [ ] Board model + constraints + counter cache + org default cap wiring.
- [ ] Pull service + advisory lock + hook integration + events.
- [ ] Return service + confirm semantics + events.
- [ ] Offboarding bulk-return + board archival.
- [ ] Resolution residency handoff (with cues plan_2's transition).
- [ ] Concurrency spec: threads racing the last slot — exactly one wins.

## Tests

- Negative: requester pulls → denied; owner pulls to another's board →
  denied; pull at cap → blocked with structured reason; pull skipping
  required hook → blocked; second Board for one owner → DB rejects;
  direct board_id mass-assignment on cue update → rejected (pull service
  is the only path — cop/test enforced); **counter-cache drift doesn't
  affect the cap decision** (critique: corrupt `cues_count` directly,
  assert the pull's admit/reject outcome is unchanged — the real-row
  count inside the lock is what actually decided it).
- Offboarding: N cues → N+1 events, all in backlog, board archived,
  metrics history intact, **each affected requester's notification
  fired** (critique).

## Open questions

1. **Archived board history** — (a) keep board + events forever for
   metrics **8/10**; (b) purge with membership **3/10**: destroys the
   insights the org paid for.
   Answer: Keep
2. **In-review returns** — (a) confirm-dialog + notify requester
   **8/10**; (b) forbid returning in_review cues entirely **5/10**:
   cleaner rule, but real life includes "requester went dark, park it".
   Answer: Yes, review requires requester to be notified. This is not an optional email notification and can only be adjusted via organization admin.

## Critique

*Reviewed 2026-07-09.*

- **Don't let the counter cache into the cap decision.** The plan has
  both an advisory lock + real count and a `cues_count` counter cache;
  the correct discipline: count real rows inside the lock (authoritative),
  use the counter cache for display only. Counter caches drift; a
  drifted cache deciding cap admission is a silent limit bug. One
  sentence in the implementation, one drift negative test (corrupt the
  cache, cap decision still correct).
  *Resolved 2026-07-11 (Critique feedback: "do what you feel is
  appropriate"): Design and Tests above now say this explicitly — real
  row count inside the lock decides admission, `cues_count` is
  display-only, and the drift negative test is named in Tests.*
- Offboarding bulk-return: consider notifying affected *requesters*
  ("your cue is back in the backlog") — the plan notifies org owners
  only; requesters watching "on Charlie's board" will wonder. Cheap:
  it's the existing cue_returned notification fired per cue, rolled up.
  *Resolved 2026-07-11: adopted as designed — Design's Owner offboarding
  bullet and Tests both updated.*
- Return-to-backlog of in_review cues with confirm + requester
  notification (W2a): stands. No further critique — the advisory-lock
  pull design and `resolved_from_board_id` residency handoff are right.
  
## Critique feedback:
Good critiques, maybe we should improve then. Do what you feel is appropriate.