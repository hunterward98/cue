# mobile — Child Plan 4: Pre-Launch Polish Audit

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED (Phase 4,
  pre-launch)
- **Depends on:** all Phase 2 UI shipped; plan_3 (PWA in place)
- **Last updated:** 2026-07-08

## Goal

The human pass automated checks can't replace: real devices, real
thumbs, every core journey — producing a fix list worked to zero before
launch.

## Design

- **Method:** scripted walkthrough (journey list below) executed on
  real iOS Safari + Android Chrome (own devices per parent Q1 rec 8/10;
  BrowserStack 5/10 only if a device-specific bug demands), each journey
  scored pass / friction / broken with notes; friction+ items become
  checklist entries here; broken items become bugs fixed before launch.
- **Journey list:** signup → verify → join org (from a real email on
  the phone); submit cue with camera-roll photo; check my request after
  the status-change email (the deep-link path); owner: triage backlog,
  pull, work a cue to resolve-with-comment via the action sheet;
  comment with @mention from phone; org owner: approve a join request,
  check insights; install PWA, repeat a journey inside it; theme switch;
  org-themed org visual check.
- **Audit lines beyond journeys:** keyboard avoidance (composer not
  hidden by keyboard), input font sizes ≥16px (no zoom-on-focus), form
  autofill/autocomplete attributes honored, safe-area on notched
  devices, tap-target spot checks in real flows (gallery measurement
  catches components; composed screens can still crowd), scroll
  performance on a 100-cue backlog (mid-tier Android), upload progress
  on throttled connection (devtools 3G profile), email rendering of all
  templates in Gmail app + Apple Mail (plan_2 of notifications built
  them; here we look at them on phones).
- **Exit criterion:** zero broken, zero friction on requester journeys
  (owners tolerate mild friction at launch; requesters don't — they'll
  just email the designer instead, and the product loses its reason).

## Implementation steps

- [ ] Walkthrough script finalized from shipped reality (journeys
      above + anything Phase 2–3 added).
- [ ] iOS pass; [ ] Android pass (notes → checklist here).
- [ ] Fix cycle (items tracked as checkboxes appended to this file).
- [ ] Re-run both passes clean.
- [ ] Regression capture: every fixed "broken" gets a matching automated
      spec where one is expressible (the self-improvement gotcha rule
      applied to mobile findings).

## Tests

The audit is manual by design; its output is new automated specs (the
regression-capture step) plus the fix list. Automated coverage already
standing guard: plan_2's matrix/tripwire/budgets, plan_3's SW suite.

## Open questions

None until findings exist — the audit generates its own follow-ups.

## Critique

*Reviewed 2026-07-09.*

No critique — a scripted human audit with an exit criterion
(zero friction on requester journeys), regression-capture into
automated specs, and the email-rendering pass folded in is exactly
what the automated matrix can't do and nothing it can. One addition
from plan_3's critique: add "cold-start the installed PWA while logged
out" to the journey list.
