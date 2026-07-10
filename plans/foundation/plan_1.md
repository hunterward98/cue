# Parent Plan: Foundation

- **Status:** NOT_STARTED
- **Phase:** 0
- **Depends on:** —
- **Blocks:** everything
- **Manual steps:** [manual_steps_plan_1.md](manual_steps_plan_1.md)
- **Last updated:** 2026-07-08

## Objective

Stand up the monorepo, toolchain, test infrastructure, and CI so that every
subsequent workstream inherits quality gates for free. When this plan is DONE,
a contributor (human or agent) can clone, run one command, and have a working
app with database, tests, linting, and coverage enforcement.

## Scope (from master_plan.md)

- Ruby on Rails + React + Tailwind CSS, monorepo if it makes sense (it does —
  one repo, one deployable, one CI pipeline is the cheapest and simplest).
- Dead-simple platform code; costs low; build for today, scale to 5,000 DAU.
- Containerized local database; perfect test coverage from day one; negative
  tests to enforce designs; react-doctor at 100; no `any` types.

## Key decisions

### Recommended (ratify before starting)

1. **Rails 8 + Inertia.js + React 19 + TypeScript (strict) + Tailwind v4.**
   Inertia lets Rails render React pages with session auth and no separate
   API layer, token management, or client-side router — the single biggest
   simplification available for this stack. Mobile use is browser-based per
   master plan, so a JSON API is not required for MVP. If a native app ever
   materializes, controllers can grow JSON responses incrementally.
2. **Rails 8 "Solid" stack** (Solid Queue for jobs, Solid Cache for caching,
   Solid Cable if needed) — everything runs on the database, no Redis to pay
   for or operate.
3. **Vite** via `vite_rails` for the frontend build (fast, standard, Tailwind
   v4 native).
4. **Deployment target: Kamal 2** onto a single low-cost VPS (Hetzner/DO) with
   the DB co-located initially. Easily handles 5k DAU for this workload;
   scaling path is "move DB to managed Postgres" later.
5. **Tooling:** RuboCop (rails-omakase + strictness additions), Brakeman,
   ESLint + typescript-eslint (`no-explicit-any: error`), Prettier,
   react-doctor in CI with score gate = 100.
6. **Testing:** RSpec + FactoryBot + SimpleCov (100% line+branch gate),
   Vitest + React Testing Library for components, Playwright (or Capybara +
   Cuprite — decide in child plan) for system tests. CI fails under the gate.

### Open

- Ruby/Node version pinning strategy (mise vs asdf vs .tool-versions only).
- System test driver: Capybara+Cuprite (all-Ruby, simpler) vs Playwright
  (better debugging, JS-native). Leaning Cuprite for one-language simplicity.

## Child plans to create

- `plan_2.md` — Repo scaffold: Rails 8 app, Inertia, Vite, Tailwind, Docker
  Compose for Postgres, bin/setup, bin/dev.
- `plan_3.md` — Test infrastructure: RSpec, SimpleCov gates, FactoryBot,
  Vitest/RTL, system tests, example negative test patterns.
- `plan_4.md` — Lint/quality gates: RuboCop, ESLint, TS strict, react-doctor,
  Prettier, pre-commit hooks, CI pipeline (GitHub Actions).
- `plan_5.md` — Deployment skeleton: Dockerfile, Kamal config, staging env,
  image caching in build steps.

## Implementation order

1. [ ] Ratify stack decisions above (answer open questions).
2. [ ] plan_2: scaffold repo — `bin/setup` works, page renders via Inertia.
3. [ ] plan_3: test infra — a failing test fails CI; coverage gate live.
4. [ ] plan_4: lint gates — react-doctor 100 enforced; `any` impossible.
5. [ ] plan_5: deploy skeleton — app boots on a VPS behind TLS.
6. [ ] Write decision records for every choice above (self-improvement plan).

## Test strategy

Foundation is itself tested: CI must demonstrably fail on (a) a dropped test,
(b) coverage below 100%, (c) an `any` type, (d) react-doctor < 100, (e) a
RuboCop/Brakeman violation. Write one deliberate violation per gate on a
branch and confirm CI rejects it — these are the foundation's negative tests.

## Progress

- [x] Decisions ratified (Inertia + Kamal/VPS approved 2026-07-08; remaining
      opens below are non-blocking taste calls)
- [x] Child plans authored (2026-07-08)
- [ ] Repo scaffolded
- [ ] Quality gates verified failing/passing correctly
- [ ] Deploy skeleton live

## Open questions

1. ~~Approve Inertia.js?~~ **RATIFIED 2026-07-08** — Inertia.
2. ~~Approve single-VPS + Kamal?~~ **RATIFIED 2026-07-08** — approved.
3. GitHub org/repo name and whether to make it private initially.

## Critique

*Reviewed 2026-07-09.*

- **Inertia bet: validated.** The Rails adapter now lives in the official
  inertiajs org with [Evil Martians co-maintaining](https://evilmartians.com/chronicles/inertiajs-in-rails-a-new-era-of-effortless-integration),
  at feature parity with the Laravel adapter incl. Inertia 2.0
  ([inertia-rails.dev](https://inertia-rails.dev/)). Residual risk is the
  usual one — frontend deploys are coupled to Rails deploys — acceptable
  for a one-team product.
- **Target Rails 8.1, not 8.0.** 8.1 is current ("Professional" release:
  job continuations, structured logging, local CI —
  [overview](https://rubyroidlabs.com/blog/2025/11/rails-8-8-1-new-features/)).
  Job continuations matter for our bulk-return and true-up jobs.
- **react-doctor score 100 is stricter than the plan admits.** The tool is
  real ([react.doctor](https://www.react.doctor/)) and scores
  `100 − 1.5×unique error rules − 0.75×unique warning rules`, but even
  tldraw/excalidraw sit mid-80s. On greenfield, 100 is reachable — the
  brittleness is *tool upgrades* introducing new rules that break CI
  overnight. Fix: **pin the react-doctor version and upgrade deliberately**
  (new question F11 in questions.md).
- **Master plan ambiguity worth settling now:** "scaling to daily active
  5,000 users a month" mixes DAU and MAU. All capacity claims in these
  plans assume the stricter reading (5,000 DAU). If you meant 5,000 MAU
  (~250–500 DAU), every infra choice gets even more headroom. No design
  change either way — flagging the assumption.
- Deployment SPOF critique lives in plan_5's critique.
