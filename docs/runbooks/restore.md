# Runbook: database restore

For: whoever is restoring Cue's database — possibly at 3am, possibly you.
Stay calm; this is rehearsed. (Rehearsal log at the bottom is a review
item — a stale date is a finding.)

## You need

- A backup artifact `<db>-<stamp>.dump.age` (nightly job → R2 bucket,
  once production exists; locally `bin/db-backup` makes one).
- The age **identity file** (private key). Production's lives in the
  ops password manager — NOT on the VPS, NOT in the repo.
- A running Postgres (Kamal accessory or docker compose `db`).

## Steps

```sh
# 1. Decrypt (never write plaintext dumps anywhere long-lived)
age -d -i key.txt -o restored.dump cue_production-<stamp>.dump.age

# 2. Create a fresh target DB (don't clobber the damaged one — evidence)
docker exec -i cue-postgres psql -U cue -c 'CREATE DATABASE cue_restored'

# 3. Restore
docker exec -i cue-postgres pg_restore -U cue -d cue_restored --no-owner < restored.dump

# 4. Sanity: row counts, newest cue timestamps, a login in staging
docker exec -i cue-postgres psql -U cue -d cue_restored -tAc 'SELECT COUNT(*) FROM users'

# 5. Point the app at it (database.yml env vars / Kamal secrets), boot,
#    hit /up/full, THEN rename databases if promoting.
rm restored.dump  # 6. plaintext gone
```

The whole path is exercised automatically by `spec/db/db_backup_spec.rb`
on every CI run — dump → encrypt → decrypt → pg_restore → row check.

## Not yet built (blocked on manual steps: VPS + R2)

Nightly host cron, R2 upload + lifecycle (30 daily / 12 monthly),
weekly automated restore-verification job, WAL archiving
(billing-launch blocker per critique), key-rotation runbook.

## Rehearsal log

| Date       | Who                        | From artifact    | Outcome |
| ---------- | -------------------------- | ---------------- | ------- |
| 2026-07-10 | agent (CI spec, automated) | test-db artifact | pass    |
