# 0008 — 100% line+branch coverage, merged before gating, no :nocov:

- **Date:** 2026-07-09 (question F12, user override)
- **Status:** accepted

## Context

The master plan demands perfect coverage. The critique offered an escape
valve (justified :nocov: regions); the user rejected it: "We need to be
strict — our tests will define our app."

## Decision

SimpleCov records per-process with no in-process minimum (parallel
workers and partial runs see partial data); `bin/rails coverage:check`
collates every resultset — unit, system, parallel workers, distinct
COVERAGE_SUITE names per CI job — and is the single place 100%
line+branch is enforced. Frontend mirror: Vitest v8 thresholds at 100 on
pages/components/lib. Entrypoints/config are excluded from _unit_
coverage because the system suite executes them in a real browser.

## Why

One honest gate beats N flaky ones. Merging before gating is what makes
hard-100 workable without :nocov: — code covered only by system tests
still counts.

## Revisit when

The gate provably breeds assertion-free specs (then add mutation testing
on policies/entitlements — the critique's other half), or suite runtime
makes the merge step the bottleneck.
