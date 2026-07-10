# auth-security — Child Plan 3: Hardening

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2
- **Last updated:** 2026-07-08

## Goal

The baseline protections that must exist before any external user can
reach the login form: throttling, lockout, breach-checked passwords,
strict headers, and TLS everywhere.

## Design

- **Rack::Attack:** per-IP throttles on auth endpoints (login, signup,
  verification, reset: e.g. 10/min/IP), per-account throttles keyed on
  normalized email (5/min), exponential ban on sustained abuse. 429s get
  an on-voice but unhelpful-to-attackers page. Allowlist health checks.
- **Lockout:** 10 consecutive failures → account locked, unlock email
  issued automatically; lockouts visible in support console (support-admin
  plan_3 consumes). Lockout responses identical to bad-password responses
  (no oracle).
- **Breach check:** pwned-passwords k-anonymity API on password set/change
  only (never on login), 2s timeout, fail-open with a logged warning —
  availability of signup beats perfection of the check.
- **Headers:** nonce-based CSP (script-src 'self' + nonce — Vite/Inertia
  compatible; no external hosts, fonts self-hosted per theming plan_2),
  HSTS with sensible max-age ramp, frame-ancestors 'none',
  referrer-policy strict-origin-when-cross-origin, permissions-policy
  minimal. `force_ssl` on.
- **Session hygiene:** rotate session on login and privilege change;
  cookie flags secure/httponly/SameSite=Lax (Lax not Strict — email links
  must land logged-in).
- **security.txt** + a plain-language disclosure policy page.

## Implementation steps

- [ ] Rack::Attack rules + specs (request specs driving real throttle
      windows with time travel).
- [ ] Lockout + unlock flow + AuthEvent wiring.
- [ ] Breach check service object (stubbed HTTP in tests, fail-open spec).
- [ ] CSP + headers; system tests must pass under the real CSP (catches
      inline-script regressions forever).
- [ ] Session rotation; cookie flag assertions.
- [ ] security.txt + disclosure page.

## Tests

- Negative: 11th rapid login attempt → 429; locked account with correct
  password still fails identically; weak/breached password rejected on
  signup; response with missing nonce script blocked (CSP violation spec
  via headless console errors); http request → redirected to https.
- Fail-open spec: breach API down → signup still succeeds, warning logged.

## Open questions

1. **CAPTCHA on signup** — (a) none at launch, rely on throttles + email
   verification **8/10**: CAPTCHAs cost conversions and our verification
   step already gates bots; (b) hCaptcha/Turnstile behind an abuse
   threshold feature flag **7/10**: pre-wire, enable if abuse appears;
   (c) always-on **4/10**: friction without evidence.

## Critique

*Reviewed 2026-07-09.*

- **Rack::Attack needs a store decision the plan skips.** Backing it
  with Solid Cache means a Postgres write per tracked request on the
  hottest endpoints — works, but it's DB load spent on counters. On our
  single VPS the pragmatic v1 is `MemoryStore` per process: throttle
  limits then multiply by puma worker count (e.g. 10/min becomes ~30/min
  across 3 workers). Either accept that and set limits ÷ workers, or
  accept the Solid Cache write cost until it shows up in metrics. Pick
  one explicitly and document it — an unconfigured store silently
  no-ops in some setups, which would mean *no throttling at all*; add a
  negative test that the throttle actually trips in production config.
- **CSP + Vite dev mode:** HMR needs a relaxed dev policy (ws:,
  unsafe-inline styles in dev). Keep the strict policy production-only
  and test under production CSP in system tests (the plan already runs
  system tests under real CSP — confirm that means the *production*
  policy).
- Lockout responses identical to bad-password: right, and rare — keep.
- Otherwise no critique.
