# support-admin — Child Plan 2: Console Skeleton

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** auth-security plan_2 + plan_4 mechanism (staff 2FA),
  organizations-users plan_2
- **Sequencing:** late Phase 1 / early Phase 2 — before external users
  exist, so support tooling never lags the support burden.
- **Last updated:** 2026-07-08

## Goal

The staff door and the first room: staff flag with an audited grant path,
the `/support` wall (2FA-mandatory, 404 to everyone else), the
append-only `support_events` audit, and the org index/detail showing
metadata only.

## Design

- **Staff flag:** `users.staff` boolean, settable ONLY via
  `bin/rails support:grant[email]` / `support:revoke[email]` (console
  task requiring typed confirmation, writing a support_event with
  grantor from an env-identified operator). No web path to staffhood —
  negative-tested including mass-assignment sweeps on every user-facing
  endpoint (a request-spec shared example: `staff: true` in any params
  hash never persists).
- **The wall:** `/support` namespace controller base — requires staff +
  second factor on the current session (auth plan_4's
  `second_factor_at`, no trusted-device exemption for staff) + re-prompt
  after 12h idle. Non-staff (or staff pre-2FA): 404 — indistinguishable
  from a route that doesn't exist (parent decision; no redirect, no 403,
  no different timing — negative-tested).
- **support_events:** append-only (database plan_3 shared example) —
  actor (staff user), action, target (polymorphic: org/user/
  subscription), `data` jsonb, reason (nullable at v1; required by
  specific actions in plan_3/4/5), created_at. Written via one helper
  every support mutation must call — a cop flags support-namespace
  writes lacking it (the audit-or-it-didn't-happen rule made
  mechanical).
- **Console chrome:** distinct visual treatment — support-mode banner
  color from a dedicated token (staff always know which hat they're
  wearing; screenshots are unambiguous in incident reviews). Same
  component library underneath (parent's no-admin-gem decision).
- **Org index/detail (metadata only):** index — search by name/slug,
  filters (tier, subscription state, created, activity recency); detail
  — org profile, member list (names/emails/roles/states — membership
  metadata is support-necessary and is NOT break-glass; content is),
  subscription summary, usage counters (cues total/active, storage,
  boards), email suppression status (notifications plan_2), recent
  support_events on this org. **No cue titles, no content fields** —
  the serializer for support views is a distinct allowlist struct
  (drift-proof: a spec introspects it against a forbidden-field list).

## Implementation steps

- [ ] Flag + grant/revoke tasks + audit wiring.
- [ ] Wall (staff + 2FA + idle re-prompt) + 404 behavior.
- [ ] support_events + helper + cop.
- [ ] Console chrome + support token + navigation shell.
- [ ] Org index/detail on allowlist serializers.
- [ ] Staff-fixture factories + the persona addition to the test suite
      (support staff joins the four personas in permission matrices).

## Tests

- Negative (the heart of this plan): non-staff `/support` → 404
  byte-indistinguishable from unknown routes; staff without second
  factor → walled; mass-assignment staff escalation sweep; support
  serializer forbidden-field introspection; support mutation without
  event → cop failure; grant task without confirmation → aborts.
- Detail values reconcile with seeded truth (usage counters aren't
  estimates).

## Open questions

1. **Staff session idle re-prompt window** — (a) 12h **7/10**: daily
   re-verify without intra-day nagging; (b) 4h **6/10**: tighter, four
   prompts a workday; (c) per-login only **4/10**: long-lived staff
   sessions are the exact thing to avoid.

## Critique

*Reviewed 2026-07-09.*

- **"404 byte-indistinguishable including timing" over-promises.** The
  staff-flag lookup + 2FA check inevitably cost different time than a
  bare route miss; true timing-indistinguishability is a research
  problem, not a sprint task. Restate the bar honestly: identical
  status, headers, and body; *no deliberate* timing oracle (constant
  work where cheap). The negative test asserts content-identity, not
  nanoseconds. Everything else — console-only staff grants,
  mass-assignment sweeps, audit-or-cop — stands without critique.
- The support-mode banner via a dedicated token is a small idea that
  will pay for itself the first time a screenshot lands in an incident
  doc — keep it.
