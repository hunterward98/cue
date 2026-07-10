# database-architecture — Child Plan 2: Conventions & Tenancy Guardrails

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** foundation plan_2
- **Last updated:** 2026-07-08

## Goal

Bake the data-layer rules into machinery: every tenant table is org-scoped
and cross-org access is structurally hard; N+1s fail tests; unsafe
migrations are rejected. Downstream plans inherit all of it silently.

## Design

- **Tenancy:** `Current.organization` (ActiveSupport::CurrentAttributes)
  set from the authenticated membership in a controller concern. Tenant
  models include `OrganizationScoped`: validates presence of
  `organization_id`, provides `for_current_org` scope. **No default_scope**
  (footgun: leaks into callbacks/joins unpredictably); instead a custom
  RuboCop cop flags any `.where`-bearing query on a tenant model in
  app code that isn't rooted in `for_current_org` or an association from an
  already-scoped record. Controllers load through
  `Current.organization.<assoc>` — the idiom the cop enforces.
- **N+1:** `config.active_record.strict_loading_by_default = true` in dev
  + test; Bullet raising in test. Escape hatch: explicit
  `.strict_loading!(false)` with a required inline justification comment
  (cop-checked).
- **Migration safety:** strong_migrations gem; FK required on every
  `_id` column (migration lint task scans schema for missing FKs and
  missing indexes on FKs).
- **Column rules:** NOT NULL default; check constraints for enum columns
  (Rails `enum` + DB constraint both); `citext` for emails; timestamps
  always. annotaterb keeps schema visible in models.
- **UUIDv7 pk** convention verified here with a sortability test.

## Implementation steps

- [ ] `Current` + `OrganizationScoped` concern + controller wiring.
- [ ] Tenancy RuboCop cop + justification-comment cop.
- [ ] strict_loading + Bullet config.
- [ ] strong_migrations + FK/index lint rake task in CI.
- [ ] annotaterb; `docs/database.md` conventions doc (audience line first).
- [ ] Demo tenant model (can be a throwaway `Widget` deleted when real
      models land, or wait for organizations-users plan_2 — prefer waiting
      if sequencing allows) to exercise every guardrail.

## Tests

- Negative: query on tenant model without org scoping → cop failure
  (fixture-tested cop specs); cross-org record fetch via `for_current_org`
  returns nothing; N+1 introduced in a controller spec → Bullet raises;
  migration adding `_id` without FK → lint task fails; null org_id insert →
  DB rejects.
- UUIDv7: two records created in sequence sort by id in creation order.

## Open questions

1. **Tenancy enforcement depth** — (a) idiom + cop as designed **8/10**:
   simple, no runtime magic, testable; (b) acts_as_tenant gem **6/10**:
   battle-tested but default-scope-based magic we'd fight later;
   (c) Postgres RLS (row-level security) **5/10**: strongest guarantee but
   real operational complexity with pooled connections — documented as the
   "tomorrow" upgrade if we ever multi-tenant harder.

## Critique

*Reviewed 2026-07-09.*

- **The custom RuboCop cop is the fragile part.** Node-matcher cops that
  reason about "queries rooted in `for_current_org`" are hard to write,
  harder to keep false-positive-free, and disabled comments will breed.
  Demote the cop to best-effort; promote the **request-spec sweep** to
  the load-bearing guard: a shared example run against every org-scoped
  route asserting cross-org access → 404 (self-strengthening — new
  routes get covered automatically, like the append-only and read-only
  sweeps elsewhere). The cop can arrive later via the gotcha protocol if
  a leak class appears twice.
- `strict_loading_by_default` will bite mailers/jobs that lazily walk
  associations — expect and budget for a first-week flurry of explicit
  `includes`; that pain is the feature.
- No critique on no-default_scope (right call — default scopes leak into
  callbacks and joins unpredictably) or on strong_migrations.
