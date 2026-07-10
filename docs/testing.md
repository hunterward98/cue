# Testing

For: anyone writing a test in this repo.

## Commands

| What                      | Command                                                           |
| ------------------------- | ----------------------------------------------------------------- |
| Full backend suite        | `bundle exec rspec` (parallel: `bundle exec parallel_rspec spec`) |
| Frontend suite + coverage | `pnpm test`                                                       |
| Coverage gate (merged)    | `CI=1 bundle exec rspec && bin/rails coverage:check`              |
| Factory lint              | `RAILS_ENV=test bin/rails factory_bot:lint`                       |
| Negative-test tally       | `bin/rails spec:negative_count`                                   |

The coverage gate needs `CI=1` (or any CI env) so Rails eager-loads —
without it, never-referenced files don't appear in the resultset and the
gate can't see them. Local partial runs without the gate are fine.

## The rules

1. **100% line + branch, no `:nocov:`, no exclusions** (ADR 0008). The
   gate is `coverage:check`, which merges unit + system + parallel
   resultsets first — code covered only by a system test still counts.
   Frontend: Vitest thresholds at 100 for pages/components/lib;
   entrypoints are exercised by the system suite in a real browser.
2. **Negative tests are first-class.** Anywhere behavior can be misused,
   write the spec that proves it's rejected: tag `:negative`, name it
   "rejects/forbids/fails …". CI prints the tally
   (`spec:negative_count`); a shrinking count on a PR is a review flag.
3. **System specs run the viewport matrix.** Wrap flows in
   `with_each_viewport` (375×812 and 1280×800) — the
   `Cue/SystemSpecViewportMatrix` cop fails any example that skips it.
   Genuinely viewport-independent? Inline-disable the cop with a
   justification, visibly.
4. **Determinism:** random order (seed printed), `travel_to` for time.
   No sleeps; Capybara waits.
5. **JS errors fail system tests** (`js_errors: true` in the Cuprite
   driver). A console error is a bug, not noise.

## Verified gate failures

Every gate here was proven to fail before it was trusted (foundation
plan_1's negative-test matrix):

| Gate                | Violation tried         | Result         | Date       |
| ------------------- | ----------------------- | -------------- | ---------- |
| coverage:check      | uncalled method body    | exit 2         | 2026-07-09 |
| Vitest thresholds   | untested component      | exit 1         | 2026-07-09 |
| tsc via vite build  | type error in page      | build failed   | 2026-07-09 |
| ESLint any-ban      | `props: any`            | error          | 2026-07-09 |
| ESLint fetch-ban    | `fetch()` in component  | error          | 2026-07-09 |
| Viewport cop        | system spec w/o matrix  | offense        | 2026-07-09 |
| react-doctor        | dangerouslySetInnerHTML | exit 1         | 2026-07-09 |
| lefthook pre-commit | RuboCop offense staged  | commit blocked | 2026-07-09 |

Gotcha worth knowing: a **one-line endless method** (`def x = "y"`)
registers as covered at class-load time — line coverage can't see
through it. Multi-line bodies gate correctly. Don't use endless methods
to launder uncovered logic; reviewers should treat suspicious one-liners
accordingly.

## CI shape

`test-backend` (unit/request) and `test-system` (Cuprite) upload their
resultsets; the `coverage` job downloads both, collates, and enforces.
Distinct `COVERAGE_SUITE` env names keep SimpleCov from treating two
runs as the same process and overwriting one with the other. CI runs
single-process rspec while the suite is small; flip to parallel_rspec
when it clears ~2 minutes.
