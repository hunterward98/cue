# This is Cue.

## Cue is a solution for single-person departments.
This was inspired by someone very close to me and hearing their struggles. The majority of this app was built with their experiences in mind - a single person, in charge of all graphic design, or in charge of all marketing, or in charge of all things IT; you get the idea.

## Quickstart

Prerequisites: [Docker](https://docs.docker.com/engine/install/) and
[mise](https://mise.jdx.dev/getting-started.html).

```sh
git clone <repo> cue && cd cue
mise install   # Ruby, Node, pnpm — pinned in mise.toml
bin/setup      # deps, .env, Dockerized Postgres 18, DB create/migrate, then boots bin/dev
```

The app runs at <http://localhost:3000>. `/up/full` is a deep health check
proving the whole Rails → Inertia → React → Tailwind → DB round-trip.

Day-to-day: `bin/dev` (Rails + Vite with HMR), `bin/setup --skip-server`
(re-sync after pulling).

## Stack

Rails 8.1 · Inertia.js · React 19 (TypeScript, strict) · Tailwind CSS v4 ·
Vite · Postgres 18 (UUIDv7 primary keys) · Solid Queue/Cache · Kamal.

Start at [CLAUDE.md](CLAUDE.md) for the working agreements,
[plans/](plans/) for the roadmap, and [docs/decisions/](docs/decisions/)
for why things are the way they are.
