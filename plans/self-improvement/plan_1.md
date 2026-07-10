# Parent Plan: Self-Improvement & Documentation Loop

- **Status:** IN_PROGRESS (plan_2 DONE; plan_3/4 gated on later phases)
- **Phase:** cross-cutting — starts with foundation, never ends
- **Depends on:** — (installs alongside foundation)
- **Blocks:** — (but every plan feeds it)
- **Last updated:** 2026-07-10

## Objective

The master plan's mandate: this app is developed primarily with AI, so the
repo itself must teach its developers. Every design decision is documented
and justified; every repeated problem becomes an instruction, skill, or
guardrail; documentation improves continuously and stays concise, human
readable, and legitimately helpful.

## Scope (from master_plan.md)

- Self-improvement loop with in-depth, human-readable documentation.
- Document and justify each design decision — the what AND the why.
- Encountering a problem more than once, or any 'gotcha', REQUIRES capturing
  it as agent instructions, a skill, or another durable mechanism.
- If a skill isn't getting triggered, wire it better.
- Plans track progress and progress is managed by the agent; manual steps
  surfaced in `manual_steps_<plan>.md` with notification.

## Key decisions

### Recommended

1. **Decision records** in `docs/decisions/NNNN-title.md` (ADR-style but
   plain: Context → Decision → Why → Revisit-when). Every "Key decisions"
   block in these parent plans becomes ADRs as it's ratified. A PR that makes
   an architectural choice without an ADR fails review checklist.
2. **CLAUDE.md as the agent contract**, created with the repo scaffold and
   kept short: pointers to plans/README.md, docs/decisions/, design
   standards, test commands, and the standing rules (coverage gate, no
   `any`, no hardcoded colors, legal-update checklist).
3. **Gotcha capture protocol:** second occurrence of any problem → an entry
   in `docs/gotchas.md` AND one of: a CLAUDE.md rule, a project skill in
   `.claude/skills/`, a lint rule, or a test. The gotcha entry links to its
   mechanism — a gotcha without a mechanism is an open task.
4. **Project skills** for repeatable rituals as they emerge; first
   candidates: `release` (version, changelog, product-update post, deploy),
   `new-component` (gallery + tests + tokens scaffold),
   `legal-check` (does this PR touch user data → prompt legal diff).
   Wire triggers by observing misses: if a skill should have fired and
   didn't, its description gets rewritten (per master plan directive).
5. **Plan hygiene ritual:** at each work session's end, update plan Progress
   checklists and the README status table; when a plan requires human input,
   write/refresh `manual_steps_*.md` and notify. This ritual itself is
   captured in CLAUDE.md so any agent session honors it.
6. **Docs structure:** `docs/` = decisions/, design/ (standards, voice),
   gotchas.md, runbooks/ (deploy, backup/restore, incident). Concise beats
   complete; every doc states who it's for in its first line.

## Child plans to create

- `plan_2.md` — Install the loop: docs skeleton, ADR template, CLAUDE.md,
  gotcha protocol, plan-hygiene ritual (lands with foundation plan_2).
- `plan_3.md` — Project skills: identify, author, and trigger-test the first
  three skills once real rituals exist (mid-Phase 2).
- `plan_4.md` — Retrospective cadence: after each phase, review gotchas,
  ADR quality, skill trigger misses, test-suite pain; produce improvement
  actions (recurring — never DONE).

## Implementation order

1. [x] plan_2 with foundation (the loop must exist before code does). (2026-07-10)
2. [ ] plan_3 once rituals repeat (Phase 2).
3. [ ] plan_4 first retro at end of Phase 1, then every phase.

## Test strategy

Where mechanisms can be mechanical, they are: lint rules and CI gates over
documentation-by-convention. The rest is checklist-enforced (PR template:
"ADR needed? Legal touched? Gotcha captured?").

## Progress

- [x] Child plans authored (2026-07-08)
- [x] Docs skeleton + CLAUDE.md live (2026-07-10)
- [x] ADRs exist for all ratified Phase-0 decisions — 0001–0009 (2026-07-10)
- [ ] First three skills authored and trigger-tested
- [ ] Phase retro ritual running

## Open questions

1. Notification channel for manual steps: is a message at session end
   sufficient, or do you want an email/other ping when a
   `manual_steps_*.md` changes? (Recommendation: session-end summary; add
   automation only if steps start getting missed.)
   Answer: Session end summary is fine.

## Critique

*Reviewed 2026-07-09.*

- The loop's mechanisms (ADRs with revisit-when, gotcha protocol with
  mechanism links, plan hygiene, retros auditing the loop itself) are
  proportionate and mutually reinforcing — no structural critique.
- One honest risk to name: **process debt in a solo+agent shop.** Every
  mechanism here costs a little of every session; if velocity sags, the
  temptation is to skip the rituals silently. The correct failure mode
  is *explicit downgrade* (plan_4's lightweight-retro fallback is the
  template — apply the same "fall back loudly, record it" rule to any
  ritual). A skipped ritual that's recorded is process learning; a
  skipped ritual that isn't is rot.
- This critique pass itself validated the loop: it caught a real
  cross-plan conflict (D5, encryption vs search) that no single plan
  could see. Budget a critique pass like this at each phase boundary —
  add it to plan_4's retro template as a standing section.

## Critique feedback:
Good callouts.