# 0015 — An invitation link satisfies email verification

- **Date:** 2026-07-11
- **Status:** accepted

## Context

A brand-new user who accepts an org invitation has no account yet —
signup normally gates on a separate emailed verification code (auth
plan_2) before the account can do anything. Requiring a _second_ email
round-trip immediately after the invitation email is friction with no
security benefit: the invitation link itself was already emailed to,
and clicked from, the address in question.

## Decision

Accepting an invitation as a new user creates the account already
verified (`verified_at` set at creation) — no separate
email-verification step. The invitation's own token discipline (hashed,
single-use, 14-day TTL — `Invitation` model, mirroring `AuthToken`)
carries the same assurance a verification code does: proof of inbox
control at the address the membership is granted to.

## Why

Two proofs of the same fact is friction, not more security — the
invitation link _is_ the verification. Cutting it also removes a
confusing moment where a just-invited teammate would otherwise see a
generic "verify your email" screen instead of landing straight in the
org they were asked to join.

## Revisit when

A compliance requirement demands an explicit, freshly-timestamped
verification step independent of any other email token (unlikely at
this org size — revisit if enterprise customers ask).
