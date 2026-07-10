# 0002 — Rails 8.1 + Solid Queue/Cache (no Redis)

- **Date:** 2026-07-09
- **Status:** accepted

## Context

Jobs and caching need backing infrastructure. Redis is the reflex answer
but is one more service to pay for, operate, and break.

## Decision

Rails 8.1 with the Solid stack: Solid Queue (jobs) and Solid Cache
(cache) on Postgres, dedicated `queue`/`cache` databases in production.
Solid Cable deferred until boards need live updates. Dev/test use
async/memory adapters.

## Why

Everything on the database = one stateful service total. 8.1 (not 8.0)
for job continuations — our future bulk-return and billing true-up jobs
are exactly the long-running batch shape they exist for. Capacity is a
non-issue at 200 DAU (assumption ratified 2026-07-09).

## Revisit when

Queue latency or cache hit rates measurably suffer under load, or a
feature needs pub/sub Redis semantics Solid Cable can't cover.
