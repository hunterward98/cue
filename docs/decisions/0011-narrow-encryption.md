# 0011 — Narrow column encryption; search stays whole

- **Date:** 2026-07-10 (question D5, critique-detected design conflict)
- **Status:** accepted

## Context

The database plan declared cue descriptions/comments encrypted at rest
(Active Record Encryption); the cues search plan builds Postgres
full-text search over title+description. AR-encrypted columns store
ciphertext — both can't be true. On a single VPS the AR keys live on the
same host as the DB anyway, so AR encryption's real protection is the
stolen-backup scenario, which encrypted backups already cover.

## Decision

Encrypt narrowly: **comment bodies and feedback bodies** (never
searched, most likely to hold secrets like "my password is X"). Cue
titles and descriptions stay plaintext, searchable. At-rest posture for
everything else: age-encrypted off-host backups, strict access control,
optional LUKS at the host. Encrypted-column registry lives in
docs/database.md.

## Why

Honest about the threat model instead of performative: full-value
encryption that shares a host with its keys mostly buys broken search.
Blind-index search (option 3) is real engineering cost for weak results;
plaintext search_text shadow columns (option 2) reintroduce the
plaintext anyway.

## Revisit when

Enterprise compliance demands provable at-rest encryption of all cue
content (→ blind-index or managed KMS + separate key host), or search
scope shrinks to titles only.
