# auth-security — Child Plan 2: Accounts & Email Verification

- **Parent:** [plan_1.md](plan_1.md) · **Status:** DONE (2026-07-10) — letter_opener for delivery until notifications plan_2; invitation landing owned by organizations-users
- **Depends on:** foundation, database-architecture plan_2;
  notifications plan_2 for real sending (letter_opener until then)
- **Last updated:** 2026-07-08
- **Note:** the login-method question (parent Q1) shapes this plan's UI
  flows, so this plan stays design-level on flows and concrete on the
  invariant core (User/Session/tokens), which is identical either way.

## Goal

A user can sign up, prove they own their email, log in, log out, and
recover access — with every failure path negative-tested. Unverified
accounts can do nothing but re-request verification.

## Invariant core (implementable now)

- `User`: citext unique email, bcrypt `password_digest` (present even if
  passwordless becomes primary — passwords stay as an option),
  `verified_at`, staff flag (owned by support-admin).
- `Session`: DB-backed (Rails 8 generator pattern) — user_agent, ip,
  last_active_at; cookie holds signed session id; sessions listable and
  revocable by the user ("sign out everywhere").
- **Token discipline** (verification, reset, login codes): stored hashed,
  single-use, 15-minute expiry, scoped per purpose, invalidated on use and
  on newer issuance; 6-digit codes come with magic-link equivalents in the
  same email (code = cross-device friendly, link = one-tap on phone).
- `AuthEvent` append-only log: signup, verify, login ok/fail, logout,
  reset requested/completed, lockout (consumed by plan_3 and support
  console).

## Flow design (finalize after parent Q1)

- **Signup:** email (+ password if password mode) → verification email →
  enter code / tap link → verified → org creation or invitation landing.
  Copy is on-voice but auth screens stay snark-light (trust surface).
- **Login:** password mode = email+password; passwordless mode = email →
  code. Either way: no user enumeration — identical response whether or
  not the email exists (negative-tested), including timing (constant-time
  compare, dummy bcrypt on miss).
- **Reset:** request → email → set new password → all other sessions
  revoked + notification email sent.

## Implementation steps

- [x] Q1 resolved: per-user login-mode choice at signup; passwords at the forefront.
- [x] User/Session/AuthEvent models + AuthToken machinery (invariant core).
- [x] Signup + verification flow (gating: unverified → verification screen
      only, enforced in ApplicationController, negative-tested).
- [x] Login/logout + session management UI (list/revoke). Code login pairs the code with the server-session pending email.
- [x] Password reset flow (token consumed only when the new password saves).
- [x] Mobile-viewport system tests for every flow (the requester's very
      first impression is this flow on a phone).

## Tests

- Negative: expired/reused/cross-purpose tokens fail; unverified user hits
  any app route → redirected; enumeration probes get identical responses;
  revoked session cookie is dead immediately; verification email for
  existing address on signup does not reveal account existence.
- Time-travel specs for expiries; full happy-path system tests at both
  viewports.

## Open questions

1. *(restating parent Q1 with rankings)* **Primary login method** —
   (a) both, passwordless (email code) as the default path, password
   optional **8/10**: matches non-technical requesters, one less credential
   to phish, password remains for the email-averse; (b) password-first
   with email 2FA later **6/10**: conventional, but doubles secrets to
   manage for an audience that forgets passwords; (c) passwordless only
   **5/10**: simplest surface but hostile when email is slow; (d) password
   only **3/10**: contradicts the security posture.
   Answer: Make A and B a setting. Users will be asked while they create their account.
2. **Post-signup landing** — (a) create-or-join organization chooser
   **8/10**; (b) straight to org creation **5/10**: wrong for invited
   users. (Invitation links skip the chooser either way.)
   Answer: Users MUST be invited via email. Board owners will need a tool to do this in bulk with mailing lists.

## Critique

*Reviewed 2026-07-09.*

- **Make the signup enumeration defense explicit in the flow design, not
  just the test list.** The negative test ("verification email for
  existing address doesn't reveal existence") exists, but the flow text
  never states the mechanic: signup with an existing email must render
  the same "check your inbox" screen and send a *"you already have an
  account — sign in here"* email instead of a verification email. Write
  it into the plan_2 flow so the implementer doesn't discover the
  requirement from a failing test.
- Constant-time concerns: dummy bcrypt on miss is right; also pin the
  verification-code comparison to `secure_compare`. Cheap, complete.
- bcrypt over argon2id: fine — boring, Rails-native, and our lockout +
  throttles carry more real weight than the KDF choice at this scale.
- Otherwise no critique — token discipline (hashed, single-use, purpose-
  scoped, 15-min) is exactly right.

## Critique feedback:
Good critiques, maybe we should improve then. Do what you feel is appropriate.