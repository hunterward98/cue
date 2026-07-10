# 0001 — Inertia.js instead of a separate API + SPA

- **Date:** 2026-07-08 (ratified) / 2026-07-09 (implemented)
- **Status:** accepted

## Context

Rails backend with a React frontend. The default 2020s shape — JSON API +
client-side router + token auth — triples the moving parts for a one-team
product whose mobile story is the browser (PWA), not a native app.

## Decision

Inertia.js (inertia_rails + @inertiajs/react). Rails controllers render
React pages directly; session auth; no client router; props are the only
data path (enforced by an ESLint ban on fetch/axios in app/frontend).

## Why

The single biggest simplification available for this stack: no API layer,
no token management, no state-sync bugs between two routers. The Rails
adapter is officially maintained (inertiajs org, Evil Martians
co-maintaining) at parity with the Laravel original.

## Revisit when

A native mobile app becomes real (controllers can grow JSON responses
incrementally), or frontend deploys need to decouple from Rails deploys.
