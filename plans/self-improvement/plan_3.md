# self-improvement — Child Plan 3: Project Skills

- **Parent:** [plan_1.md](plan_1.md) · **Status:** IN_PROGRESS (mostly
  NOT_STARTED — mid-Phase 2, once rituals actually repeat — but the
  candidacy rule's own exception, see Critique feedback, let the
  `dont-reinvent-it` skill and its infrastructure ship early, 2026-07-11)
- **Depends on:** plan_2 (the loop), real repetition to codify
- **Last updated:** 2026-07-11

## Goal

Turn repeated rituals into `.claude/skills/` project skills with
descriptions that actually trigger — and a feedback loop that fixes them
when they don't.

## Design

- **Skill candidacy rule:** a ritual qualifies after it has been
  performed twice AND has ≥3 steps someone could get wrong. Below that:
  a CLAUDE.md line suffices (skills have a maintenance cost; the
  protocol resists skill sprawl).
- **First three (from the parent, refined):**
  - `release` — version bump, changelog from merged PRs, product-update
    post scaffold (marketing plan_6), legal checklist step (marketing
    plan_4), deploy + post-deploy smoke, plan-hygiene sweep. Trigger
    phrases: "release", "ship a release", "deploy to production".
  - `new-component` — scaffold component + RTL spec + gallery entry +
    goldens; check one-off justification; token-only reminder. Trigger:
    "new component", "add a component", component-ish feature asks.
  - `legal-check` — given a diff, walk the user-data checklist (new
    data category? new subprocessor? retention change?) → legal diff or
    recorded n/a. Trigger: PRs touching models with encrypted/PII
    columns, storage config, third-party clients.
- **Trigger engineering (the parent's "wire it better"):** each skill's
  description written from *user phrasing*, not implementer vocabulary;
  each ships with 3 trigger-test prompts (realistic asks that must load
  it) recorded in the skill file's header comment. Miss-log:
  `docs/skill-misses.md` — a skill that should have fired and didn't
  gets a log line + same-day description rewrite + the failing phrase
  added to its trigger tests (the gotcha protocol applied to skills
  themselves).
- **Skill hygiene:** retro (plan_4) reviews the miss-log and prunes
  skills unused for two phases (delete beats decay).

## Implementation steps

- [x] Miss-log ([docs/skill-misses.md](../../docs/skill-misses.md)) +
      CLAUDE.md pointer (2026-07-11) — done early, ahead of the trio
      below, because `dont-reinvent-it` needed it to exist.
- [x] `dont-reinvent-it` skill (2026-07-11,
      [.claude/skills/dont-reinvent-it/](../../.claude/skills/dont-reinvent-it/SKILL.md))
      — not one of the original three, shipped on the candidacy rule's
      own compliance-guarding exception (see plan_3's Critique: "ship on
      need, not on repetition count" — the same reasoning applies to a
      direct ask, not just a compliance guard). `docs:lint` now enforces
      every skill file (this one and the pre-existing `verify`, backfit
      to comply) carries 3 trigger-test prompts + a last-verified date.
- [ ] `release` skill (first of the original three — it has the most
      steps and the most plans depending on its checklist).
- [ ] `new-component` skill (with theming plan_3 live).
- [ ] `legal-check` skill (before billing goes live — it guards the
      lawyer-reviewed docs from drift).
- [ ] Trigger-test pass on all three (run the recorded prompts, verify
      loading); log + fix any miss.
- [ ] Candidate watchlist seeded: schema-migration ritual, gallery
      golden refresh, support-grant procedure — promoted when they hit
      the candidacy bar.

## Tests

Trigger tests are the tests (recorded prompts → skill loads). CI-side:
doc-lint asserts each skill file carries its three trigger-test prompts
and a last-verified date.

## Open questions

None — the candidacy rule answers "which skills" empirically; the
watchlist tracks the queue.

## Critique

*Reviewed 2026-07-09.*

- Candidacy rule (twice-performed + ≥3 error-prone steps), trigger
  tests recorded in the skill, miss-log with same-day rewrites,
  two-phase pruning: no critique — this is the master plan's "if a
  skill isn't getting triggered, wire it better" made mechanical
  instead of aspirational.
- One sequencing note: `legal-check` is listed third but guards the
  lawyer-reviewed documents — it must exist before billing goes live,
  which may arrive before the other two skills' candidacy bars are
  met. The candidacy rule should have a stated exception: compliance-
  guarding skills ship on need, not on repetition count.

## Critique feedback:
I think we may also need a skill that helps improve ourselves - are we solving a problem that has been solved via gem or pnpm package? May we should just install it!

*Shipped 2026-07-11: [.claude/skills/dont-reinvent-it/](../../.claude/skills/dont-reinvent-it/SKILL.md).
Treated as a standalone, need-driven skill rather than waiting for the
plan's mid-Phase-2 candidacy gate — the same "ship on need" exception
the critique already carved out for `legal-check` above.*