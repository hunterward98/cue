# organizations-users — Child Plan 3: Invitations & Approvals

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; notifications plan_2 (invitation emails)
- **Last updated:** 2026-07-08

## Goal

Both doors into an org work end-to-end: owner-sent email invitations
(auto-approved on acceptance) and request-to-join via org link (owner
approval queue) — with abuse limits and clean handling of the
existing-user vs new-user fork.

## Design

- **Invitation:** owner enters email(s) + role → `Invitation` record
  (org, email citext, role, inviter, token hashed, 14-day expiry,
  states: pending/accepted/expired/revoked) → email with accept link.
  Accept fork: existing signed-in user with matching email → membership
  created active immediately; no account → signup flow with email
  pre-bound (verification satisfied by the invitation token itself — the
  email link proves inbox control; document as an ADR since it shortcuts
  plan_2's verification).
  Mismatched signed-in email → clear switch-account screen.
- **Request-to-join:** org join link (`/join/:org_slug` — enabled/disabled
  per org setting, default ON for basic reality: an office admin shares a
  link in their team chat). Requester signs up/logs in → membership in
  `pending_approval` → owners see an approval queue (approve → role
  assignment, default requester; deny → membership destroyed, requester
  gets a neutral email).
- **Limits & abuse:** invites count against seat limits at send time
  (pending invitations reserve seats — prevents 20 invites on a 15-seat
  basic org); Rack::Attack throttle on invite sending and join requests;
  invitation emails identical whether or not the address has an account.
- **Member management UI (owner):** list with role/state/last-active,
  role changes (through the entitlements seam), deactivate/reactivate,
  revoke pending invitations, resend (regenerates token, kills old one).

## Implementation steps

- [ ] Invitation model + token discipline + expiry sweeping job.
- [ ] Send/accept flows incl. both forks + switch-account screen.
- [ ] Join-link setting + request flow + approval queue UI.
- [ ] Seat reservation logic at the entitlements seam.
- [ ] Member management UI (mobile-tested — owners will approve from
      phones).
- [ ] Emails (via notifications plan_2 infrastructure; letter_opener
      until provider is live).

## Tests

- Negative: expired/revoked/reused invitation token → friendly dead-end,
  no membership; accept with mismatched account → no membership until
  switch; 16th seat via invite on basic → blocked at send; join request to
  disabled link → 404; approval by a non-owner → 403/404; invitation
  email content identical for existing vs new addresses.
- Fork matrix system tests: {existing user, new user} × {invitation,
  join request} — four end-to-end paths, both viewports.

## Open questions

1. **Do pending invitations reserve seats?** — (a) yes **8/10**: honest
   about limits, no surprise at accept time; (b) no, check at accept
   **5/10**: nicer sending UX, ugly "org is full" rejection for the
   invitee — the worse first impression.
2. **Default role on join-link approvals** — (a) requester always,
   owner upgrades after **9/10**; (b) owner picks at approval time
   **6/10**: one more decision in the queue UI; fine to add later.

## Critique

*Reviewed 2026-07-09.*

- Invitation-token-satisfies-verification is sound (the email link
  proves inbox control — same assurance as a verification email) and
  correctly ADR'd. No critique on the core flows.
- **Add a per-inviter throttle, not just per-org/IP** — a compromised
  member account bulk-inviting is the abuse case the org-level throttle
  misses.
- Seat reservation by pending invites (O4a) will confuse owners when
  "you have 15 members" shows 12 + 3 ghosts — make the member list show
  reserved seats explicitly ("3 invitations pending — these hold
  seats"), or the support tickets write themselves.
- Deny emails ("neutral email" on join denial): keep it genuinely
  neutral — no org name in the denial? No: the requester asked to join,
  they know the org. Fine as designed.
