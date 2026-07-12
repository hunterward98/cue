# organizations-users — Child Plan 3: Invitations & Approvals

- **Parent:** [plan_1.md](plan_1.md) · **Status:** DONE (2026-07-11) for
  single-invite send/accept/join/manage; bulk invitation (auth-security
  plan_2 Q2's "mailing lists" ask) is a known, flagged gap — see
  Implementation steps
- **Depends on:** plan_2; notifications plan_2 (invitation emails) — landed
  on the same letter_opener stopgap auth plan_2 already ships with, not
  blocked on notifications plan_2 actually starting
- **Last updated:** 2026-07-11

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

- [x] Invitation model + token discipline + expiry sweeping job
      (2026-07-11) — `Invitation`, `config/recurring.yml` sweep; redemption
      logic never trusts the stored state alone (`reserving_seat`/
      `redeemable?` both re-check `expires_at`), so correctness never
      depends on the sweep having run (AuthToken's precedent).
- [x] Send/accept flows incl. both forks + switch-account screen
      (2026-07-11) — `InvitationAcceptancesController`, invitation-backed
      fast path in `RegistrationsController` (skips verification, ADR
      0015), `after_authentication_url` extended to resume mid-flow
      invitation/join links after login (`Authentication` concern).
- [x] Join-link setting + request flow + approval queue UI (2026-07-11) —
      `JoinRequestsController` (`org/join` page); approval queue folded
      into the members page (below), not a separate screen.
- [x] Seat reservation logic at the entitlements seam (2026-07-11) —
      `Memberships::SeatChecks` now counts `Invitation.reserving_seat`
      alongside active memberships; `Invitations::Send` checks it at
      send time, `Invitations::Accept` flips the invitation to accepted
      *before* re-checking so its own reservation isn't double-counted.
- [x] Member management UI (2026-07-11) — `org/members/index`: one
      combined roster (active/deactivated members, join-request queue,
      pending invitations with reserved-seat visibility per critique),
      role toggles, activate/deactivate/deny/revoke/resend all wired to
      the plan_2 `Memberships::*` services and the new `Invitations::*`
      services. Mobile viewport covered by the fork-matrix system specs
      below, not a dedicated click-budget spec — no tap-count promise
      was made for this screen the way cues plan_6 makes one.
- [x] Emails (2026-07-11) — `InvitationMailer`, letter_opener, same
      stopgap as auth plan_2; real provider is notifications plan_2's job
      whenever that plan starts.
- [ ] **Known gap, not built:** bulk invitation. auth-security plan_2's
      Q2 answer asked for a board-owner tool to invite "in bulk with
      mailing lists," and this plan's own Design says "owner enters
      email(s)" (plural) — what shipped is one invite per request
      (`Invitations::Send` takes a single `email:`). `Org::MembersController#create`
      is the natural extension point (loop `Invitations::Send` calls,
      one per line of a pasted/uploaded list, partial-success reporting
      since one bad email shouldn't block the other 49) — flagging here
      rather than silently shipping less than what was asked for.

## Tests

- Negative: expired/revoked/already-accepted invitation token → friendly
  dead-end, no membership; accept with mismatched account → switch-account
  screen, no membership until switch; 16th reserved seat (active +
  pending invites) on basic → blocked at send, not just accept; a seat
  vanishing between invite and accept → invitation stays pending,
  redeemable, and the failure surfaces as a flash alert instead of a
  crash (same shape for the analogous join-approval-at-capacity case);
  join request to a disabled or unknown link → identical redirect+alert,
  not 404 as originally sketched — a friendlier dead-end than a bare 404
  page, still no oracle (disabled and unknown are indistinguishable);
  every owner-only action 404s a non-owner, never 403 (ADR 0010's
  philosophy); invitation email content has no existing-vs-new-address
  branch to begin with (unlike signup's enumeration defense), so there's
  nothing for a test to distinguish.
- Fork matrix system tests: {existing user, new user} × {invitation,
  join request} — four end-to-end paths, both viewports
  (`spec/system/organization_membership_spec.rb`).
- Rack::Attack: per-inviter throttle (critique) proven to trip
  (`spec/requests/rate_limiting_spec.rb`), same "flip on with a fresh
  store" pattern auth plan_3 established.

## Open questions

1. **Do pending invitations reserve seats?** — (a) yes **8/10**: honest
   about limits, no surprise at accept time; (b) no, check at accept
   **5/10**: nicer sending UX, ugly "org is full" rejection for the
   invitee — the worse first impression.
   Answer: yes, but need a way to revoke the reservation.
2. **Default role on join-link approvals** — (a) requester always,
   owner upgrades after **9/10**; (b) owner picks at approval time
   **6/10**: one more decision in the queue UI; fine to add later.
   Answer: yes, a

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

## Critique feedback
Great insights - these are features we need.