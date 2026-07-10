# foundation — Child Plan 4: Lint & Quality Gates + CI

- **Parent:** [plan_1.md](plan_1.md) · **Status:** DONE (2026-07-10)
- **Depends on:** plan_2 (scaffold), plan_3 (tests exist to run)
- **Last updated:** 2026-07-10

## Goal

Make the master plan's quality bars impossible to miss: no `any`, no
untested line, react-doctor 100, no security lint violations — all enforced
in one GitHub Actions pipeline plus fast local pre-commit hooks.

## Design

- **Ruby:** RuboCop with `rubocop-rails-omakase` base + `rubocop-rspec`,
  `rubocop-factory_bot`, plus custom cops as they emerge (viewport-matrix
  cop from plan_3 lives here). Brakeman (security) and bundler-audit
  (CVE scan) in CI.
- **TypeScript/React:** ESLint flat config with `typescript-eslint` strict
  + stylistic presets, `@eslint-react` or `eslint-plugin-react-hooks`;
  `no-explicit-any: error` and `ban-ts-comment: error` (no
  `@ts-expect-error` without a linked issue). Prettier for format (ESLint
  defers all formatting to it).
- **react-doctor:** run in CI against `app/frontend`, gate = score 100,
  every rule enforced per master plan.
- **CI pipeline (GitHub Actions):** jobs — `lint` (rubocop, eslint,
  prettier-check, brakeman, audits), `test-backend` (RSpec + coverage
  gate), `test-frontend` (vitest + thresholds), `system` (Capybara matrix),
  `react-doctor`. All required for merge; main is a protected branch.
  Postgres via service container. Gem/node caches keyed on lockfiles.
- **Pre-commit:** fast subset only (changed-file lint + format) so hooks
  never exceed ~5s — CI is the wall, hooks are the courtesy. Tool: Q1.
- **PR template:** checklist — tests added (incl. negative)? ADR needed?
  privacy/ToS touched? support-tooling matrix row affected? gotcha to
  capture?

## Implementation steps

- [x] RuboCop config + zero-offense baseline on scaffold.
- [x] ESLint flat config + Prettier; `any` negative-verified.
- [x] react-doctor wired, gate 100.
- [x] Brakeman + bundler-audit + `pnpm audit` (fail on high+).
- [x] GitHub Actions workflow with the five jobs + caching.
- [x] Branch protection on main (all jobs required).
- [x] Pre-commit hooks (Q1 tool).
- [x] PR template + CODEOWNERS stub.
- [x] Deliberate-violation verification for each gate (parent's matrix).

## Tests

The gates are the tests. Each gate's deliberate-violation run is recorded
in `docs/testing.md` (date verified + what failed).

## Open questions

1. **Pre-commit hook manager** — (a) lefthook **8/10**: fast, single
   binary, YAML config, parallel; (b) husky + lint-staged **6/10**: works
   but Node-centric for a Rails-first repo; (c) overcommit **5/10**: Ruby
   native but slower and less maintained; (d) none, CI only **4/10**:
   slower feedback loop for agents and humans alike.
   Answer: a
2. **Conventional commits + commitlint?** — (a) no, plain good messages
   **7/10**: ceremony without a changelog consumer yet; (b) yes **5/10**:
   pays off only if we later automate changelogs — revisit at the release
   ritual (self-improvement plan_3).
   Answer: Yeah let's not get too fancy. You'll be writing commits anyways so you can summarize well.

## Critique

*Reviewed 2026-07-09.*

- **Pin react-doctor's version** in package.json and treat upgrades as
  deliberate PRs (see plan_1 critique + question F11). An unpinned
  `@latest` scoring gate WILL break CI on a rule release.
- Add the `fetch`-ban lint from plan_3's critique to the ESLint config
  scope here.
- Minor: `ban-ts-comment` requiring a linked issue is good but define
  the linked-issue format now (URL in the comment) so the rule is
  enforceable mechanically, not by reviewer memory.
- Otherwise no critique — the gate set matches the master plan's bars
  and each gate has a deliberate-violation verification, which is the
  part most projects skip.
