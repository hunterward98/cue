# auth-security — Child Plan 5: Recurring Security Review Process

- **Parent:** [plan_1.md](plan_1.md) · **Status:** IN_PROGRESS since 2026-07-10 (never DONE — recurring by design). Weekly scan CI + threat model v1 + checklist live; label-check + first phase review pending GitHub repo.
- **Depends on:** foundation plan_4 (CI), self-improvement plan_4 (retros)
- **Last updated:** 2026-07-08

## Goal

"Always be improving security" (master plan) turned into a routine instead
of a mood: scheduled scans, review triggers, and a living threat checklist
so security work happens on cadence, not after incidents.

## Design

- **Continuous (CI):** Brakeman + bundler-audit + pnpm audit on every PR
  (foundation plan_4) plus a **weekly scheduled CI run** so CVE discoveries
  in unchanged code still surface. Failing scheduled run opens an issue
  automatically.
- **Per-change:** PRs touching `app/**/auth*`, sessions, permissions,
  support console, uploads, or markdown rendering trigger a
  `/security-review` pass — enforced by PR-template checkbox plus a CI
  label check on those paths.
- **Per-phase (with self-improvement retro):** run the threat checklist —
  authz matrix drift (new roles/routes vs policy tests), token/expiry
  inventory, dependency risk review, secrets scan (gitleaks history scan
  quarterly), backup/restore rehearsal date (database plan_4), support
  break-glass audit review (are reasons real?).
- **Living docs:** `docs/security/threat-model.md` (assets → actors →
  surfaces, updated when a new surface ships: uploads, webhooks, support
  console, Stripe) and `docs/security/checklist.md` (the retro list).
- **Dependency updates:** Dependabot/Renovate weekly batch PRs — Q1.

## Implementation steps

- [x] Weekly scheduled security CI workflow + auto-issue on failure.
- [ ] Path-triggered security-review label check.
- [x] Threat model v1 (docs/security/threat-model.md).
- [x] Checklist doc + retro integration (docs/security/checklist.md).
- [x] Dependency update automation: Dependabot (bundler + actions + npm, pinned gates ignored).
- [ ] First phase-review executed at end of Phase 1.

## Tests

Process plan — verification is that the mechanisms fire: a synthetic PR
touching auth paths without the checkbox fails the label check
(negative-tested CI config, same deliberate-violation approach as
foundation).

## Open questions

1. **Dependency update bot** — (a) Renovate **8/10**: monorepo-aware,
   grouping rules, less noisy; (b) Dependabot **7/10**: zero setup,
   GitHub-native, noisier; (c) manual monthly **4/10**: will slip.
   Answer: Dependabot.
2. **Public bug bounty at launch?** — (a) no; disclosure policy +
   security.txt only **8/10**: bounties need triage capacity we don't
   have; (b) small bounty program **3/10** for now.
   Answer: Never bug bounty.

## Critique

*Reviewed 2026-07-09.*

No critique — scheduled scans, path-triggered reviews, phase checklist,
and the living threat model are proportionate and each has an
enforcement mechanism rather than an intention. One addition worth
making when it becomes real: when Stripe webhooks land (billing plan_3),
add webhook-endpoint abuse (replay, signature-stripping) to the threat
model's standing surfaces list.
