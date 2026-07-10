# Cue — Master Execution Plan

This index tracks all parent plans, their ordering, and overall progress. Each
feature has a parent plan at `plans/<feature>/plan_1.md`. Child plans
(`plan_2.md`, `plan_3.md`, …) are authored inside the feature directory when
that workstream begins — parent plans define scope, decisions, and ordering;
child plans define implementation detail.

## Conventions

- **Statuses:** `NOT_STARTED` → `PLANNING` → `IN_PROGRESS` → `BLOCKED` / `DONE`
- Every plan carries a `Status`, `Depends on`, and `Progress` checklist. Update
  the checklist in the plan **and** the table below when state changes.
- Anything requiring human action lives in
  `plans/<feature>/manual_steps_plan_1.md`. The agent must notify the user when
  a new manual step is added.
- Open questions live in each plan's `## Open questions` section. Questions
  that block a decision are marked **[BLOCKING]**. Every open question is
  also consolidated — with options ranked /10 — in [questions.md](questions.md),
  the single answer sheet; answers get recorded back into the owning plan.
- Child plans are authored for all features as of 2026-07-08 (54 total,
  `plan_2.md`+ in each feature directory). Question-dependent child plans
  stay design-level until their questions resolve.
- Every plan carries a `## Critique` section (research-backed review pass,
  2026-07-09). Competitive landscape and positioning live in
  [market-research.md](market-research.md).

## Phase ordering

**Phase 0 — Foundation** (nothing ships without this)

| # | Plan | Status | Depends on |
|---|------|--------|-----------|
| 1 | [foundation](foundation/plan_1.md) | IN_PROGRESS (2–4 DONE, 5 BLOCKED on manual steps) | — |
| 2 | [database-architecture](database-architecture/plan_1.md) | IN_PROGRESS (2 DONE, 3 ongoing, 4 BLOCKED) | foundation |

**Phase 1 — Core platform**

| # | Plan | Status | Depends on |
|---|------|--------|-----------|
| 3 | [auth-security](auth-security/plan_1.md) | NOT_STARTED | foundation, database-architecture |
| 4 | [organizations-users](organizations-users/plan_1.md) | NOT_STARTED | auth-security |
| 5 | [theming-design-system](theming-design-system/plan_1.md) | NOT_STARTED | foundation |

**Phase 2 — Product core (MVP)**

| # | Plan | Status | Depends on |
|---|------|--------|-----------|
| 6 | [cues](cues/plan_1.md) | NOT_STARTED | organizations-users, theming-design-system |
| 7 | [boards-workflow](boards-workflow/plan_1.md) | NOT_STARTED | cues |
| 8 | [notifications-email](notifications-email/plan_1.md) | NOT_STARTED | cues |

**Phase 3 — Monetization & extended product**

| # | Plan | Status | Depends on |
|---|------|--------|-----------|
| 9 | [billing](billing/plan_1.md) | NOT_STARTED | organizations-users, cues |
| 10 | [initiatives](initiatives/plan_1.md) | NOT_STARTED | cues, billing (gating) |
| 11 | [metrics-insights](metrics-insights/plan_1.md) | NOT_STARTED | boards-workflow |

**Phase 4 — Growth & polish**

| # | Plan | Status | Depends on |
|---|------|--------|-----------|
| 12 | [marketing-site-seo](marketing-site-seo/plan_1.md) | NOT_STARTED | theming-design-system |
| 13 | [mobile](mobile/plan_1.md) | NOT_STARTED | theming-design-system (verification runs every phase) |

**Cross-cutting — always active**

| # | Plan | Status | Depends on |
|---|------|--------|-----------|
| 14 | [self-improvement](self-improvement/plan_1.md) | IN_PROGRESS (plan_2 DONE) | — (starts with foundation) |
| 15 | [support-admin](support-admin/plan_1.md) | NOT_STARTED | auth-security (console skeleton lands Phase 1–2) |

## MVP definition

The MVP is Phases 0–2 complete plus billing gating stubs: an organization can
sign up, verify email, invite users, create cues on a backlog, board owners can
pull cues to their boards, comment/notify via email, and resolve cues into the
completed section — all mobile-friendly, themed (light/dark), fully tested —
plus the support console skeleton and user-support operations.

## Rules inherited from master_plan.md (apply to every plan)

1. Every line of code has a test; coverage gates are enforced in CI, including
   negative tests that enforce design constraints.
2. No `any` types. No hardcoded colors in components. react-doctor score 100.
3. Build for today, design for 5,000 DAU. Prefer boring, cheap, simple.
4. Every design decision gets documented with justification (see
   self-improvement plan for the decision-record mechanism).
5. Privacy policy / ToS must be updated alongside any feature touching user
   data (tracked as a checklist item in each feature plan).
6. Every feature ships tooling at the right tiers — support console (platform
   staff), org owner, board owner — tracked centrally in the
   [support-admin tooling matrix](support-admin/plan_1.md). A feature plan is
   not DONE until its matrix row is checked or marked n/a.

## Ratified decisions (2026-07-08)

- Inertia.js over a separate API + SPA (foundation).
- PostgreSQL, single-database org-scoped tenancy, single-VPS Kamal deploy
  (database-architecture, foundation).
- Org-level admin role exists, named **org owner**; platform-level **support**
  staff role added (organizations-users, support-admin).
- Annual pricing = 10× monthly, i.e. 2 months free (billing).
