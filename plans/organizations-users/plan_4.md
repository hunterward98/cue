# organizations-users — Child Plan 4: Org Settings Surface

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_3, theming plan_3 (components)
- **Last updated:** 2026-07-08

## Goal

The org owner's home for everything org-wide: profile, member management
entry point, product defaults, and the danger zone. Billing and theme
panels dock here later (their plans own the panel contents; this plan owns
the frame).

## Design

- **Settings layout:** `/o/:slug/settings` with a side-nav (mobile:
  accordion) — sections: Profile, Members (plan_3's UI docks here),
  Defaults, Theme (theming plan_4 docks), Billing (billing plan_4 docks),
  Danger zone. Owner-only; board owners/requesters get 404 on the
  namespace (negative-tested), except their own per-board settings which
  live with boards/cues plans, not here.
- **Profile:** org name (mutable), slug (immutable v1, displayed with
  copy-able join link when enabled), logo upload placeholder (activates
  with theming plan_4).
- **Defaults:** cue field toggles org-wide baseline (consumed by cues
  plan_3 — this page just edits `settings` jsonb through a typed form
  object, no stringly-typed writes), default board cap (boards plan_2
  consumes), new-cue notification fan-out (notifications plan_4 consumes),
  join-link on/off (plan_3).
- **Danger zone:** org deletion (soft-delete per plan_2 Q1) behind a
  type-the-org-name confirmation, destructive-red per design standards;
  export-my-data stub — see Q1.
- Every settings write → an audit event (org_events or reuse pattern from
  database plan_3 conventions) so owners can answer "who changed the
  default cap?".

## Implementation steps

- [ ] Settings frame + navigation + authorization.
- [ ] Profile section.
- [ ] Defaults section with typed settings form object (jsonb shape
      validated — malformed settings unrepresentable).
- [ ] Danger zone with deletion flow + grace-period email.
- [ ] Org settings audit events + a simple "changes" list in the frame.
- [ ] Mobile system tests (accordion nav, all sections reachable ≤2 taps).

## Tests

- Negative: non-owner on any settings route → 404; malformed settings
  payload (unknown key, wrong type) → rejected by form object; deletion
  without exact name match → refused; deleted org's routes → 404 for all
  members during grace (except restore banner for owners).
- Settings write → audit event asserted (append-only shared example).

## Open questions

1. **Data export (org owner)** — (a) defer, ship with billing/enterprise
   push, design the button now **7/10**: real feature, zero MVP users need
   it day one; (b) MVP CSV-of-cues export **6/10**: cheap and
   trust-building, but scope creep; (c) never **1/10**: lock-in smell,
   contradicts the trust posture.
2. **Slug immutability** — (a) immutable v1 **8/10**: join links and
   bookmarks never break, rename = support ticket (support console can do
   it with an audit trail later); (b) mutable with redirects **5/10**:
   redirect bookkeeping now for a rare want.

## Critique

*Reviewed 2026-07-09.*

- No critique on structure, typed settings form object, or the danger
  zone ceremony.
- One addition: the org settings audit trail ("who changed the default
  cap?") is designed as maybe-reuse of the events pattern — make it
  definite. Owners *will* ask; billing disputes ("who downgraded us?")
  make it load-bearing later. One `org_events` table now, same
  append-only shared example, done.
- O7 (immutable slugs): stands, with the support-console rename path as
  the escape hatch — ensure that rename op (support-admin scope) writes
  redirects or invalidates join links explicitly when it eventually
  exists; note it in the support tooling matrix row rather than leaving
  it implied.
