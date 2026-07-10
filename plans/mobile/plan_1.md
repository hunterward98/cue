# Parent Plan: Mobile Experience

- **Status:** NOT_STARTED
- **Phase:** 4 for polish; **verification is cross-cutting from Phase 1**
- **Depends on:** theming-design-system
- **Blocks:** —
- **Last updated:** 2026-07-08

## Objective

The core appeal for requesters is submitting and tracking cues from a phone.
Mobile is not a separate app — it's a discipline applied to every screen from
day one, plus a Phase-4 polish pass and PWA packaging.

## Scope (from master_plan.md)

- Submitting requests to board organizers must work in a mobile browser
  (a native app is explicitly not required — "mobile app or in the browser
  on the phone" is satisfied by an installable PWA).
- Minimal clicks: login → see a cue → manage it.

## Key decisions

### Recommended

1. **Responsive web + PWA, no native app.** Documented decision: a native
   app is cost without benefit at this scale; PWA gives home-screen install
   and app-like feel for free. (Push notifications via PWA are a possible
   later add — email remains primary per master plan.)
2. **Mobile-first is a foundation-level gate, not a Phase-4 activity:**
   - Every system test for a user-facing flow runs at BOTH 375px and desktop
     viewports (test-suite convention established in foundation plan_3).
   - The component gallery (theming plan_3) renders per-viewport screenshots.
   - Definition of done for any screen includes the mobile check.
   This plan owns *defining* those conventions; other plans execute them.
3. **Requester critical path budget:** ≤ 3 taps from opening the site
   (logged in) to a submitted cue; ≤ 2 taps to view status of "my requests."
   Budget is asserted in a system test (count real interactions).
4. **Phase-4 polish scope:** touch targets ≥ 44px audit, board tap-to-move
   interactions (with boards plan_4), file upload from camera roll, PWA
   manifest + service worker (offline = graceful message, not offline-first),
   iOS Safari quirks pass.

## Child plans to create

- `plan_2.md` — Mobile testing conventions + viewport CI matrix + click
  budget tests (lands in Phase 1 alongside foundation/theming).
- `plan_3.md` — PWA packaging: manifest, icons, service worker, install
  prompt (on-voice, not naggy).
- `plan_4.md` — Mobile polish audit: full-flow pass on iOS Safari + Android
  Chrome, touch targets, camera-roll uploads, fix list.

## Implementation order

1. [ ] plan_2 conventions (Phase 1 — before first product screen).
2. [ ] Continuous: every feature plan's screens pass viewport tests.
3. [ ] plan_3 PWA (Phase 4).
4. [ ] plan_4 polish audit (Phase 4, pre-launch).

## Test strategy

- The viewport matrix IS the strategy: no user-facing flow merges without a
  passing 375px system test.
- Negative test: a screen with horizontal body scroll at 375px fails.
- Click-budget tests for the requester critical paths.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Viewport conventions live in CI
- [ ] Click budgets asserted
- [ ] PWA shipped
- [ ] Polish audit complete

## Open questions

1. Real-device testing: BrowserStack (~$29/mo) vs your own devices for the
   pre-launch audit? (Recommendation: own devices + free iOS simulator;
   BrowserStack only if bugs demand it.)

## Critique

*Reviewed 2026-07-09.*

- PWA-over-native (ratified) remains right for this product and
  audience; nothing in 2026's app-store economics changes the math for
  a browser-first requester tool.
- The strongest structural idea here is budgets-as-tests (tap budgets
  in CI); its known weakness is brittleness under legitimate UX
  changes — plan_2's registry-with-reviewed-diffs handles that. No
  critique beyond plan_2's definitional note.
- MO3 (own devices over BrowserStack): stands; add one caveat — "own
  devices" must include at least one *low-end Android*, not just
  whatever flagship is in the household; the scroll-performance line in
  plan_4 depends on it.
