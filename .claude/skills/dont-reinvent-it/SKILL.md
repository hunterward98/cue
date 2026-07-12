---
name: dont-reinvent-it
description: Before writing custom code for a problem that's already been solved, check whether a maintained gem or pnpm package already solves it — and prefer installing over reimplementing when it does.
---

# Don't reinvent it

Self-improvement plan_3 critique feedback (2026-07-11): "are we solving
a problem that has been solved via gem or pnpm package? Maybe we should
just install it!" Exempt from the plan_3 candidacy rule (performed twice
and at least 3 error-prone steps) — this isn't a ritual to codify, it's
a standing check to run before writing non-trivial custom logic, so it
ships the day it was asked for rather than waiting on plan_3's full
rollout.

## When this fires

About to hand-write more than a few lines of logic for something that
sounds like a solved problem: parsing/formatting a known format,
retry/backoff, rate limiting, diffing, a state machine, CSV/PDF/image
handling, a well-known protocol (OAuth, JWT, CSV, iCal…), date/time
math beyond what `ActiveSupport`/`Date`/`Time` already give you.

## The check, in order

1. **Does Ruby's stdlib or Rails/ActiveSupport already do this?** Cheapest
   answer, zero new dependency. (This codebase already leans on this
   instinct — `OpenSSL::Digest::SHA256` for token hashing, `SecureRandom`
   for tokens, `URI::MailTo::EMAIL_REGEXP` for email format — no gem for
   any of them.)
2. **Is there a well-maintained gem/pnpm package for it?** Check
   last-release recency, open-issue trend, and whether it's the
   ecosystem's default answer (the kind of thing that shows up first in
   a "how do I X in Rails/React" search) — not just "a package exists."
   ADR 0014 (Base UI over Radix) is the worked example of _choosing
   between_ packages once you've decided a package is the right call.
3. **Weigh the dependency cost against the lines saved** (master plan:
   "boring, cheap, simple"). A well-maintained package that saves real
   correctness risk (OAuth's PKCE/state handling, password-breach
   k-anonymity lookups — already gemmed, not hand-rolled) is worth
   adding. A heavy dependency to save twenty obvious lines isn't.
4. **A package that's almost right isn't automatically right.** When
   `axe-core-rspec` turned out to assume a Selenium driver this repo's
   Cuprite setup doesn't have, the fix wasn't forcing the mismatched gem
   in — it was a ~20-line wrapper reusing the _engine_ the gem bundles
   (`axe-core-api`'s vendored JS) without its incompatible glue code
   (`spec/support/axe.rb`). Prefer the package; don't contort the app
   to fit a package that's fighting the stack.

If the check comes back "yes, use the package": add it via `bundle add`
or `pnpm add`, not a hand-copied vendor file — Dependabot/`bundler-audit`
/`pnpm audit` need to see it to keep it patched.

## Trigger tests

Recorded per plan_3's trigger-test convention — these three prompts must
load this skill:

1. "I need to implement exponential backoff for retrying failed jobs."
2. "Let's write a CSV export for the cue list."
3. "We need to validate and parse phone numbers on signup."

**Last verified:** 2026-07-11 (authored; not yet run against a live
miss — first use will confirm the trigger phrasing holds).
