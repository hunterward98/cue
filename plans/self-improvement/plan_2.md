# self-improvement — Child Plan 2: Install the Loop

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Sequencing:** lands WITH foundation plan_2 — the loop exists before
  the code does.
- **Last updated:** 2026-07-08

## Goal

The documentation and decision machinery, installed as repo furniture:
docs skeleton, ADR template + backfill, CLAUDE.md contract, the gotcha
protocol, and the plan-hygiene ritual.

## Design

- **Docs skeleton:** `docs/decisions/` (ADRs), `docs/design/`
  (standards.md, voice.md, components.md — owned by theming),
  `docs/gotchas.md`, `docs/testing.md`, `docs/database.md`,
  `docs/runbooks/`, `docs/security/`. House rule stamped in
  `docs/README.md`: every doc opens with one line saying who it's for;
  concise beats complete; a doc nobody reads is deleted, not maintained.
- **ADR format (`docs/decisions/NNNN-slug.md`):** Context (2–4
  sentences) / Decision / Why (the justification the master plan
  demands) / Revisit-when (the trigger that reopens it — every ADR names
  its own expiry condition). **Backfill on install:** 0001 Inertia over
  API+SPA · 0002 Postgres + org-scoped single-DB tenancy · 0003
  single-VPS Kamal · 0004 role model (owner/board_owner/requester +
  global support) · 0005 annual = 10× monthly · 0006 support console
  in-app, no admin gem · 0007 metadata-by-default/break-glass support
  access · 0008 PWA, no native app · 0009 R2 for objects (when cues
  plan_5 lands) — then continuously as ratifications happen.
- **CLAUDE.md (the agent contract, kept under ~60 lines):** pointers
  (plans/README.md status table, docs/, current phase), commands
  (setup/test/lint one-liners), standing rules (coverage gates, no
  `any`, no color literals, tenancy idiom, negative-test convention,
  voice guide for user-facing strings, PR checklist duties), and the
  rituals: plan hygiene + gotcha protocol (below). CLAUDE.md changes are
  reviewed like code — it *is* the self-improvement surface.
- **Gotcha protocol (master plan's mandate made procedural):** second
  encounter of any problem → entry in gotchas.md (symptom, cause, the
  mechanism that now prevents it) AND the mechanism itself: a CLAUDE.md
  rule, a cop/lint, a test, or a skill. An entry without a mechanism
  link fails the retro review (plan_4). Skill-miss handling: when a
  skill should have triggered and didn't, rewrite its description the
  same day (parent directive "wire it better").
- **Plan-hygiene ritual (session-end):** update touched plans' Progress
  + Status; sync README table; new human-needed items → the feature's
  `manual_steps_*.md` + explicit notification in the session's closing
  message. Written into CLAUDE.md so every agent session inherits it.

## Implementation steps

- [ ] Skeleton + docs/README.md house rules.
- [ ] ADR template + backfill 0001–0008.
- [ ] CLAUDE.md v1 (replacing foundation plan_2's stub).
- [ ] gotchas.md protocol header + first entry when it earns one.
- [ ] PR template lines (with foundation plan_4): ADR? gotcha? legal?
      matrix row?
- [ ] Plan-hygiene ritual text in CLAUDE.md.

## Tests

Light by nature: a CI doc-lint checks ADR files match the template
sections and gotcha entries carry a mechanism link (structural greps —
cheap honesty checks, not prose police).

## Open questions

1. **ADR numbering discipline** — (a) monotonic global counter **8/10**:
   simple, greppable, merge conflicts on numbers are rare and trivial;
   (b) date-prefixed slugs **5/10**: no conflicts, worse to cite.

## Critique

*Reviewed 2026-07-09.*

- **The ADR backfill list is already stale — that's the lesson, not a
  failure.** Critique-round decisions (PG18 native uuidv7, Base UI over
  Radix, react-doctor version pinning, narrow-encryption if D5 lands as
  recommended, composite tenant FKs) each need ADRs the 0001–0009 list
  doesn't include. Change the mechanism: the backfill step should
  generate the list from questions.md's ratified log at execution time,
  not from a hand-maintained enumeration in this plan.
- CLAUDE.md under ~60 lines with pointers: right size; resist the
  drift toward pasting rules into it that already live in lints (the
  lint IS the rule; CLAUDE.md points at it).
- Doc-lints as structural greps, not prose police: correct restraint.
  No further critique.
