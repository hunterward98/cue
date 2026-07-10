# foundation — Child Plan 5: Deployment Skeleton

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2–4; manual steps (VPS + domain purchased)
- **Last updated:** 2026-07-08

## Goal

The app boots on the production VPS behind TLS via `kamal deploy`, with
image builds cached, secrets managed, and a staging story — before any
feature ships, so deployment never becomes a scramble.

## Design

- **Kamal 2** deploying the Rails 8 default multi-stage Dockerfile (tuned:
  jemalloc, bootsnap precompile, thruster in front of puma). kamal-proxy
  terminates TLS via Let's Encrypt.
- **Topology v1:** one VPS runs web + Solid Queue worker + Postgres
  (Kamal accessory with a named volume). Scaling path (documented, not
  built): move Postgres to managed, add a second app host behind
  kamal-proxy.
- **Image caching (master plan calls this out):** GitHub Actions builds
  with registry-backed BuildKit cache (`cache-from/to` on GHCR) so deploys
  rebuild only changed layers.
- **Secrets:** `.kamal/secrets` reading from GitHub Actions secrets in CI
  and a local `.env` for manual deploys; Rails credentials for app-level
  secrets (AR encryption keys — coordination with database plan_4). No
  secret ever in the repo (gitleaks scan added to CI lint job).
- **Deploys:** manual `workflow_dispatch` job at v1 (deliberate — auto
  deploy on main comes once the suite has earned trust; revisit at Phase 2
  retro). Rollback = `kamal rollback` documented in a runbook.
- **Observability v1:** Rails structured logs + logrotate on host, uptime
  monitoring via a free external pinger, error tracking: Q2.

## Implementation steps

- [ ] Dockerfile tune + local `docker build` verified.
- [ ] Kamal config (app, proxy/TLS, Postgres accessory, worker role).
- [ ] GHCR + BuildKit registry cache in CI build job.
- [ ] Secrets wiring + gitleaks in CI.
- [ ] First production deploy of the health page.
- [ ] Staging decision (Q1) implemented.
- [ ] Runbooks: deploy, rollback, host-loss recovery (`docs/runbooks/`).
- [ ] Uptime pinger + error tracker (Q2).

## Tests

- CI builds the production image on every PR (catches Dockerfile rot).
- Post-deploy smoke: hit `/up` and the health page after each deploy;
  deploy job fails on non-200.

## Open questions

1. **Staging environment** — (a) staging as a second Kamal destination on
   the same VPS (different hostname, own DB) **8/10**: near-zero cost,
   catches config drift, good enough pre-launch; (b) separate cheap VPS
   **6/10**: cleaner isolation, +$6/mo, more to maintain; (c) no staging,
   feature-flag on prod **4/10**: too spicy while the suite is young.
2. **Error tracking** — (a) Sentry SaaS free tier **8/10**: excellent
   Rails+React SDKs, free tier fits MVP volume; (b) self-hosted GlitchTip
   **6/10**: Sentry-compatible, cheap, but ops burden on our one VPS;
   (c) logs only **3/10**: silent client-side errors.
3. **VPS provider** — (a) Hetzner **8/10**: best price/perf (~€5–9 CX/CPX),
   EU data residency; (b) DigitalOcean **7/10**: simpler ecosystem, US
   regions, slightly pricier; pick with the manual-steps answer on hosting
   account. US-audience latency argues for a US region either way.

## Critique

*Reviewed 2026-07-09.*

- **The real weakness is RPO, not the single VPS.** Nightly `pg_dump`
  (database plan_4) means up to 24h of paying customers' tickets lost on
  host failure. The single-VPS SPOF is an availability risk (acceptable:
  hours of downtime ≅ annoyance); 24h data loss is a trust-ender. Two
  alternatives, at least one should land before billing goes live:
  1. **pgBackRest or wal-g WAL archiving to R2** — RPO drops to ~minutes,
     stays on our Postgres, modest setup cost. (Recommended; tracked in
     database plan_4 critique.)
  2. **Managed Postgres** (DO Managed PG / Crunchy / Neon, ~$15–19/mo) —
     outsources backups, PITR, and upgrades entirely; the "scaling path"
     brought forward. Costs more monthly, deletes two runbooks.
- Co-locating app + worker + DB couples DB restarts to deploy mishaps;
  acceptable at this scale, but set Postgres `shared_buffers`/memory
  caps explicitly in the accessory config so a fat Solid Queue job can't
  OOM the DB (one line, prevents the classic co-location incident).
- Kamal accessory Postgres major-version upgrades are manual — write the
  upgrade runbook when PG19 ships, not during the incident.
- Sentry free tier (5k errors/mo) is fine for MVP; the quota exhausts
  silently — set the spike alert at 80% so a client-side error loop
  doesn't blind us mid-month.
- F9 note: Hetzner's US regions (Ashburn, Hillsboro) satisfy the
  US-latency concern; ranking stands.
