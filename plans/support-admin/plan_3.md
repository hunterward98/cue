# support-admin — Child Plan 3: User-Support Operations

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED (Phase 2,
  with auth flows live — the MVP support burden is auth problems)
- **Depends on:** plan_2, auth-security plans 2–3
- **Last updated:** 2026-07-08

## Goal

The operations that answer the first hundred support emails: find the
user, resend verification, unlock the account, kill sessions, fix a
mistyped email — each audited, each with guardrails.

## Design

- **User lookup:** by email/name → account metadata (verified?, locked?,
  lockout history from auth_events, active session count, org
  memberships + roles, suppression status). Same allowlist-serializer
  discipline as plan_2 — no content, and auth_events shown are the
  user's own security events (that's support-necessary metadata).
- **Operation set (each: confirm dialog + reason field required +
  support_event + where noted, notification to the affected user — 
  silent support mutations breed distrust):**
  - Resend verification (throttle-bypass flag audited).
  - Unlock account (auth plan_3 lockout) — notifies user.
  - Revoke sessions (all or one) — notifies user ("a support agent
    signed you out — if you didn't ask us to, reply").
  - Email change assist: sets a pending email + verification to the NEW
    address + notice to the OLD (the account-takeover-resistant order;
    completes only on new-address verification) — the highest-risk op
    here, hence the ceremony.
  - Clear email suppression (post-bounce recovery after the user fixes
    their inbox).
- **Guardrails:** staff cannot operate on their own account or on other
  staff accounts via this surface (peer/self changes go through the
  console task path with its heavier ceremony — see Q1); operations on
  users in orgs the staff member personally belongs to get an extra
  confirm naming the conflict (small-world hygiene for a small company).
- **Rate/anomaly visibility:** support_events browser (plan_2) gains
  filters per action type — the volume of unlock/email-change ops is
  itself a security signal the phase review (auth plan_5) reads.

## Implementation steps

- [ ] Lookup + serializer + introspection spec.
- [ ] The five operations (each: service + dialog + reason + event +
      user notification + specs before the next one starts).
- [ ] Guardrails (self/staff/conflict-of-interest checks).
- [ ] Event-browser filters.
- [ ] Runbook: `docs/runbooks/support-ops.md` — when to use which op,
      verification questions to ask a requester before email-change
      (social-engineering counterscript).

## Tests

- Per operation: happy path + reason-missing rejection + event emission
  + user notification content (no sensitive echo) + the negative twins
  (unlock on unlocked account = no-op no-event; resend on verified user
  = refused).
- Guardrails: self-op → rejected; staff-target → rejected; conflicted
  org → extra-confirm path asserted.
- Email change: old address always notified; change without new-address
  verification never completes (time-travel past expiry → reverts).

## Open questions

1. **Staff-on-staff operations** — (a) console tasks only (out of the
   web surface entirely) **8/10**: the web console compromise scenario
   shouldn't be able to unlock/redirect other staff; (b) allowed with
   dual-confirm **4/10**: convenience against the exact threat model
   that matters.

## Critique

*Reviewed 2026-07-09.*

- Reason-required ops, user notifications on support actions, the
  takeover-resistant email-change order (verify new, notify old), and
  staff-on-staff pushed to console-only (SU4a): no critique — this op
  set matches how account-takeover actually happens at small SaaS
  companies.
- One addition: the runbook's social-engineering counterscript should
  include a hard rule — **support never asks for or accepts codes/
  passwords from users** (attackers coach victims to relay codes);
  print it in the email templates' footer too ("we will never ask for
  this code"). Cheap, and it inoculates the user base early.
