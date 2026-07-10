# 0004 — Single VPS + Kamal 2 deployment

- **Date:** 2026-07-08 (ratified; implementation blocked on manual steps)
- **Status:** accepted

## Context

MVP needs a production home. Assumed load is 200 DAU (ratified
2026-07-09) — a rounding error for one decent machine.

## Decision

One VPS (provider TBD — F9 leans Hetzner US) running web + Solid Queue
worker + Postgres as a Kamal accessory; kamal-proxy terminates TLS.
Scaling path documented, not built: managed Postgres first, second app
host second.

## Why

Cheapest thing that is completely real: TLS, zero-downtime deploys,
rollbacks. PaaS convenience isn't worth 5–10× the money at this scale;
Kubernetes isn't worth the operational surface at any nearby scale.

## Revisit when

Billing goes live (WAL archiving / RPO decision fires first — see
foundation plan_5 critique), or sustained CPU > ~60%, or a second
region/tenant-isolation requirement appears.
