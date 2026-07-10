# initiatives — Child Plan 2: Models, Tree & Gating

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** cues plan_2, billing plan_2 (gate), organizations plan_2
- **Note:** two parent questions (single vs multi initiative per cue;
  requester write access) shape the schema — this plan stays design-level
  on those joints and concrete on the tree core.
- **Last updated:** 2026-07-08

## Goal

The initiative skeleton: org-wide workspaces with a required summary, a
Confluence-like node tree, cue linkage, and the premium gate — the
foundation plan_3 (documents) and plan_4 (navigation) build on.

## Design

- **Initiative:** org-scoped; title; **summary required** (master plan —
  model + DB NOT NULL + negative test); creator; archived flag
  (initiatives outlive campaigns; archive hides from index, preserves
  links); Active Storage cover slot deferred.
- **InitiativeNode:** tree via parent_id + materialized-path cache
  (`path` column maintained on move) + position; `kind` enum: folder |
  document | asset; name; kind-specific data joins arrive in plan_3
  (document body, asset attachment). Depth ≤ 5 (parent rec 8/10 —
  enforced on create/move), name unique among siblings. Move = reparent +
  path rebuild for subtree (small trees; simple recursive update in a
  transaction is fine at this scale — documented).
- **Folder delete:** requires empty, or explicit "delete contents"
  confirm cascading soft-delete — see Q1.
- **Cue linkage:** pending parent Q1 (single 8/10 vs multiple 5/10) —
  single: `initiative_id` on cues (simplest, badge UX implied);
  multiple: join table. Schema decision deferred to the answer; both
  keep the same read API (`cue.initiatives` returns 0..1 or 0..n) so
  plan_4's UI design proceeds regardless.
- **Permissions:** view = all active org members; create/edit initiative
  + tree = board owners + org owners; requesters read-only pending parent
  Q2 (rec 7/10). Same policy-object pattern as cues plan_2.
- **Gate:** `allows?(:initiatives)` — basic tier: index/detail/deep links
  → 404 (no content-shaped upsell leak; the FeatureLock upsell lives on
  the nav entry only); downgrade → initiatives frozen read-only, not
  hidden (consistent with cues plan_7 Q2's never-vandalize rule — see Q2).

## Implementation steps

- [ ] Await/confirm parent Q1+Q2 (schema joints); everything below is
      answer-independent.
- [ ] Initiative model + summary constraint + archive.
- [ ] Node tree + path maintenance + depth/sibling rules + move
      operation.
- [ ] Folder delete semantics (Q1).
- [ ] Policies + gate (404 behavior) + downgrade freeze.
- [ ] Factories: initiative-with-tree (the workhorse for plan_3/4 specs).

## Tests

- Negative: no summary → invalid + DB reject; depth 6 → rejected;
  sibling name collision → rejected; cycle via move (node into own
  subtree) → rejected; basic-tier deep link → 404; requester create
  (pending Q2) → denied; cross-org node reparent → rejected (tenancy).
- Path cache: property-style spec — after arbitrary move sequences,
  paths match recomputed truth.

## Open questions

1. **Folder delete** — (a) require-empty, offer "delete all inside"
   confirm with typed count ("delete 14 items") **8/10**: no accidental
   subtree loss; (b) always cascade with confirm **5/10**; (c) forbid
   deleting non-empty **4/10**: creates junk-drawer folders.
2. **Downgrade behavior** — (a) frozen read-only **8/10**: consistent
   with the linking rule; (b) 404 like never-had-it **3/10**: their
   marketing materials vanish — support fire guaranteed.

## Critique

*Reviewed 2026-07-09.*

- Adjacency + materialized-path with depth ≤5 and transactional subtree
  rebuild: right-sized (ltree would be over-tooling at this depth). No
  critique on the tree core.
- **Sibling-name uniqueness needs a case rule:** "Assets" and "assets"
  as siblings is confusion, not flexibility. Case-insensitive
  uniqueness (citext or a lower() unique index) — one line now, one
  less head-scratcher later.
- Basic-tier deep links → 404 (no content-shaped upsell leak) while the
  *nav entry* carries the FeatureLock upsell: this split is correct and
  subtle — write one sentence in the implementation explaining WHY the
  404 (never confirm a gated resource exists), or a future contributor
  will "helpfully" turn it into an upsell page.
- Archived-not-deleted + downgrade-freeze (I5a): consistent with the
  never-vandalize rule; no further critique.
