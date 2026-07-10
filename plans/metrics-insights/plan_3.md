# metrics-insights — Child Plan 3: Insights UI

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; theming plan_3 (components, chart tokens)
- **Reminder:** load the dataviz skill before writing any chart code
  (per its trigger rules).
- **Last updated:** 2026-07-08

## Goal

Two pages that answer a manager's Monday questions at a glance: the
board owner's insights (my flow, my stale cues) and the org owner's
insights (cross-board comparisons, category speeds, requester volumes) —
readable on a phone, honest in its labels.

## Design

- **Board insights (`/o/:slug/boards/:board/insights`, owner +
  org owners):** stat tiles (resolved this window, median in_progress →
  done, cap utilization now), time-in-status by category (bar),
  throughput trend (line, weekly), stale-cue callout list (linked by
  number — the actionable centerpiece, top of page on mobile).
- **Org insights (`/o/:slug/insights`, org owners; all tiers — parent
  Q1 rec):** slowest categories ranking, board comparison (throughput +
  median duration side-by-side — framed as workload visibility, not
  employee scoreboard: no rank ordering, no red highlights on people;
  the voice guide gets a say in chart framing), requester volume list,
  org-wide trend.
- **Chart discipline:** one lightweight library (Q1) wrapped in
  library-owned chart components (`InsightBar`, `InsightLine`,
  `StatTile` — gallery-tested like everything else) so product code
  never touches the chart lib directly; colors exclusively from the
  color-coding token set (the no-hardcoded-color law extends into SVG —
  lint scope widened accordingly); dataviz skill consulted at build for
  form/palette rules.
- **Window picker:** 30/90/365 shared across both pages, in the URL
  (shareable/bookmarkable); "calendar time" label from plan_2 rendered
  under duration charts.
- **Empty/insufficient data:** on-voice teaching states ("Three cues
  isn't a trend. Come back when you've shipped a few more.") with
  explicit minimums (no charts under n=5 — misleading tiny-n charts are
  worse than none).
- Mobile: tiles stack, charts resize (container queries), tables →
  cards; stale list first.

## Implementation steps

- [ ] Chart lib decision (Q1) + wrapped components + gallery entries +
      lint scope extension.
- [ ] Stat tiles + both pages composed from plan_2 structs.
- [ ] Window picker + URL state.
- [ ] Empty/minimum states + voice pass on all labels/framings.
- [ ] Viewport tests + axe on both pages; click budget: board → its
      insights = 1 tap.

## Tests

- Rendering truth: seeded golden history → asserted tile values and
  chart data props (numbers on screen === plan_2 goldens); n<5 → empty
  state not chart (negative); non-owner on org insights → 404; requester
  on any insights → 404 (parent's privacy rule).
- Visual goldens for both pages × themes × viewports.

## Open questions

1. **Chart library** — (a) Recharts **7/10**: React-native composition,
   fine at this chart complexity, heavier bundle; (b) visx **6/10**:
   lighter primitives, more assembly labor; (c) hand-rolled SVG for
   bars/lines only **6/10**: zero deps, real a11y/tooltip work;
   (d) Chart.js **5/10**: canvas (goldens/a11y harder), imperative.
   Decide when building with the dataviz skill loaded.

## Critique

*Reviewed 2026-07-09.*

- Wrapped chart components, tokens-into-SVG lint extension, n<5 empty
  states, no-scoreboard framing for board comparisons: no critique —
  the "workload visibility, not employee scoreboard" stance is the
  right ethical read of small-team metrics and should survive any
  future feature pressure.
- M4 note: given the actual chart inventory (bars, lines, tiles — no
  scatter/zoom/brush), the hand-rolled-SVG option is stronger than its
  6/10 suggests *if* the dataviz skill's specs cover tooltips and
  keyboard access; Recharts remains the safe default. Leave the
  ranking; decide at build with the skill loaded, as planned.
- Stale-cue callouts as the mobile-first top element: correct — it's
  the only insight that demands action today rather than reflection;
  no further critique.
