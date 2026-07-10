# mobile — Child Plan 2: Testing Conventions & Click Budgets

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Sequencing:** lands in Phase 1, alongside foundation plan_3 (it
  extends that harness) — before the first product screen exists.
- **Depends on:** foundation plan_3
- **Last updated:** 2026-07-08

## Goal

The mechanism that makes mobile-first a gate instead of a slogan: every
user-facing flow proven at phone width, no horizontal scroll ever, and
the requester's critical paths held to explicit tap budgets in CI.

## Design

- **Viewport matrix (co-owned with foundation plan_3):**
  `with_viewports` shared context — 375×812 (iPhone-class baseline) and
  1280×800; user-facing system specs must include it (custom cop from
  foundation enforces). Tablet width deliberately excluded at v1
  (two widths cover the reality; three slows CI for marginal signal —
  documented).
- **Horizontal-scroll tripwire:** after each system-spec page settle at
  mobile width, a helper asserts
  `document.documentElement.scrollWidth <= innerWidth` — automatic on
  the matrix runs (opt-out with justification comment only). The single
  cheapest mobile regression net that exists.
- **Tap-budget harness:** a system-spec DSL (`budget_taps(3) { ... }`)
  counting Capybara click/tap interactions inside the block — exceeding
  fails with the interaction log printed. Budgeted journeys (from
  parent):
  - logged-in → submitted cue: ≤3 taps (cues plan_6).
  - logged-in → status of my request: ≤2 taps (cues plan_6).
  - owner: backlog → pulled cue: ≤2 taps (boards plan_3).
  - cue → linked initiative → its cues → another cue: ≤3 taps
    (initiatives plan_4).
  Budgets live in one registry file — adding a journey = adding a line +
  spec; changing a budget = a reviewed diff (product-shape changes
  become visible in git history).
- **Touch-target check:** gallery screenshot pass (theming plan_3)
  gains an automated interactive-element measurement — anything
  < 44×44px effective size fails the gallery spec (catches at the
  component level, where fixing is cheap).
- **Definition-of-done line** ("mobile: matrix + budgets green") added
  to the PR template (foundation plan_4).

## Implementation steps

- [ ] `with_viewports` + scroll tripwire helper + cop (with foundation
      plan_3 — one PR).
- [ ] Tap-budget DSL + registry + first budget wired to the auth flow
      (the only flow existing in Phase 1).
- [ ] Touch-target measurement in the gallery harness.
- [ ] PR template line + `docs/testing.md` mobile section.
- [ ] Adopt-as-they-ship checklist: each budgeted journey's spec lands
      with its feature (tracked in the feature plans; listed here for
      the registry).

## Tests

Meta again: deliberate violations — a fixture page with 380px-wide
content fails the tripwire; a journey exceeding budget fails with a
readable log; a 40px button in the gallery fails measurement.

## Open questions

1. **Mobile-width choice** — (a) 375px **8/10**: iPhone SE/mini class,
   the honest floor; (b) 390px **6/10**: comfier modern default,
   hides SE-class breakage; (c) 320px **4/10**: punishing for a
   vanishing device class.

## Critique

*Reviewed 2026-07-09.*

- **Define what a "tap" counts before the DSL exists.** Typing,
  scrolling, and drawer-opens are the contested cases (is opening the
  filter drawer a tap? yes; is typing a title N taps? no — count field
  *focus*, not keystrokes). One paragraph in the registry file defining
  countable interactions prevents budget lawyering later. The DSL then
  counts clicks + taps + focus-changes, ignores keystrokes/scroll.
- Two-viewport matrix (not three): right trade; revisit only if tablet
  usage shows up in analytics.
- Horizontal-scroll tripwire auto-attached to matrix runs: the best
  cheap mechanism in the mobile plans — no critique. Touch-target
  measurement at the gallery (component level, where fixes are cheap):
  also right; composed-screen crowding is correctly left to plan_4's
  human audit.
