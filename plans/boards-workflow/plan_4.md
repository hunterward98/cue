# boards-workflow — Child Plan 4: Board UI

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, cues plan_6/8
- **Last updated:** 2026-07-08

## Goal

The board owner's daily room: three status columns, drag-and-drop that
respects the state machine, in-board search, and the board's settings —
capped, focused, and pointedly not Jira.

## Design

- **Layout:** `/o/:slug/boards/:board` — columns cue'd / in progress /
  in review; header shows capacity ("7 of 10") and the search field.
  Resolved cues animate off (to completed) — the visible reward.
  Mobile: single column with a status segmented-control, or horizontal
  column swipe — see Q2.
- **Drag-and-drop:** dragging between columns = status transition —
  runs `transition_to!` guards; hook-blocked drops snap back and open the
  inline prompt (e.g. required done-comment via the resolve dialog).
  Within-column drag = position. Library: Q1. Mobile primary mechanism =
  tap card → status action sheet (drag is desktop sugar; parity of
  capability, not of gesture).
- **Resolve flow:** moving to resolved always via a small dialog
  (substatus pick: done/closed/infeasible + comment field appearing when
  the hook demands) — one dialog, hook-aware, keyboard-quick.
- **In-board search:** cues plan_8's query object scoped to this board +
  its resolved history; results grouped active/completed.
- **Board settings (owner-only, docks here):** name, max_items,
  numbering prefix + categories + stake levels + field overrides +
  custom fields + hooks (cues plan_3/7/8 panels compose in — this plan
  owns the settings frame for board scope).
- **Visitors** (other members): read-only board — cards navigate to
  detail; no transition affordances render (policy-filtered, as always).

## Implementation steps

- [ ] Board page + columns + capacity header + policy-filtered
      interactivity.
- [ ] DnD (Q1 library) + guard integration + snap-back + inline prompts.
- [ ] Mobile status action sheet + layout decision (Q2).
- [ ] Resolve dialog (substatus + conditional comment).
- [ ] In-board search.
- [ ] Board settings frame + docked panels.
- [ ] System tests: full owner day-in-the-life (pull → progress → review
      → resolve-with-comment → slot frees) at both viewports — this is
      the MVP acceptance test's second half.

## Tests

- Negative: visitor drag attempt → no-op (and endpoint rejects); drop
  violating state machine (cue'd → review… actually adjacent-only? no —
  matrix from cues plan_2 governs; illegal edges snap back); resolve
  without substatus → blocked; search leaking other boards' cues → fail.
- DnD accessibility: keyboard move path (grab/arrow/drop) fully works —
  axe + interaction specs.

## Open questions

1. **DnD library** — (a) dnd-kit **8/10**: headless, accessible,
   sensors for touch/keyboard, active maintenance; (b) Atlassian
   pragmatic-drag-and-drop **7/10**: excellent perf, newer API, heavier
   docs lift; (c) native HTML5 DnD **3/10**: no touch, a11y pain.
   Answer: A
2. **Mobile board layout** — (a) segmented control, one status at a time
   **8/10**: full-width readable cards, zero horizontal scroll;
   (b) horizontal column swipe **6/10**: spatial continuity with desktop
   but cramped cards; decide with a gallery prototype of both.
   Answer: A

## Critique

*Reviewed 2026-07-09.*

- **W4 (dnd-kit) verified current:** dnd-kit remains the actively
  maintained community default in 2026 (~2.8M weekly downloads;
  [ecosystem comparison](https://www.pkgpulse.com/guides/dnd-kit-vs-react-beautiful-dnd-vs-pragmatic-drag-drop-2026),
  [Puck roundup](https://puckeditor.com/blog/top-5-drag-and-drop-libraries-for-react)).
  Ranking stands; pragmatic-drag-and-drop remains the fallback if
  dnd-kit's sortable preset fights the column model.
- Drag-between-columns = state transition with snap-back on
  guard-block: right model. One UX note: hook-blocked snap-backs must
  be visually distinct from illegal-edge snap-backs (fixable vs
  not-allowed) — the structured reason already carries this; make the
  two animations/toasts distinct so users learn the difference without
  reading.
- Mobile tap-to-move as primary with drag as desktop sugar: correct
  and honest (W5 prototype decision pending). No further critique.

## Critique feedback
Good calls. I like drag between too.