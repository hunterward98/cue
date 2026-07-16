# Parent Plan: Metrics & Insights

- **Status:** NOT_STARTED
- **Phase:** 3
- **Depends on:** boards-workflow, cues (audit events are the data source)
- **Blocks:** —
- **Last updated:** 2026-07-08

## Objective

Give organizations and board owners the numbers that refine their workflow:
where time goes, which work is slowest, who asks the most. Built entirely on
the `cue_events` audit log — no separate analytics infrastructure.

## Scope (from master_plan.md)

- Time spent by cue type: total time from in-progress to done, per work
  category.
- Which cue types are slowest.
- Who requests the most.
- Aimed at org admins and board owners refining workflows.

## Key decisions

### Recommended

1. **Source of truth: `cue_events`** (from cues plan). Time-in-status is
   computed from transition timestamps. No event system rework needed —
   this dependency is *designed in* from the cues plan.
2. **Computation: SQL over events with Solid Cache**, recomputed on a daily
   job + on-demand refresh. No warehouse, no cubes — a 5k-DAU org's events
   fit in milliseconds of Postgres. Documented as a deliberate
   build-for-today choice.
3. **v1 insight set:**
   - Median + p90 time in each status, by work category (org and per-board).
   - Slowest categories ranked (in-progress → done duration).
   - Requester leaderboard (cue volume, resolution rate).
   - Board throughput: cues resolved per week, board cap utilization.
   - Stale-cue callouts (in a status > N days — configurable).
4. **Presentation:** one "Insights" page per board owner + one org-level page
   for admins, date-range picker (30/90/365 days), charts via a single
   lightweight library chosen per the design system (dataviz skill will be
   loaded when charts are built; tokens only, no hardcoded colors).
5. **Privacy:** insights aggregate metadata only (statuses, categories,
   counts, durations) — never cue content. Requester leaderboard visible to
   admins/owners only, not to other requesters.

## Child plans to create

- `plan_2.md` — Query layer: duration/aggregation SQL over cue_events,
  caching, date ranges, correctness tests against synthesized event
  histories.
- `plan_3.md` — Insights UI: owner page, org page, charts, empty states
  ("not enough data yet" — on-voice), mobile rendering.

## Implementation order

1. [ ] Verify cues plan_2 emits every needed event (schema review gate —
   do this DURING cues implementation, not after).
2. [ ] plan_2 query layer.
3. [ ] plan_3 UI.

## Test strategy

- Golden tests: synthesize an event history with known durations, assert
  exact aggregates (including cues that bounce between statuses, cues
  reopened, timezone edges, and in-flight cues excluded/included correctly).
- Negative tests: requester cannot access insights pages; insights never
  render cue titles/descriptions to unauthorized roles.

## Progress

- [ ] Event schema verified sufficient
- [x] Child plans authored (2026-07-08)
- [ ] Query layer shipped
- [ ] UI shipped

## Open questions

1. Are insights available on the basic tier? Master plan doesn't gate them.
   (Recommendation: yes on all tiers — insights drive the habit that
   justifies upgrades.)
  answer: yes but need to have good core ones on the basic tier. can have some super advanced or niche metrics on another tier.
2. Business-hours-aware durations (8h workday) vs wall-clock?
   (Recommendation: wall-clock v1, clearly labeled; business-hours is a
   documented deferral.)
answer: wall clock

## Critique

*Reviewed 2026-07-09.*

- Events-as-source, SQL-over-warehouse, all-tiers availability (M1):
  no critique — proportionate and cheap, and the dependency was
  designed into cues plan_2 rather than bolted on.
- One product-shaped observation: the master plan asks "who requests
  the most," which the leaderboard answers — but the more actionable
  small-office insight is usually "which *categories* eat Charlie's
  week." The v1 insight set covers both; when prioritizing within
  plan_3, build category-time views before requester leaderboards
  (managers act on the former; the latter mostly generates feelings).
- Stake semantic drift across boards would quietly poison org-level
  aggregates — resolved if the cues plan_3 critique's org-level stake
  configuration is adopted (C6 thread). Cross-referenced so the
  decision lands with its metrics consequence visible.
