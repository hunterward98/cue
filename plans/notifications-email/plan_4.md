# notifications-email — Child Plan 4: Event Wiring & Templates

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_3, cues plans 2/4, boards plan_2
- **Last updated:** 2026-07-08

## Goal

Every v1 event actually lands in inboxes with a well-written template:
the last mile connecting domain events → engine → rendered mail, plus
the auth/invitation mails riding the same rails.

## Design

- **Template set (each: subject, HTML, text, spec):**
  - `mention` — "Charlie mentioned you on CUE-42" (the one mail that's
    always on).
  - `comment` — participant update (+ storm rollup variant).
  - `status_change` — per-transition wording; resolve variant carries
    substatus in human words ("marked done" / "closed: infeasible" gets
    gentle phrasing — someone's request just got declined; snark-free).
  - `cue_created` — to fan-out audience, includes category/stake chips.
  - `cue_pulled` — "your request is on Charlie's board" (the moment the
    requester learns work is starting — worth writing well).
  - `membership` family (from organizations plan_3: invitation, approval
    result) and auth family (from auth plan_2: verification, reset,
    lockout, new-session notice) — restyled onto plan_2's layout, content
    owned by their plans, listed here for template-inventory completeness.
- **Content constraint everywhere:** number, title, actor, event, CTA —
  never description/comment bodies (plan_2's constrained API makes
  violation structurally hard; specs make it caught).
- **Deep links:** every CTA lands exactly on the thing (cue detail,
  approval queue) post-auth — session-expired path bounces through login
  back to target (system-tested; email links are how requesters live).
- Per-board `notify_requester_on_status_change` hook (cues plan_8) gates
  status_change sends — single source of truth check in the resolver.

## Implementation steps

- [ ] Template inventory built on the constrained API, one PR per family
      (reviewable voice pass each).
- [ ] Resolver wiring for each category (plan_3 tables extended per
      template variant).
- [ ] Deep-link + return-to-target auth bounce, system-tested.
- [ ] Hook gate integration.
- [ ] Full-loop system test: comment with mention → email rendered in
      test outbox → link → lands on cue (the demo-able proof).

## Tests

- Per template: content assertions (positive: number/title/actor/CTA;
  negative: seeded sensitive strings absent), both parts, voice
  denylist for snark-free zones (resolve-declined, auth family).
- Loop: event → exactly the resolved audience receives exactly one
  correctly-rendered mail (integration spec per category).
- Deep links: expired-session bounce returns to target; cross-org target
  after membership loss → 404 not leak.

## Open questions

None new — audiences and gating resolve in plan_3/parent questions; this
plan is execution once those land.

## Critique

*Reviewed 2026-07-09.*

- No critique on scope or the constrained-content discipline. Two
  execution notes:
- The "resolve-declined gets gentle, snark-free phrasing" rule is
  quietly one of the most important copy decisions in the product —
  someone's request being closed as infeasible is the moment they
  decide whether Cue made them look bad to their boss. Suggest the
  requester-facing resolved email always includes the closing comment's
  *existence* ("Charlie left a note") as the click-through hook — the
  note itself stays out of the email per the privacy rule, and the
  hook gives the decline context one tap away.
- Expired-session deep-link bounce: test it specifically on iOS
  Gmail-app → in-app browser → session-less Safari handoff, the
  gnarliest real-world path for our audience; if it survives that, it
  survives everything (mobile plan_4 audit line).
