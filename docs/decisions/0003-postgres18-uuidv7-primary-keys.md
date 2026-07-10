# 0003 — Postgres 18 with native uuidv7() primary keys

- **Date:** 2026-07-09 (question D4)
- **Status:** accepted

## Context

Sequential integer ids leak volume and invite cross-tenant id guessing;
random UUIDv4 keys bloat btree indexes. The original plan generated
UUIDv7 app-side (SecureRandom.uuid_v7 in an ApplicationRecord callback).

## Decision

Postgres 18's native `uuidv7()` as the column default for every primary
key. Generators emit `id: :uuid` (+ `type: :uuid` references); an adapter
prepend injects the default so hand-written `create_table` can't forget
it. No app-side callback. Solid Queue/Cache schemas keep their upstream
bigint keys.

## Why

DB-level generation also covers raw SQL and bulk inserts, and deletes a
whole convention from app code. Time-ordered v7 keeps insert locality.
Caveat (accepted): a v7 id embeds creation time, which is already visible
in-app.

## Revisit when

A table's id must not reveal creation time, or PG major upgrades change
uuidv7() semantics.
