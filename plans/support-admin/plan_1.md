# Parent Plan: Support & Admin Tooling

- **Status:** NOT_STARTED
- **Phase:** cross-cutting — console skeleton lands with Phase 1–2; every
  feature adds its tooling row as it ships
- **Depends on:** auth-security (staff auth + 2FA), organizations-users
- **Blocks:** no feature is DONE until its tooling matrix row is checked
- **Last updated:** 2026-07-08

## Objective

A platform-level **support** role — us, the business operators — manages all
customers/organizations from an internal console. Beyond the console, every
feature ships tooling at the right tier: support (platform), org owner
(billing/membership), board owner (their board). This plan owns the console
and the tooling matrix that tracks all three tiers across features.

## Role model (ratified 2026-07-08)

| Role | Scope | Lives on |
|------|-------|----------|
| **support** | entire platform: all orgs, billing, users | global staff flag on `User` — NOT an org membership |
| **org owner** | one org: billing, membership, org settings, themes | `Membership.role = owner` |
| **board owner** | their board + their cue configuration | `Membership.role = board_owner` |
| **requester** | submit/track cues, comment | `Membership.role = requester` |

(The organizations-users plan previously called org owner "admin" — renamed
to `owner` to keep "admin" unambiguous now that support exists.)

## Key decisions

### Recommended

1. **`/support` namespace inside the same Inertia app** — no ActiveAdmin/
   Administrate/Avo (they're a second, erb-centric UI stack that would break
   design cohesion and the react-doctor/token gates). Reuse the component
   library; support screens are just more tested React.
2. **Support security exceeds user security:** staff flag can only be set
   via console (`bin/rails support:grant`, audited), never via web UI; 2FA
   is **mandatory for staff from day one** — the one part of the "2FA
   post-MVP" plan that jumps the queue; every support action writes to an
   append-only `support_events` audit table.
3. **Metadata by default, break-glass for content.** Support sees org names,
   member counts, subscription state, usage numbers — never cue content,
   comments, files, or initiative documents. Content access requires an
   explicit break-glass action with a typed reason, is fully audited, and
   (recommended) notifies org owners. Master plan's privacy strictness
   applied to ourselves.
4. **No impersonation at v1.** A read-only "view as" may come post-MVP under
   break-glass rules; write-as-user never.
5. **The tooling matrix below is the enforcement mechanism** for "each
   feature needs admin tooling": feature plans don't restate it; a feature's
   parent plan is only DONE when its matrix row is fully checked or marked
   n/a with a reason.

## Tooling matrix

Checkboxes are the live tracker. `—` = not applicable by design.

| Feature | Support console | Org owner | Board owner |
|---|---|---|---|
| organizations-users | [ ] org index/search/detail, lock org, member listing | [ ] invite/approve/remove members, roles | — |
| auth-security | [ ] resend verification, unlock account, session revoke | [ ] require-2FA org setting (post-MVP) | — |
| billing | [ ] view subscription, extend trial, comp account, refund (Stripe deep-link), read-only override log | [ ] plan selection, payment portal, invoices, upgrade/downgrade | — |
| cues | [ ] usage counts + limits view (no content) | [ ] org-wide field defaults | [ ] categories, priorities, numbering, hooks, field toggles |
| boards-workflow | [ ] boards-per-org overview (counts only) | [ ] default board cap, all-boards overview | [ ] own cap, board settings |
| notifications-email | [ ] delivery/bounce status per org, suppression list | [ ] new-cue fan-out setting | [ ] own notification prefs |
| initiatives | [ ] count/storage usage per org (no content) | [ ] enable/manage initiatives | [ ] create/edit |
| theming | [ ] preview org theme (chrome only) | [ ] theme picker, logo upload | — |
| metrics-insights | [ ] platform metrics (orgs, DAU, cue volume) | [ ] org insights page | [ ] board insights page |
| marketing/feedback | [ ] feedback + bug-report triage queue | — | — |
| support-admin itself | [ ] staff management, support_events audit browser | — | — |

## Child plans to create

- `plan_2.md` — Console skeleton: staff flag + grant task, `/support` auth
  wall with mandatory 2FA, `support_events` audit table, org index/detail
  (metadata only). Lands late Phase 1 / early Phase 2.
- `plan_3.md` — User-support operations: resend verification, unlock,
  session revoke, email-change assist (Phase 2, with auth flows live).
- `plan_4.md` — Billing operations: trial extension, comping, refund flow,
  entitlement override with expiry + audit (Phase 3, with billing plan).
- `plan_5.md` — Break-glass mechanism + org-owner notification, feedback
  triage queue (Phase 3–4).

## Implementation order

1. [ ] plan_2 skeleton (after auth-security plan_2; staff 2FA piggybacks on
   the email-code mechanism, built early for staff only).
2. [ ] plan_3 user-support ops (MVP support burden is auth problems).
3. [ ] plan_4 billing ops (with Phase 3).
4. [ ] plan_5 break-glass + triage.
5. [ ] Continuous: check matrix rows as features ship.

## Test strategy

- Negative tests: non-staff hits `/support` → 404 (not 403 — don't reveal it
  exists); staff without 2FA enrolled → blocked at wall; any content
  endpoint without break-glass → fail; break-glass without reason → fail;
  every support mutation asserts a `support_events` row (a mutation without
  audit is a test failure by convention).
- Staff flag escalation attempts via mass-assignment/params → negative
  tested.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Console skeleton live (staff 2FA enforced)
- [ ] User-support ops shipped
- [ ] Billing ops shipped
- [ ] Break-glass + triage shipped
- [ ] Tooling matrix current with all shipped features

## Open questions

1. Notify org owners on break-glass content access? (Recommendation: yes —
   it's a trust feature worth advertising in the privacy policy.)
2. Support role granularity — read-only support vs full support?
   (Recommendation: single full tier now; split when there's a second
   support human.)

## Critique

*Reviewed 2026-07-09.*

- Metadata-by-default with audited break-glass, no admin gem, mandatory
  staff 2FA, and the tooling matrix as a completion gate: no critique
  on the architecture — this is the privacy posture the master plan
  demands, applied to ourselves.
- If B10 (enterprise differentiation) adopts capability-based
  differentiators, several land in this plan's orbit (audit-log export,
  break-glass digest reports, org-required-2FA) — the tooling matrix
  gains rows. Sequence B10 before support plan_4 to avoid rework.
- One matrix gap found in review: **org slug rename** (organizations
  plan_4 critique names support as its escape hatch) has no matrix
  cell. Add it to the organizations-users row (support console op,
  audited, with join-link invalidation).
