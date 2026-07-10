# 0010 — Tenancy: acts_as_tenant + request sweep + composite FKs

- **Date:** 2026-07-10 (question D1; user asked for re-evaluation at
  implementation time, leaning toward the gem)
- **Status:** accepted

## Context

Single-database, org-scoped tenancy (ratified 2026-07-08). The original
design was a hand-rolled scoping idiom guarded by a custom RuboCop cop;
the plan_2 critique itself demoted that cop as fragile
(false-positive-prone node matching, disable-comment breeding), which
guts the idiom option's enforcement story. The alternative was
acts_as_tenant.

## Decision

Three independent layers:

1. **acts_as_tenant** for runtime scoping — `acts_as_tenant :organization`
   on tenant models, tenant set per-request from the authenticated
   membership.
2. **Request-spec sweep** (load-bearing test guard): every org-scoped
   route asserts cross-org access → 404; plus the self-strengthening
   schema-conformance spec (org_id NOT NULL + FK + index on every table
   that has the column — including future ones). Every tenant table
   carries organization_id even when reachable through a parent; the
   denormalization is deliberate.
3. **Composite tenant FKs on the hot spine** (cue→board, comment→cue,
   cue_event→cue, node→initiative): children FK on
   `(parent_id, organization_id)` against the parent's
   `UNIQUE (id, organization_id)` — the DB itself proves parent and
   child share a tenant, closing the cross-org-write hole app scoping
   can't.

## Why

For a codebase written primarily by AI, automatic query scoping beats
discipline-based idiom: the failure mode of a forgotten
`for_current_org` is silent data leakage, while acts_as_tenant's is loud.
The gem is battle-tested and maintained; its default-scope magic is a
real cost, but it's bounded and the two structural layers don't depend
on it. Postgres RLS remains the documented "multi-tenant harder"
upgrade.

## Revisit when

acts_as_tenant fights Solid Queue/jobs or Rails upgrades twice (gotcha
threshold), or an enterprise isolation requirement arrives (→ RLS).
