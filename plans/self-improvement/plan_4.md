# self-improvement — Child Plan 4: Retrospective Cadence

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED (first
  retro at end of Phase 1 — not yet: org plan_4 and theming plan_4 are
  still open; recurring — never DONE). Template design-refined
  2026-07-11 per critique feedback, ready the moment the trigger fires.
- **Depends on:** plan_2 (the artifacts retros inspect)
- **Last updated:** 2026-07-11

## Goal

The heartbeat that keeps the loop honest: at each phase boundary, inspect
the machinery (not just the product), produce concrete improvement
actions, and verify the previous retro's actions actually happened.

## Design

- **Trigger:** end of each phase (README table flips a phase to DONE) +
  a standing six-week ceiling if a phase runs long (long phases are when
  drift compounds).
- **Retro template (`docs/retros/YYYY-MM-phase-N.md`) — the lightweight
  form, by answer (Q1 chose (b) over the 8-section (a) design: "Retro
  should be lightweight, honestly"):**
  1. **Actions** — previous retro's actions done? (unfinished items
     carry forward loudly; two carries = the action was wrong, redesign
     it.)
  2. **Gotchas** — every entry has a live mechanism link? new
     repeat-problems missing entries? (grep the session history/PR
     threads for "again"-shaped pain.)
  3. **Drift** — README table vs reality; plans touched without
     progress updates (hygiene ritual failures = process bug, not
     person bug).
  4. **Cross-plan conflict scan** (critique addition, adopted): a fast
     pass asking whether any two plans' decisions collide — the D5
     encryption/search conflict is the proof such collisions survive
     per-plan review and only show up when someone looks across plans
     on purpose. Folded into the lightweight template as its own line
     rather than skipped for brevity, since it's the one section a
     3-item list wouldn't otherwise catch.
  The full 8-section version (ADR audit, skill miss-log review,
  test-suite health, security checklist, docs pruning) stays documented
  below as the fallback-*up*, not the default — reach for it if a
  phase boundary turns out to need the depth, not as the starting point.
  Output: ≤5 improvement actions (forced ranking — a 12-action retro
  produces zero actions in practice), each with its mechanism and its
  verification hook for the next retro.
- **Full 8-section template (reserve depth, not the default):** ADR
  audit (decisions made this phase without ADRs? any ADR whose
  revisit-when has tripped?), skill miss-log review + pruning (plan_3),
  test-suite health (runtime trend, flake list, negative-test count
  trend per suite, coverage-gate friction), security checklist (auth
  plan_5's per-phase items — run here, recorded there), docs pruning
  (anything nobody read this phase gets the delete question) — on top
  of the four lightweight sections above.
- **Who:** the agent drafts the retro from repo evidence; you get the
  draft + the proposed actions in the session summary — approval is the
  human step (a manual_steps entry per retro).

## Implementation steps

- [ ] Template committed + CLAUDE.md pointer.
- [ ] Retro trigger noted in README phase table legend.
- [ ] Phase 1 retro executed (first real run — expect the template to
      need surgery; that surgery is itself the loop working).
- [ ] Recurring thereafter (checklist grows one line per retro):
  - [ ] Phase 1 retro · [ ] Phase 2 retro · [ ] Phase 3 retro ·
        [ ] Phase 4 / pre-launch retro

## Tests

Doc-lint: retro files match template sections; previous-actions section
non-empty after the first retro (the carry-forward can't be silently
dropped).

## Open questions

1. **Retro depth for the solo+agent team** — (a) the 8-section template
   as designed, ~1 session per retro **7/10**: thorough while phases are
   formative; (b) lightweight 3-section (actions/gotchas/drift) **6/10**:
   sustainable floor — fall back to this if retros start slipping, and
   note the fallback as itself a retro finding.
   Answer: Retro should be lightweight, honestly.
   *Applied 2026-07-11: Design above now leads with the lightweight
   4-section form (the original 3 plus the cross-plan conflict scan
   below) and keeps the full 8-section template as reserve depth, not
   the default.*

## Critique

*Reviewed 2026-07-09.*

- Carry-forward-loudly, ≤5 forced-ranked actions, agent-drafted with
  human approval: no critique on the design; the two-carries-means-
  redesign rule is the sharpest piece.
- Addition from plan_1's critique: add a standing retro section —
  "cross-plan conflict scan" — a fast pass asking whether any two
  plans' decisions collide (the D5 encryption/search conflict is the
  proof such collisions survive per-plan review). Cheap to run once
  the plans are mostly built; highest-leverage early, when they're
  still paper.
  *Resolved 2026-07-11 (Critique feedback: "Great input"): folded into
  the lightweight template as its own line (Design above) rather than
  only living in the full 8-section version — it's cheap enough, and
  useful enough this early, to run every time, not just when depth is
  warranted.*

## Critique feedback:
Great input.