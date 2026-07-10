# foundation — Child Plan 2: Repo Scaffold

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** manual steps (GitHub repo exists)
- **Last updated:** 2026-07-08

## Goal

A fresh clone runs `bin/setup && bin/dev` and gets a working Rails 8 +
Inertia + React 19 (TS strict) + Tailwind v4 app against a Dockerized
Postgres, with Solid Queue/Cache installed. This commit defines the shape
every later commit inherits.

## Design

- `rails new cue --database=postgresql --skip-test --skip-jbuilder
  --skip-action-mailbox` (keep Action Mailer, Active Storage, Action Cable
  off until needed — add Solid Cable only when boards demand it).
- Frontend lives in `app/frontend/` (vite_rails convention): `pages/`
  (Inertia pages), `components/` (library, owned by theming plan_3),
  `lib/`. Path alias `@/` configured in both `tsconfig.json` and Vite.
- `tsconfig.json`: `strict: true`, `noUncheckedIndexedAccess: true`,
  `exactOptionalPropertyTypes: true`. TS errors fail the Vite build.
- Postgres 17 via `docker-compose.yml` (single service, named volume,
  port 5432, healthcheck). App runs on host, DB in container — simplest
  dev loop.
- Primary keys: UUIDv7 generated app-side (`SecureRandom.uuid_v7`, Ruby
  3.4+) via an `ApplicationRecord` callback; migration generator defaults
  `id: :uuid, default: nil`.
- `bin/setup` idempotent: deps, DB create/migrate/seed, `.env` from
  `.env.example`. `bin/dev` = Procfile.dev (rails server + vite dev).
- CLAUDE.md stub lands here (content owned by self-improvement plan_2).

## Implementation steps

- [ ] Tool pinning (`.tool-versions` or `mise.toml`) — see Q1.
- [ ] `rails new` with flags above; commit pristine generator output first,
      then customizations as separate commits (reviewable diff).
- [ ] docker-compose Postgres + `config/database.yml` wiring.
- [ ] vite_rails + inertia_rails + React 19 + TS strict + Tailwind v4.
- [ ] Solid Queue + Solid Cache (database-backed, `bin/jobs` runner).
- [ ] UUIDv7 pk convention + generator config + FactoryBot/RSpec generator
      defaults (RSpec install itself is plan_3).
- [ ] `bin/setup` / `bin/dev`; README quickstart section.
- [ ] Health page: an Inertia-rendered React page at `/up/full` proving
      Rails → Inertia → React → Tailwind → DB round-trip.
- [ ] `.env.example`, `.gitignore` audit, CLAUDE.md stub.

## Tests

- System smoke test: health page renders with a Tailwind-styled element and
  a DB-sourced value.
- CI job runs `bin/setup` from clean checkout (catches setup rot forever).

## Open questions

1. **Version manager** — (a) mise **8/10**: fast, one tool for Ruby+Node,
   reads `.tool-versions`; (b) asdf **6/10**: ubiquitous but slower, plugin
   churn; (c) pin in README only **3/10**: drift guaranteed.
   Answer: Mise sounds great.
2. **Node package manager** — (a) pnpm **8/10**: fast, strict, disk-cheap;
   (b) npm **7/10**: zero extra install, boring is good; (c) yarn **4/10**:
   no advantage here. Low stakes; recommend pnpm.
   Answer: pnpm is fine, may need installed on this machine - you have full permission to do so.

## Critique

*Reviewed 2026-07-09.*

- **Use Postgres 18 + native `uuidv7()`, drop the app-side callback.**
  PG18 ships `uuidv7()` built-in — `id: :uuid, default: -> { "uuidv7()" }`
  gives DB-level generation that also covers raw SQL/bulk inserts and
  removes the ApplicationRecord callback entirely
  ([practical guide](https://chayuto.com/blog/rails-8-uuidv7-postgresql-primary-key/),
  [Hashrocket](https://hashrocket.com/blog/posts/postgresql-18-s-uuidv7-faster-and-secure-time-ordered-ids)).
  The docker-compose image should be `postgres:18`, not 17. Keep the Ruby
  fallback note only for hosts stuck below 18 (ours isn't).
  Caveat to document: UUIDv7 embeds creation time — fine for us; cue
  creation time is already visible in-app.
- **`rails new` should target 8.1** (see plan_1 critique).
- Committing pristine generator output before customizations: good
  practice, keep it.
- Otherwise no critique.

## Critique feedback
These are all great. Go with your critique.
