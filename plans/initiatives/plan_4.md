# initiatives — Child Plan 4: Navigation UX & Cue Linkage Surface

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_3; cues plan_6 (badge dock on detail)
- **Last updated:** 2026-07-08

## Goal

The master plan's specified navigation loop made real: cue shows an
initiative badge → tap → initiative workspace → left-rail "cues" button →
all linked cues → back. Plus the workspace layout and initiative index.

## Design

- **Initiative index (`/o/:slug/initiatives`):** card grid — title,
  summary (this is why summaries are required — the index is readable),
  linked-cue count, contributors, updated-at; archived toggle; create
  flow (title + summary, in-context tutorial line explaining what
  initiatives are for).
- **Workspace layout (`/o/:slug/initiatives/:id`):** left rail (master
  plan): tree navigation + the **"cues" button** — a peer of the tree,
  not buried; main pane renders the selected node (document view/edit,
  asset grid, folder listing). Breadcrumbs from path cache. Summary
  editable in the header. Mobile: rail = Drawer; "cues" button surfaces
  in the header bar (the loop must work one-handed).
- **Cues panel:** linked cues listed with status badges/stake chips,
  grouped active/completed; each navigates to cue detail. Link-a-cue
  affordance here too (search typeahead, same component as cues plan_7
  linking — reuse, not reinvention).
- **Cue-side badge (docks into cues plan_6 detail):** initiative badge
  near the header (name, tap → workspace). Linking/unlinking a cue ↔
  initiative: board owners + org owners, from either end; emits
  CueEvent(initiative_linked/unlinked) for the activity tab + metrics.
- **Round-trip budget:** cue → initiative → cues panel → another cue ≤ 3
  taps (mobile plan_2 budget test).

## Implementation steps

- [ ] Index + create flow + archive toggle.
- [ ] Workspace layout + rail/Drawer + node routing + breadcrumbs.
- [ ] Cues panel + link/unlink from both ends + events.
- [ ] Badge dock on cue detail.
- [ ] Round-trip system test at both viewports (the loop is the
      feature — test it as one journey).

## Tests

- Negative: link across orgs → rejected; requester link attempt →
  denied (pending parent Q2 outcome for reads stands regardless —
  linking is owner-tier); basic-tier badge render → absent (gate);
  unlink removes badge + panel entry atomically.
- Panel grouping correctness (active/completed) against seeded mixed
  statuses; index summary truncation renders safely (no mid-entity
  cuts).

## Open questions

None new — the two schema joints (single/multi, requester access) are
parent Q1/Q2; this plan renders whichever answer lands.

## Critique

*Reviewed 2026-07-09.*

- The navigation loop (badge → workspace → cues panel → cue) matches
  the master plan's specified UX beat-for-beat, and the round-trip tap
  budget makes it testable. No critique on the core.
- Required-summary powering the index cards is a nice closure of the
  master plan's "must have a summary" rule — surface the summary
  *quality* gently at creation ("one sentence people will see on the
  index") rather than accepting "asdf"; a min-length validation (say,
  20 chars) is the cheap version.
- Mobile: the left rail as Drawer is right; ensure the "cues" button
  survives INTO the drawer trigger bar (not buried inside the drawer) —
  the loop's mobile budget depends on it, and the plan already hints
  at this ("surfaces in the header bar"); making it a hard requirement.
