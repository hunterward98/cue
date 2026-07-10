# foundation — Child Plan 3: Test Infrastructure

- **Parent:** [plan_1.md](plan_1.md) · **Status:** DONE (2026-07-10)
- **Depends on:** plan_2 (scaffold)
- **Last updated:** 2026-07-10

## Goal

The test harness that makes "every line has a test" mechanical: RSpec +
SimpleCov gating 100% on the backend, Vitest + RTL gating 100% on the
frontend, system tests with a mobile/desktop viewport matrix, and the
negative-test conventions the whole project will follow.

## Design

- **Backend:** rspec-rails, FactoryBot (+ `FactoryBot.lint` in CI),
  shoulda-matchers, SimpleCov with `minimum_coverage line: 100, branch: 100`
  and `refuse_coverage_drop`. Coverage merged across unit + system runs
  before the gate is evaluated.
- **Frontend:** Vitest + React Testing Library + jsdom; V8 coverage
  provider, 100% thresholds in `vitest.config.ts`. MSW not needed at start
  (Inertia pages receive props, no fetch layer to mock — a documented
  simplification win).
- **System tests:** Capybara. Driver: see Q1. Transactional DB strategy
  with shared connection; screenshots on failure uploaded as CI artifacts.
- **Viewport matrix (mobile plan_2 convention lands here):** shared context
  `with_viewports` runs a flow at 375×812 and 1280×800; user-facing flow
  specs must use it (checked by a spec-linting rule: system specs missing
  the tag fail a custom RuboCop cop).
- **Negative-test convention:** negative cases live beside positives,
  tagged `:negative`, named "rejects/forbids/fails …". CI prints a count of
  negative tests per suite — a shrinking count on a PR is a review flag.
- Deterministic time (`travel_to`) and seeded randomness; `--order random`
  with printed seed.

## Implementation steps

- [x] RSpec + FactoryBot + shoulda-matchers install and conventions doc
      (`docs/testing.md` — who it's for: anyone writing a test here).
- [x] SimpleCov gates + multi-run merge.
- [x] Vitest + RTL + thresholds; example component spec.
- [x] Capybara + driver (Q1) + failure screenshots.
- [x] `with_viewports` shared context + cop enforcing it.
- [x] Negative-test tag + counting rake task.
- [x] Parallel test workers (built-in Rails parallelization for RSpec via
      parallel_tests — evaluate; skip if suite is fast enough yet).
- [x] Foundation's own negative tests: branch with a coverage drop, an
      untested line, a skipped viewport — each must fail CI (verify once,
      document in docs/testing.md).

## Tests

This plan *is* tests; its acceptance is the deliberate-violation matrix in
the parent plan passing (i.e., CI correctly rejecting each violation).

## Open questions

1. **System test driver** — (a) Capybara + Cuprite **8/10**: all-Ruby, one
   test runner, fast CDP driver, transactional fixtures just work;
   (b) Playwright (via playwright-ruby-client under Capybara) **6/10**:
   best-in-class debugging/traces but younger Ruby bindings, more moving
   parts; (c) Selenium **4/10**: slowest, no upside here.
   Answer: a
2. **parallel_tests from day one?** — (a) defer until suite > 2 min
   **8/10**: YAGNI, less CI config; (b) install now **5/10**: pays only
   later, costs setup friction now.
   Answer: We are going to need it - we're moving fast.

## Critique

*Reviewed 2026-07-09.*

- **F3 driver: both options verified alive in 2026** — Cuprite/Ferrum docs
  current ([rubycdp/cuprite](https://github.com/rubycdp/cuprite)) and
  capybara-playwright-driver released 0.5.9 in March 2026
  ([rubygems](https://rubygems.org/gems/capybara-playwright-driver)). The
  Cuprite-first ranking stands; revisit only if CDP flake shows up twice
  (gotcha protocol).
- **100% line+branch coverage is the weakest gate in the plan — honest
  risk: test theater.** Coverage measures *execution*, not *assertion*;
  a mandated 100% invites specs that run code and assert nothing, which
  is worse than 96% honest coverage because it looks like safety. Two
  better shapes, pick one:
  1. **(Recommended)** Keep the 100% gate but allow `# :nocov:` regions
     requiring an inline justification comment, with a CI-printed nocov
     count reviewed at each retro (mirrors our negative-test counter).
     Preserves the master-plan mandate with an auditable escape valve.
  2. Gate at 100% line / targeted branch (models, policies, services
     only), and add **mutation testing** (mutant gem) on the two
     highest-stakes layers — policies and entitlements — where assertion
     quality actually gets verified. Mutation testing is the real
     answer to "are the tests any good"; coverage never was.
  Either way, add mutant runs on `app/policies` + entitlements as a
  weekly CI job — cheap and it audits the tests themselves.
- Frontend "no fetch layer to mock" claim is right today; it decays if
  any component ever fetches directly. Add a lint forbidding `fetch`/
  `axios` in `app/frontend` (Inertia props are the only data path) to
  keep the simplification true.

## Critique feedback:
I don't like :nocov:, although realistic, sounds like bad engineering to me. We need to be strict - our tests will define our app.