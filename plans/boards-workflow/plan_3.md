# boards-workflow — Child Plan 3: Backlog UI

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, cues plan_6 (cue cards/serializer),
  theming plan_3
- **Last updated:** 2026-07-08

## Goal

The org's single intake surface: a prioritized list every member can
read, requesters watch their submissions in, and board owners triage and
pull from — with the pull affordance showing exactly how much room their
board has left.

## Design

- **Layout:** `/o/:slug/backlog` — ordered list (not columns; parent
  decision) of cue cards (number, title, category Badge, stake, deadline
  chip, requester avatar, age). Mobile: full-width cards, filters in a
  Drawer.
- **Ordering:** manual priority order via fractional `position` (cues
  plan_2 column). Who reorders: board owners and org owners (the
  triage act — requesters don't jockey their own items to the top;
  negative-tested). New cues enter at bottom — see Q1.
- **Filters:** category, stake, requester, age, "has deadline",
  unfiltered count always visible ("Backlog · 34"). Basic-tier ambient
  signal: active-cue count vs 50 limit surfaces here as a quiet meter
  once past 80% (billing plan_2's limit; upsell only at the limit,
  on-voice).
- **Pull affordance (owners only):** each card shows a pull button with
  remaining-capacity context ("Pull — 3 slots left"); at cap the button
  becomes the blocked-reason state ("Board's full. Finish something." —
  voice guide approved). Pull-gating hook failures (category/deadline
  required) render as inline fix-prompts on the card, resolvable without
  leaving the backlog.
- **Reorder interactions:** drag on desktop; mobile = long-press drag
  plus explicit move-to-top/up/down actions (touch drag on long lists is
  miserable — buttons are the primary mobile mechanism, drag the bonus).
- Empty state: teaching moment ("Nothing's cued up. Suspicious." + CTA).

## Implementation steps

- [ ] Backlog page + card composition + pagination (100+ cue orgs).
- [ ] Filters + count + Drawer on mobile.
- [ ] Reorder (fractional positioning endpoint + optimistic UI +
      authorization).
- [ ] Pull affordance states (capacity, blocked, hook-prompt) wired to
      plan_2 services.
- [ ] Basic-tier limit meter (entitlements seam).
- [ ] Viewport + click-budget system tests (owner: backlog → pull ≤2
      taps; requester: find own cue ≤2 taps via filter).

## Tests

- Negative: requester reorder attempt → rejected (endpoint + absent UI,
  tested separately); pull button states match service truth (capacity
  shown = capacity enforced — a drift test seeding cap-1); filter
  injection (unknown param values) → safely ignored.
- Reorder: fractional positions never collide under interleaved
  concurrent reorders (property-ish spec); order stable across pagination.

## Open questions

1. **New-cue entry position** — (a) bottom of backlog **7/10**: triage
   promotes deliberately, no queue-jumping; (b) top **4/10**: newest
   drowns the triaged order; (c) separate "untriaged" strip above the
   ordered list **6/10**: honest inbox model, +1 concept — good later if
   triage volume grows.
   Answer: A

## Critique

*Reviewed 2026-07-09.*

- **Fractional positioning needs a rebalance story stated up front.**
  Repeated insertions between the same two items exhaust float/string
  precision eventually; at our scale it's a slow leak, not a crisis,
  but the failure is confusing when it lands. One background rebalance
  job (renumber positions when min-gap threshold crossed) designed now,
  written when the first gap warning logs — cheaper than the
  alternative (integer positions with gap reindexing) and keeps the
  simple column.
- Requesters can't reorder (only owners/org owners triage): right, and
  matches the anti-queue-jumping stance — but let requesters see *rank*
  ("#12 in the backlog") — transparency without control; cheap and it
  preempts the "where's my request" email to the designer, which is the
  product's whole reason to exist.
- Basic-tier 80% limit meter: good restraint on the upsell. No further
  critique.

## Critique feedback:
Great insight, do those.