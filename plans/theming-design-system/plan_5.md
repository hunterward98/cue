# theming-design-system — Child Plan 5: Voice Guide & Guided Tutorials

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_3 (components for coach marks)
- **Last updated:** 2026-07-08

## Goal

Codify the snarky-but-classy voice so every string sounds like Cue no
matter who (or what) wrote it, and build the lightweight tutorial
framework that teaches the product in-flow — starting with "what's a
cue?".

## Design

- **Voice guide (`docs/design/voice.md`):** principles — dry wit, never
  at the user's expense; snark seasons, it isn't the meal (≤1 wink per
  screen); plain words over jargon; auth/billing/errors-with-consequences
  stay snark-light; destructive confirmations are dead serious. Canonical
  examples table (do/don't), including the master-plan line: "normal
  people just call this a ticket; you can do that if you really want."
- **String centralization:** all user-facing strings in locale files
  (rails-i18n en.yml for server-rendered; a typed `strings.ts` module or
  frontend i18n JSON for React — see Q1). Payoff: voice review = reviewing
  one diff surface; copy becomes testable; i18n later is a translation
  task, not a refactor. A lint (or convention + review) flags literal
  user-facing strings in components.
- **Tutorial framework:** coach-mark overlays (anchored tooltips with
  next/skip) + first-run empty states doing double duty as teaching
  moments. Per-user progress (`tutorial_progress` jsonb on user):
  dismissed/completed per tutorial; never re-nags; replayable from a help
  menu. No third-party tour library — a Popover primitive from plan_3
  suffices (Q2).
- **v1 tutorials:** (1) "What's a cue?" — requester's first visit,
  ends at the create-cue button; (2) "Your board" — board owner's first
  board visit (cap explained: "ten things. that's the point."); (3) org
  owner first-run — invite members, set defaults. Each ≤4 steps (voice
  guide: tutorials that need >4 steps mean the UI failed).

## Implementation steps

- [ ] Voice guide v1 + PR-review line item ("copy matches voice.md?").
- [ ] String centralization mechanism (Q1) + retrofit the strings that
      exist by then + literal-string lint/convention.
- [ ] Coach-mark component (Popover-based) + progress persistence + help
      menu replay.
- [ ] The three v1 tutorials (each: RTL spec + system test + both
      viewports — coach marks on mobile especially).
- [ ] EmptyState copy pass across shipped screens against voice.md.

## Tests

- Tutorial state: completes/dismisses persist across sessions
  (negative: dismissed tutorial never reappears); anchors resolve on both
  viewports (a coach mark pointing at a hidden element fails the spec).
- Strings: spec asserting no missing i18n keys; snark-light zones
  (auth/billing) contain none of the flagged wink-phrases (a greppable
  denylist — cheap voice regression net).

## Open questions

1. **Frontend string mechanism** — (a) typed `strings.ts` modules per
   feature, no i18n runtime **8/10**: full TS safety, zero deps,
   English-only reality honored (i18n later = mechanical extraction);
   (b) react-i18next now **5/10**: runtime + keys without a second
   language to justify them; (c) inline strings **2/10**: voice review
   becomes archaeology.
   Answer: Yeah don't think I will ever add multi-language.
2. **Tour library** — (a) own Popover-based coach marks **8/10**: tokens,
   voice, and viewport behavior fully ours, small scope; (b) driver.js or
   similar **5/10**: fast start, styling fights and bundle weight after.
   Answer: A

## Critique

*Reviewed 2026-07-09.*

- **The two-string-system seam needs one explicit rule.** Server strings
  (Rails i18n: emails, marketing, validation messages) and frontend
  strings (typed strings.ts) will both exist — fine — but validation
  errors cross the boundary (server-generated, React-rendered). Decide
  now: validation/error copy lives in Rails i18n and arrives as Inertia
  props; strings.ts never duplicates it. One sentence in the voice guide
  prevents the drift where the same error exists in both systems with
  different snark levels.
- Mentions-always-notify is presented as locked; the "mute this cue"
  setting (notifications plan_3) already softens it correctly — no
  change, just ensure the tutorial/preferences copy doesn't promise
  "mentions ALWAYS reach you" while mute exists.
- Coach-marks-over-tour-library: right call at this scope. No other
  critique — the ≤4-step tutorial rule ("more steps means the UI
  failed") is the best line in the plan; put it in the design standards
  doc too.

## Critique feedback
Great insights.