# CLAUDE.md — the agent contract

Cue: a snarky-but-classy Jira replacement for single-person departments.
Roadmap and status: [plans/README.md](plans/README.md) ·
Why things are the way they are: [docs/decisions/](docs/decisions/) ·
Current phase: 1→2 (foundation/auth/orgs/theming core done; cues next,
pending review).

## Commands

- `bin/setup` — idempotent bootstrap (deps, .env, Docker Postgres 18, db).
- `bin/dev` — Rails + Vite dev servers.
- `bundle exec rspec` / `parallel_rspec spec` — backend tests.
- `pnpm test` · `pnpm check` · `pnpm lint` · `pnpm doctor` — frontend.
- `bin/rubocop` · `bin/brakeman` — Ruby lint/security.
- `CI=1 bundle exec rspec && bin/rails coverage:check` — the coverage gate.

## Standing rules

- 100% line+branch coverage, merged before gating; **no :nocov:, ever**
  (ADR 0008). Details + verified-failure log: [docs/testing.md](docs/testing.md).
- Negative tests (`:negative`, "rejects/forbids/fails …") wherever
  behavior could be abused. Shrinking tally = review flag.
- System specs wrap flows in `with_each_viewport` (cop-enforced).
- No `any`, no unexplained ts-expect-error, no fetch/axios in
  app/frontend — Inertia props are the only data path (ESLint-enforced;
  ADRs 0001, 0006).
- No hardcoded colors in components — everything through theme tokens
  (theming plans own the token system; rule becomes lint-enforced there).
- UUIDv7 pks come from Postgres defaults; never add id-generation
  callbacks (ADR 0003).
- Every architectural choice → ADR (template in docs/decisions/);
  user-facing copy follows [docs/design/voice.md](docs/design/voice.md):
  a little snarky, never mean.
- The lint IS the rule: don't restate lint-enforced rules here.

## Rituals

- **Session end (plan hygiene):** update touched plans' Progress/Status,
  sync the plans/README.md table, refresh `manual_steps_*.md`, and call
  out new manual steps in the closing message.
- **Gotchas:** second occurrence of any problem → docs/gotchas.md entry
  - a mechanism (rule/cop/test/skill). Skill misfire → same-day entry in
    [docs/skill-misses.md](docs/skill-misses.md) + rewrite its trigger.
- Commits: plain, well-summarized messages (no conventional-commit
  ceremony). Pre-commit hooks are lefthook; CI is the wall.
