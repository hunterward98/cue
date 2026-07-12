# auth-security — Child Plan 6: OAuth (Google, Microsoft)

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2 (accounts/sessions); coordinates with plan_4 (2FA
  — an OAuth sign-in satisfies the "proved you own this inbox" bar the
  same way email verification does, ADR 0015 precedent)
- **Last updated:** 2026-07-11

## Goal

Google sign-in (fast, per Hunter's read of this audience — real-estate
offices live in Google Workspace), and likely Microsoft/Entra ID, as an
alternative to password/passwordless — without duplicating an account
for someone who already has one under the same email.

**Why now, not MVP:** the plan_1 critique validated "no OAuth at MVP"
for this audience; Hunter's feedback overrode it — "We should plan for
Google OAuth but that will be quick; might need Microsoft though." This
plan exists so that override has a real design behind it, sequenced
whenever Phase 1 auth work picks back up (not MVP-blocking).

## Design

- **Library:** OmniAuth (`omniauth`, `omniauth-google-oauth2`,
  `omniauth-rails_csrf_protection` — the CSRF gem is load-bearing since
  OmniAuth's own CVE history is why it exists now, not optional). Same
  "Rails-native tooling, no Devise" stance plan_1 already ratified —
  OmniAuth isn't a Rails-core generator, but it's the de facto standard
  precisely because rolling PKCE/state-parameter handling by hand is the
  kind of thing this codebase explicitly avoids (ADR-worthy: "we don't
  reinvent OAuth2 state handling").
- **Account model:** a new `Identity` join (`provider`, `uid`, `user_id`,
  unique on `provider`+`uid`) rather than provider columns on `User` —
  scales to Microsoft without a second migration, and to a user linking
  both providers to one account later. Matches the shape `Invitation`
  and `AuthToken` already use: a narrow, single-purpose table next to
  `User`, not a widening of `User` itself.
- **Sign-in fork, mirrors org plan_3's invitation fork exactly:**
  - Existing `Identity` for this provider+uid → sign in as that user
    (`start_new_session_for`).
  - No `Identity`, but a `User` already exists with the provider's
    (verified-by-the-provider) email → **link**, don't duplicate: create
    the `Identity` on the existing account, sign in. This is the
    account-linking case a naive implementation gets wrong and creates
    two accounts for one person.
  - No `Identity`, no matching `User` → create a new, already-verified
    `User` (ADR 0015 precedent: the provider's own verified-email claim
    substitutes for our verification code) + the `Identity`, sign in.
  - Provider reports the email as **unverified** → refuse the sign-in
    with a clear message ("your Google account's email isn't verified
    with Google — verify it there first"), never silently trust an
    unverified claim to link or create an account.
- **Login screen:** "Continue with Google" (and Microsoft, if answered
  in) above the password/passwordless forms — the fast path first for
  the audience most likely to already be signed into Workspace.
- **Not in scope:** org-mandated SSO (an org requiring members to use
  Google specifically), calendar/contacts/deeper Workspace integration,
  SAML/enterprise IdP. This plan is sign-in only.

## Implementation steps

- [ ] `Identity` model + migration (provider/uid/user_id, unique
      provider+uid, FK to users) + factory.
- [ ] OmniAuth + CSRF gem, Google strategy configured (dev/test:
      `OmniAuth.config.test_mode`, matching how letter_opener stands in
      for real email).
- [ ] `OmniauthCallbacksController` (or similar): the three-way fork
      above, `AuthEvent` records for each path (mirrors existing
      signup/login events).
- [ ] Login screen button(s) + provider-unverified-email error state.
- [ ] Microsoft strategy, if O2 answers yes — same controller, config
      addition only (the fork logic is provider-agnostic by design).

## Tests

- Negative: unverified provider email → refused, no account
  created/linked; a provider callback with a tampered/replayed state
  param → rejected (OmniAuth + the CSRF gem's job, but worth a smoke
  test that it's actually wired); an `Identity` can't attach to two
  `User`s (DB uniqueness on provider+uid); rate limiting on the callback
  endpoint (same `Rack::Attack` shape as `/session`).
- Fork matrix: {existing Identity, existing User no Identity (link),
  brand-new} × Google (× Microsoft, if in scope) — mirrors org plan_3's
  fork-matrix system spec pattern.
- New-via-OAuth users land verified with no verification email sent
  (same assertion style as the invitation-backed-signup spec in
  `spec/requests/registrations_spec.rb`).

## Open questions

1. **Microsoft at the same time as Google, or Google first and
   Microsoft as a fast-follow?** — (a) **(Recommended)** Google first,
   ship it, add Microsoft as a follow-up PR once Google's fork logic is
   proven in production **8/10**: the fork/link/create logic is the
   real risk, not the provider config — de-risk it once, not twice at
   once; (b) both in the same PR **5/10**: "might need Microsoft" reads
   uncertain enough that building it speculatively risks unused code if
   it turns out nobody asks.
   Answer:
2. **Does linking require the user to be signed in, or does email-match
   alone authorize the link?** — (a) **(Recommended)** email-match alone
   **7/10**: the provider already re-proved inbox ownership (that's what
   OAuth *is*), so this is exactly as strong as the invitation-token
   precedent (ADR 0015) — no extra friction; (b) require an existing
   signed-in session to confirm the link explicitly **5/10**: stronger
   against a theoretical email-reuse edge case, but adds a step for the
   overwhelmingly common case and this audience doesn't run into that
   edge case (real-estate offices, not marketplaces with email churn).
   Answer:
3. **Password-mode users who add Google: does Google become sign-in
   #2, or does it replace the password?** — (a) **(Recommended)**
   additive — both work, user can still use their password **8/10**:
   removing a working credential without being asked is the kind of
   thing that generates a support ticket; (b) OAuth sign-in silently
   disables the password **3/10**: no.
   Answer:

## Critique

*Self-reviewed 2026-07-11, on authoring — not yet through the
2026-07-09 batch pass. The account-linking fork is the part most likely
to need a second look once real Google accounts are being tested
against it (e.g., Google Workspace admin-managed accounts sometimes
report email differently than consumer Gmail — worth a manual smoke
test against a real Workspace account before calling this done, not
just the OmniAuth test-mode fixtures).*

## Critique feedback
