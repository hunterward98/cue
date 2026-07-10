# Parent Plan: Auth & Security

- **Status:** NOT_STARTED
- **Phase:** 1
- **Depends on:** foundation, database-architecture
- **Blocks:** organizations-users, everything user-facing
- **Last updated:** 2026-07-08

## Objective

Accounts, sessions, email verification, and the security posture. Master plan:
users may store extremely sensitive information; security is the one area we
"build for tomorrow" — always improving.

## Scope (from master_plan.md)

- Email verification before a user may use the site (MVP requirement).
- Login codes via email (2FA) — fast-follow after MVP, designed for now.
- Strict privacy: a user must be logged in AND approved for an organization to
  see anything in it. Previews/search results must never leak org content
  (coordination point with marketing-site-seo).

## Key decisions

### Recommended

1. **Rails 8 built-in authentication generator** as the base (sessions,
   password reset), extended with email verification. No Devise — the
   generator is simpler, fully ours, and fully testable. No OAuth providers at
   MVP (real-estate offices live in email; add Google SSO later if demanded).
2. **Session-based auth** (works natively with Inertia). Secure, httponly,
   SameSite=Lax cookies; session expiry + rotation on privilege change.
3. **Email verification flow:** signup → verification code/link via email →
   account usable. Unverified accounts can do nothing except re-request
   verification. Verification tokens: single-use, short-lived, hashed at rest.
4. **2FA design (build now, ship post-MVP):** email one-time codes as the
   baseline (master plan's suggestion), architecture leaves room for TOTP.
   Org-level setting to *require* 2FA for members (enterprise selling point).
5. **Baseline hardening at MVP:** Brakeman in CI, rate limiting
   (Rack::Attack) on auth endpoints, password breach check
   (pwned-passwords k-anonymity API), account lockout with backoff, audit log
   of auth events, CSP headers, forced TLS.

## Child plans to create

- `plan_2.md` — Accounts: signup, login, logout, password reset, email
  verification, session management. Full negative-test suite (wrong code,
  expired token, replay, unverified access attempts).
- `plan_3.md` — Hardening: rate limits, lockout, breach check, headers/CSP,
  auth audit log.
- `plan_4.md` — 2FA via email codes + org-required-2FA setting. General
  rollout is post-MVP, but the email-code mechanism itself lands early:
  **support staff require mandatory 2FA before the support console opens**
  (see support-admin plan) — build the mechanism once, enforce for staff
  first, then extend to users.
- `plan_5.md` — Recurring security review checklist (feeds self-improvement
  loop; runs `/security-review` on auth-touching changes).

## Implementation order

1. [ ] plan_2 accounts + verification (MVP-blocking).
2. [ ] plan_3 hardening (MVP-blocking).
3. [ ] plan_4 2FA (first post-MVP security improvement).
4. [ ] plan_5 recurring review process established.

## Test strategy

Negative tests are the star here: every protected route asserts unauthorized
AND unverified AND wrong-org access fails; token replay fails; rate limits
trigger; lockout engages. System test covers the full signup→verify→login
happy path on mobile viewport.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Accounts + verification shipped
- [ ] Hardening shipped
- [ ] 2FA shipped
- [ ] Privacy policy sections updated (coordination with marketing-site-seo)

## Open questions

1. Email-code login (passwordless) as the *primary* auth, instead of
   password + email 2FA? Simpler for non-technical requesters, one less
   credential to breach. Recommendation: offer both, passwordless default.
   Answer: Password + email 2FA for organization admins/board owners that "remembers device for 14 days" to bring passwordless.
2. Session lifetime for requesters vs board owners (e.g. 30 days vs 7)?
    Answer: 7 days each.

## Critique

*Reviewed 2026-07-09.*

- **Passwordless-default (A1 rec) carries one honest coupling:** email
  deliverability becomes login availability. Option (a) already keeps
  passwords as the fallback path, which is the right mitigation — but
  make the fallback *discoverable* ("use a password instead" visible on
  the code screen, not buried in settings), otherwise a Postmark
  incident locks out the password-less majority in practice.
- Rails 8 built-in auth generator over Devise: validated direction — the
  generator is current Rails-core guidance and gives us full ownership;
  no critique.
- No OAuth at MVP is right for this audience; when it comes, it'll be
  Google Workspace first (real-estate offices) — nothing in the session
  design blocks it.
- Otherwise no critique.
