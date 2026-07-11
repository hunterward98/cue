# Parent Plan: Organizations & Users

- **Status:** NOT_STARTED
- **Phase:** 1
- **Depends on:** auth-security, database-architecture
- **Blocks:** cues, boards-workflow, billing
- **Last updated:** 2026-07-08

## Objective

The tenancy and role model: organizations, membership, approval, and the two
core roles — a small number of **board owners** (assignees) and a large number
of **requesters**. Every feature downstream keys off this model.

## Scope (from master_plan.md)

- Users must be approved members of an org to see anything in it.
- Roles: board owner (has own board, controls it, moves items from backlog),
  requester (submits cues, comments, views own requests), plus **org owner**
  (manages billing, membership, org settings, themes — ratified 2026-07-08).
  A platform-level **support** staff role also exists but is NOT an org
  membership — see [support-admin](../support-admin/plan_1.md) for the full
  role model and the tooling each role gets per feature.
- Tier limits enforced here: basic = 15 users / 2 board owners, premium =
  200 / 10, enterprise = unlimited owners, min 100 users (enforcement logic
  lives in billing's entitlements, checked at membership mutation time).

## Key decisions

### Recommended

1. **Model:** `Organization`, `User` (global identity), `Membership` (join:
   user ↔ org, holds `role` and `state`). A user can belong to multiple orgs
   (a freelance designer serving two offices) — memberships make this free.
2. **Roles on membership:** `owner`, `board_owner`, `requester` ("owner"
   rather than "admin" so "admin" stays unambiguous now that platform-level
   support staff exist). Org owners may also be board owners (flag, not a
   separate role). The support role is a global staff flag on `User`, owned
   by the support-admin plan — it must never be expressible as a membership
   role (negative test here).
   Feedback: good callouts.
3. **Joining flows:** (a) email invitation from an admin — auto-approved on
   acceptance; (b) request-to-join by org slug/link — requires owner
   approval. Both end in `Membership.state = active`.
4. **Org settings owned by this plan:** name, slug, logo, default ticket-field
   toggles (cues plan consumes), theme selection (theming plan consumes).
5. Limits enforced with DB-level checks + application validation + negative
   tests (e.g. 3rd board owner on basic tier must fail at both layers).

## Child plans to create

- `plan_2.md` — Models + tenancy wiring (Organization, Membership, roles,
  state machine, org-scoped queries proven by tests).
- `plan_3.md` — Invitation & approval flows (emails, tokens, admin UI,
  member list management, removal/deactivation).
- `plan_4.md` — Org settings surface (profile, defaults; theme + billing
  panels arrive with their own plans).

## Implementation order

1. [ ] plan_2 models (blocking for cues).
2. [ ] plan_3 invitations/approvals.
3. [ ] plan_4 settings surface.

## Test strategy

- Negative tests: non-member sees nothing (404, not 403 — don't confirm org
  existence); deactivated member loses access immediately; role escalation by
  parameter tampering fails; over-limit membership mutations fail.
- Factory design here sets the pattern for the whole suite — invest in it.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Models merged
- [ ] Invitation/approval flows shipped
- [ ] Settings surface shipped
- [ ] Privacy policy updated for membership data

## Open questions

1. ~~Confirm the admin role addition.~~ **RATIFIED 2026-07-08** — yes, named
   **org owner**; the org creator is the first owner. Platform **support**
   role added alongside (see support-admin plan).
2. Can a requester see *all* cues in the org, or only their own requests +
   boards they're granted? Master plan says org members are "approved access
   to that organization" — recommendation: members see all org boards
   (simple), with a post-MVP option for restricted requesters.
   Answer: Make it a setting org owners can configure. By default, members see all org boards and cues.
3. Do board owners count toward the user limit? (Recommendation: yes.)
Answer: yes, need this sort of simplicity in our app.

## Critique

*Reviewed 2026-07-09.*

- **The default-visibility recommendation (O2a: everyone sees all cues)
  collides with the master plan's own IT use case.** "Help me reset my
  password," an HR-adjacent request, or a salary-related design brief
  should not be org-readable — and the master plan explicitly names IT
  password resets and "extremely sensitive information." Two better
  shapes than flipping O2 wholesale:
  1. **(Recommended)** Keep O2a's transparency default **and add a
     per-cue `confidential` flag** (visible to requester + board owners +
     org owners only). One boolean, one policy branch, a badge, and
     negative tests — small, and it resolves the tension instead of
     trading it. Added as question **O8** in questions.md.
  2. Default requesters-see-own-only (O2b) with an org-level
     "transparent mode" toggle — stronger privacy default, but it
     hollows out the small-team "what's Charlie working on" appeal that
     O2a's ranking was based on.
- Role model (owner / board_owner / requester + global support):
  validated; see plan_2 critique for a representation improvement.
- Otherwise no critique.

## Critique feedback:
I like the confidential idea, but do not think it will be used the way we think. Someone requesting a password reset because they forgot it, probably isn't going to know to use it. So, we may need "template requests" that board owners can create for common requests. They will be able to take in any cue and make it a template for other requesters to "request" and have them fill out certain fields specific to their case. We need a plan for this - make one and prioritize it within the relevant plans.