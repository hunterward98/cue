---
name: verify
description: Drive the Cue app end-to-end in a real browser to verify a change at its surface (Rails + Vite + Inertia).
---

# Verifying Cue changes at runtime

## Build & launch

- Shell needs mise: `eval "$(mise activate bash)"` before any ruby/pnpm.
- Dev data: `bin/rails db:prepare db:seed` — seeds a demo org (`/o/demo`)
  with owner@demo.test / boards-a@demo.test / boards-b@demo.test /
  requester@demo.test, all password `a-long-enough-password`.
- Launch: `bin/dev` in a background task. **Rails listens on
  http://localhost:5100** (not 3000); Vite dev server on 3036. If bin/dev
  says "A server is already running", a previous instance is up — reuse
  it (`curl localhost:5100/up` → 200) or remove tmp/pids/server.pid.
- Mail in dev opens via letter_opener (tmp/letter_opener/) — read the
  latest file for codes/links.

## Driving with Chrome MCP

- Sign in at `/session/new`; post-login home is `/organizations`.
- **Gotcha:** input actions (click/type) in the same browser_batch as a
  `navigate` get eaten by Inertia hydration — the form looks filled or
  stays silently empty and submit is blocked by HTML5 `required`. Split
  batches: navigate + wait in one, interactions in the next. Verify a
  form actually submitted by grepping log/development.log for the POST.
- Chrome autofill fills the DOM but not React state — click the field,
  `ctrl+a`, retype instead of trusting prefilled values.
- 404 behaviors (non-member org, unknown slug, malformed slug) render as
  debug exception pages in development (RecordNotFound / RoutingError);
  the production 404 status is asserted by request specs — seeing the
  right exception class is the dev-mode confirmation.

## Flows worth driving

- Auth: register → check inbox → code from letter_opener → verify.
- Tenancy walls: sign in as requester@demo.test, visit an org they're
  not a member of → RecordNotFound; `/o/demo` → role line renders.
- Org creation: `/organizations/new` — slug auto-suggests from name
  (diacritics stripped), manual slug edit stops the sync, duplicate slug
  re-renders with "has already been taken" under the field.

## Watch out

- development.rb sets `strict_loading_by_default = true` — lazy-load
  bugs only appear here, never in the test suite. A
  StrictLoadingViolationError page in dev is a real bug; eager-load in
  the code path that owns the record.

## Trigger tests

Recorded per self-improvement plan_3's trigger-test convention (applied
retroactively, 2026-07-11) — these three prompts must load this skill:

1. "Can you run the app and check that this works?"
2. "Take a screenshot of the login page."
3. "Verify this change actually works, not just that the tests pass."

**Last verified:** 2026-07-11 (retrofitted with the trigger-test
convention; not yet run against a live miss).
