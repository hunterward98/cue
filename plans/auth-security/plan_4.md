# auth-security — Child Plan 4: 2FA (Email Codes)

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2 (token machinery), notifications plan_2 (sending)
- **Sequencing:** mechanism + staff enforcement land with the support
  console (Phase 1–2); general user rollout is post-MVP.
- **Last updated:** 2026-07-08

## Goal

A second factor via email one-time codes: mandatory for support staff
before the console opens, opt-in for users post-MVP, org-mandatable for
enterprise appeal. Built once, enforced in layers.

## Design

- **Mechanism:** after primary auth, a 6-digit code (same token
  discipline as plan_2: hashed, single-use, 5-minute expiry for 2FA,
  3 attempts then re-issue required). Session records `second_factor_at`;
  authorization for protected areas checks it.
- **Note:** if parent Q1 lands on passwordless-primary, email code IS the
  primary factor — then "2FA" for users means adding TOTP as the second
  distinct factor, and this plan's user-facing scope shifts to TOTP
  (ROTP gem + QR provisioning). Staff enforcement is unaffected: staff use
  password + email code from day one regardless. This is why the plan
  stays mechanism-focused until Q1 resolves.
- **Enforcement layers:** (1) staff: cannot pass the `/support` wall
  without a second factor, ever; (2) user opt-in in account settings;
  (3) org policy `require_2fa` — members without 2FA get a grace-period
  nag then a hard wall (org owners see compliance status).
- **Trusted devices:** signed cookie remembering the second factor for 30
  days per device, revoked with sessions ("sign out everywhere" clears
  trust). Never for staff — staff verify each new session.
- **Recovery:** email-based factors self-recover via account email; if
  TOTP enters (Q1-dependent), 10 single-use recovery codes generated at
  enrollment.

## Implementation steps

- [ ] Code challenge screen + token plumbing + `second_factor_at`.
- [ ] Staff enforcement at the support wall (with support-admin plan_2).
- [ ] Trusted-device cookie (users only) + revocation.
- [ ] User opt-in settings UI (post-MVP window).
- [ ] Org `require_2fa` policy + grace/nag/wall + owner compliance view
      (post-MVP window).
- [ ] TOTP decision point after parent Q1 resolves.

## Tests

- Negative: correct password + no/expired/wrong code → no session
  elevation; 4th code attempt → rejected until re-issue; staff without
  second factor hits console → walled regardless of cookie tricks;
  trusted-device cookie replayed after revocation → challenge again;
  requester in a require-2fa org past grace → walled from org content.
- Clock-travel: expiries, grace periods.

## Open questions

1. **Grace period for org-required 2FA** — (a) 7 days with escalating nags
   **8/10**; (b) immediate hard wall **5/10**: punishes members for an
   owner's toggle mid-workday; (c) 30 days **4/10**: too leisurely for a
   security control.

## Critique

*Reviewed 2026-07-09.*

- **The plan already flags the same-factor problem; sharpen it to a
  product constraint:** if A1 lands passwordless-default, email codes
  are single-factor for those users, and Cue must not advertise "2FA"
  until TOTP exists. Concretely: the marketing site and org
  `require_2fa` setting copy may only use the term once a genuinely
  distinct second factor ships. Staff flow (password + email code) is
  legitimately two factors today — scoping the claim to staff is
  accurate and fine.
- If A1 = passwordless, consider jumping straight to TOTP for the
  user-facing "2FA" milestone and skipping user-facing email-OTP
  entirely — it would otherwise be code + code, security theater.
  (Staff keep password + email code either way.)
- Trusted-device 30d cookie, never for staff: right call, no critique.
