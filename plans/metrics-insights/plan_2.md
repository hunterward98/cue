# metrics-insights — Child Plan 2: Query Layer

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** cues plan_2 (cue_events), boards plan_2
- **Last updated:** 2026-07-08

## Goal

Correct numbers from the audit log: time-in-status, category speed
rankings, requester volumes, board throughput — computed in SQL, cached,
and proven against synthesized histories with known answers.

## Design

- **Interval derivation:** transitions in `cue_events` → status
  intervals via window functions (`LAG`/`LEAD` over event timestamps per
  cue); in-flight intervals close at `NOW()` for "currently stuck"
  views but are excluded from resolved-duration aggregates (mixing
  in-flight into medians poisons them — golden-tested rule). Reopens:
  each visit to a status is its own interval; "in_progress → done total
  time" (master plan's metric) = sum of in_progress intervals for cues
  whose terminal substatus = done.
- **Aggregates (`percentile_cont` for median/p90):** per org and per
  board, windowed 30/90/365 days (by resolution date for duration
  metrics, event date for volume metrics — mixing anchors is the classic
  dashboard bug; documented + tested): time-in-status by category;
  slowest-categories ranking (median in_progress→done); requester
  leaderboard (submitted, resolved, resolution rate); board throughput
  (resolved/week, cap-utilization time series from pull/resolve events);
  stale-cue list (current status age > per-board threshold, default 7d,
  configurable in board settings).
- **Query objects** (`Insights::*`) returning typed result structs — no
  SQL in controllers; every query `EXPLAIN`-reviewed with the composite
  indexes it needs on cue_events (org_id, cue_id, created_at, action).
- **Caching:** Solid Cache, key = org/board + window + a data-version
  (max event id) — self-busting on new events, no invalidation
  choreography; nightly warm job for org pages.
- **Wall-clock durations at v1** (parent Q2: wall-clock 8/10 labeled
  clearly vs business-hours 5/10 deferred) — the label lives in the UI
  strings ("calendar time").
- **Privacy:** result structs carry ids/counts/durations + display names
  only — never titles/descriptions (plan_3 renders links by number;
  authorization re-checked at render).

## Implementation steps

- [ ] Interval CTE + indexes + EXPLAIN check-in (documented in
      `docs/database.md`).
- [ ] Query objects per insight + typed structs.
- [ ] Golden-history harness: factory-built event timelines with
      hand-computed expected values (incl. reopen loops, timezone
      boundaries, DST, sub-minute transitions, in-flight exclusion).
- [ ] Cache layer + warm job.
- [ ] Stale-threshold board setting.

## Tests

- Golden histories are the suite's core (every aggregate exact); volume
  vs duration anchor separation asserted; cross-org/board leakage
  negative (seeded look-alike org); cache version bust on new event;
  empty-window results well-formed (no NaN/nil leaks into structs).
- Performance guard: query objects under N ms against a 50k-event
  seeded org (regression canary, generous threshold).

## Open questions

1. **Requester leaderboard identity granularity** — (a) show requester
   display names to owners/org owners only (parent decision) with
   opt-out none **7/10**: it's workflow data, the audience is
   management-side; (b) org setting to anonymize **5/10**: privacy
   nicety, setting sprawl — add if a customer asks.

## Critique

*Reviewed 2026-07-09.*

- Window functions over events, percentile_cont, golden-history testing,
  wall-clock-labeled durations: no critique — the anchor-separation
  rule (durations by resolution date, volumes by event date) is exactly
  the bug most dashboards ship with, caught in design here.
- Two duration-semantics edges the golden harness must include (adding
  to the listed cases): cues resolved, reopened, and re-resolved (which
  resolution date anchors the duration?) — pick "latest resolution,
  cumulative in-progress time" and test it; and cues pulled to a board,
  returned to backlog, re-pulled (in_progress intervals on different
  boards — attribute to the resolving board or split?). Pick
  "attribute to resolving board," document, test. Neither is exotic in
  this workflow; both silently skew medians if unhandled.
- Cache key on max-event-id per org: ensure the index (org_id, id DESC)
  exists or that lookup becomes the slowest part of a cached endpoint.
  Minor.
