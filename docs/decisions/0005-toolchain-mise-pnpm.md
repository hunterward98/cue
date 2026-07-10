# 0005 — mise + pnpm toolchain, versions pinned in-repo

- **Date:** 2026-07-09 (questions F1, F2)
- **Status:** accepted

## Context

Agents and humans need identical Ruby/Node/pnpm versions with zero
"works on my machine" drift.

## Decision

mise pins ruby 3.4.10 / node 24.12.0 / pnpm 11.10.0 in mise.toml.
pnpm with supply-chain hardening: minimumReleaseAge 24h, trustPolicy
no-downgrade, build scripts default-denied (allowBuilds opt-in).

## Why

mise: one fast tool for all runtimes. pnpm: strict node_modules and
first-class supply-chain policy — newly published malware is usually
caught within hours, so a 24h install delay buys real protection for
free. 7d was tried and retro-failed a fresh lockfile; raise it
post-foundation when install cadence slows.

## Revisit when

Raising minimumReleaseAge (post-foundation), or mise/pnpm break a CI
image.
