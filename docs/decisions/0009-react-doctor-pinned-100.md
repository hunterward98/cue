# 0009 — react-doctor pinned, gate = zero findings (score 100)

- **Date:** 2026-07-09 (questions F11 + plan_1 critique feedback)
- **Status:** accepted

## Context

Master plan: react-doctor at 100 from day one, every rule enforced. The
tool's score comes from a remote API, and unpinned versions ship new
rules that would break CI overnight.

## Decision

react-doctor pinned exactly (0.7.3); upgrades are deliberate PRs.
`pnpm doctor` = clean public/vite-* (its security pass scans compiled
bundles — false positives by construction) then
`react-doctor . --yes --no-telemetry --blocking warning`: zero
errors+warnings ⇔ score 100, no network, no score API.

## Why

Greenfield is the only time 100 is cheap; the gate keeps it that way.
Offline scoring keeps CI deterministic and vendor-independent.

## Revisit when

Upgrading the pin (read the new rules first), or react-doctor learns to
honor ignore files in its security pass (drop the rm from pnpm doctor).
