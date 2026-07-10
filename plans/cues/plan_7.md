# cues — Child Plan 7: Cue Linking & Custom Fields (Premium)

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_6; billing plan_2 (entitlement gates live)
- **Last updated:** 2026-07-08

## Goal

The two premium/enterprise cue powers: linking cues with easy
back-and-forth navigation, and board-owner-defined custom fields.

## Design

### Linking

- `cue_links` join (cue_a, cue_b, creator, created_at) with canonical
  ordering (lower uuid first) + unique constraint — A↔B stored once,
  queried both directions. Untyped links at v1 ("relates to" only —
  blocks/duplicates typing is Jira-creep; see Q1). Same-org only (DB +
  policy).
- UI: "linked cues" section on detail — Badge-chips (number + title +
  status) navigating on tap; add-link = typeahead search over org cues
  (number or title); remove by link creator or board owner. Master plan's
  "powerful but not cluttered": section absent when empty and gated.
- Gate: `allows?(:cue_linking)` — basic org: creation rejected at the
  seam; existing links (from a downgrade) remain visible but frozen
  (see Q2).

### Custom fields (per board owner)

- `BoardConfig.custom_fields` jsonb: ordered field definitions
  {key, label, type: text|select|number|date, options?, required?}.
  Max 10 per board. Values in `cues.custom_values` jsonb keyed by field
  key; validated against the definition at write (unknown key, wrong
  type, missing required → rejected).
- Definition changes: removing a field hides values (retained in jsonb —
  restore on re-add); renaming = label-only (key immutable); type changes
  disallowed (delete + recreate, confirm dialog explains).
- Rendered in create/edit and detail for cues on that owner's board;
  backlog cues (no board yet) don't carry custom fields — they apply
  from pull time (documented behavior).
- Gate: `allows?(:custom_fields)`; definitions UI locked on basic with
  the tasteful upsell state (theming plan_4 pattern).

## Implementation steps

- [ ] cue_links model + canonicalization + policy + gate.
- [ ] Link UI (section, typeahead add, remove) + navigation.
- [ ] custom_fields schema + validator + definitions UI (owner board
      settings) + value rendering in form/detail.
- [ ] Downgrade behavior for both features (billing plan_2 hooks).

## Tests

- Negative: basic-tier link creation → seam rejection (UI lock separately
  tested); duplicate link A↔B / B↔A → constraint; cross-org link →
  rejected; self-link → rejected; 11th custom field → rejected; value
  failing definition (bad option, wrong type, missing required) →
  rejected; custom-value write for a field not on that board → rejected.
- Link navigation system test: A → B → back to A within budget.

## Open questions

1. **Typed links** — (a) untyped v1 **8/10**: navigation is the feature;
   types are Jira-creep until a customer asks; (b) relates/blocks/
   duplicates **4/10**: three concepts to explain in a product allergic
   to clutter.
2. **Links on downgrade to basic** — (a) visible but frozen (no
   add/remove) **8/10**: never vandalize customer data on downgrade;
   (b) hidden until re-upgrade **4/10**: data hostage vibes; (c) deleted
   **1/10**.

## Critique

*Reviewed 2026-07-09.*

- **Custom select fields must store option IDs, not label strings.** As
  designed, `options: ["Urgent", "Later"]` with values stored as
  literals means renaming an option orphans every existing value. Make
  options `{id, label}` pairs (ids immutable, generated); values store
  ids; renames are label edits. Small schema change now, saves a data
  migration and a support ticket class later.
- **Required custom fields + backlog cues (fields apply at pull time)
  need one explicit UX beat:** the pull action must prompt for required
  custom fields the backlog cue can't have yet — otherwise "required"
  either blocks pulls confusingly or silently isn't. The pull dialog
  (boards plan_2/backlog plan_3 affordance) gains a required-customs
  step; write it into both plans' handoff.
- Canonical-ordered link storage + frozen-on-downgrade: sound; no
  further critique.
