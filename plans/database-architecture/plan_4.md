# database-architecture — Child Plan 4: Backups, Restore & Encryption Keys

- **Parent:** [plan_1.md](plan_1.md) · **Status:** BLOCKED (needs foundation plan_5 prod + R2 bucket manual steps). age ratified (D2); WAL-archiving-before-billing adopted per critique.
- **Depends on:** foundation plan_5 (prod exists), R2 bucket (cues plan_5
  shares it or a dedicated backups bucket)
- **Last updated:** 2026-07-08

## Goal

Before the first real customer row exists: automated encrypted backups,
a tested restore path, and Active Record Encryption keys managed with a
rotation story. Untested backups are decorative.

## Design

- **Backups:** nightly `pg_dump` (custom format, compressed) from a cron
  on the VPS (host cron, not Solid Queue — must work when the app is
  down), client-side encrypted (age or gpg symmetric), uploaded to a
  dedicated R2 bucket with object lifecycle: 30 daily, 12 monthly.
  Off-VPS is the point — host loss must not take backups with it.
- **Restore:** `docs/runbooks/restore.md` — from fresh VPS to running app.
  Rehearsed on staging quarterly; rehearsal date logged in the runbook
  (a stale date is a review flag — the self-improvement retro checks it).
- **Verification:** weekly job restores latest dump into a scratch
  database and runs a row-count sanity check; alert on failure.
- **AR Encryption:** primary + deterministic + key-derivation keys in
  Rails credentials; which columns are encrypted is each feature plan's
  call, but the registry (list of encrypted columns) lives in
  `docs/database.md`. Key rotation runbook (re-encrypt with
  `ActiveRecord::Encryption` key rotation support) written now, exercised
  when first rotation is due (annually or on suspicion).
- **Backup contents are sensitive** (they contain the encrypted columns
  ciphertext + everything else): bucket is private, credentials scoped
  write-only for the cron user; restore credentials separate.

## Implementation steps

- [ ] Backups bucket + scoped credentials (manual step rider: R2 account —
      shared with cues plan_5's upload bucket setup).
- [ ] Backup script + host cron + encryption + lifecycle rules.
- [ ] Weekly restore-verification job + alerting (uptime pinger webhook or
      error tracker).
- [ ] Restore runbook + first full rehearsal before public signup opens.
- [ ] AR Encryption keys generated + registry section + rotation runbook.

## Tests

- Backup script under test (bats or RSpec-driven): produces decryptable,
  `pg_restore`-able artifact from a seeded test DB.
- Negative: backup bucket rejects public read (bucket policy asserted in
  the script's preflight); app boots refuses if encryption keys missing in
  production (config assertion).

## Open questions

1. **Backup encryption tool** — (a) `age` **8/10**: modern, tiny, simple
   keyfiles; (b) gpg symmetric **6/10**: everywhere but clunky;
   (c) rely on R2 bucket privacy only **3/10**: one leaked credential from
   plaintext dumps.
   Answer: A

## Critique

*Reviewed 2026-07-09.*

- **RPO 24h is the plan's real gap** (same finding as foundation plan_5
  critique). Nightly dumps are fine for the pre-revenue MVP; before the
  first paid subscription, add one of:
  1. **(Recommended) pgBackRest or wal-g continuous WAL archiving to
     R2** — RPO drops from 24h to minutes; keep nightly dumps as the
     simple-restore belt-and-suspenders. Add "WAL archiving live" as a
     billing-launch blocker in this plan's checklist when adopted.
  2. **Managed Postgres** with built-in PITR — deletes this entire plan's
     ops surface for ~$15–19/mo; legitimate if the runbook load starts
     crowding out product work.
- The weekly automated restore-verification is the strongest element —
  most teams never test restores. Keep the quarterly *manual* rehearsal
  too (the automated path tests the dump, not the human).
- age over gpg stands (D2). If WAL archiving is adopted, pgBackRest's
  own AES-256 encryption covers the archive stream — one less moving
  part; note it in the D2 decision.

## Critique feedback:
Good critiques, maybe we should improve then. Do what you feel is appropriate.
