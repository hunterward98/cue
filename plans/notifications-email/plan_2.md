# notifications-email — Child Plan 2: Mail Infrastructure

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** foundation; manual steps (provider account + domain DNS)
  for real sending — everything below builds and tests against
  letter_opener until then.
- **Note:** provider choice (manual step) is pending — the design is
  provider-agnostic behind Action Mailer, so only the delivery adapter +
  webhook parsing await the answer.
- **Last updated:** 2026-07-08

## Goal

The sending machinery every mailer in the app rides on: provider wiring,
deliverability (SPF/DKIM/DMARC), theme-aware layout, bounce/complaint
handling, and the privacy rule baked in as a test.

## Design

- **Provider (manual-step Q, rankings):** Postmark **8/10** — transactional
  focus, best-in-class deliverability + message streams, simple webhooks,
  ~$15/mo at MVP volume; SES **6/10** — cheapest at scale, more setup
  (suppression handling, warmup care), fine fallback; Resend **6/10** —
  pleasant DX, younger deliverability track record.
- **Adapter seam:** Action Mailer delivery method + one `EmailProvider`
  module owning webhook signature verification + payload normalization —
  swapping providers later touches exactly one file (+ DNS).
- **Layout:** single responsive HTML template + plaintext part for every
  mail. Light-theme tokens only — email client dark-mode is a swamp;
  one excellent light template beats two mediocre ones (documented
  decision, revisit on complaint volume). Org logo slot (theming plan_4
  variant) in org-context mails; Cue wordmark otherwise. Voice: subject
  lines informative-first, wit in the body where appropriate
  (snark-light zone rules apply to auth mail).
- **Privacy rule as infrastructure:** the base mailer exposes a
  constrained content API (event line, cue number/title, actor, CTA
  link) — mailers physically can't interpolate descriptions/comment
  bodies without bypassing the base class (cop + the parent's negative
  content assertions on every mailer spec).
- **Bounce/complaint webhooks:** verified endpoint → normalize →
  `EmailSuppression` (address, reason, source event) — suppressed
  addresses skip sends (job-level check), surface to org owners on the
  member list ("email bouncing" badge) and in support console
  (support-admin plan_2 org detail).
- **Headers:** List-Unsubscribe (+ one-click RFC 8058) on all
  notification categories (not transactional auth), per-category
  unsubscribe tokens landing on preference page (plan_3).

## Implementation steps

- [ ] Base mailer + constrained content API + layout (both parts) +
      letter_opener dev flow.
- [ ] Provider adapter + credentials + DNS records handed to manual step
      (SPF/DKIM/DMARC + verification checklist in the runbook).
- [ ] Webhook endpoint + signature verification + suppression model +
      send-time check.
- [ ] Owner-facing bounce badge + support console surface handoff.
- [ ] Unsubscribe headers + tokens.
- [ ] Deliverability runbook (`docs/runbooks/email.md`): warmup, DMARC
      monitoring, what to do when Gmail hates us.

## Tests

- Every mailer spec asserts: both parts render, no forbidden content
  (regex net over rendered output for seeded sensitive strings),
  correct suppression behavior (suppressed recipient → no delivery job).
- Webhook: bad signature → 401 (negative); bounce → suppression created;
  complaint → suppression + category future-sends killed.
- Layout: renders under 102KB (Gmail clipping), links absolute, CTA
  deep-links carry no sensitive query params.

## Open questions

1. *(manual step, ranked above)* Provider: Postmark 8/10 / SES 6/10 /
   Resend 6/10.
2. **Sending domain pattern** — (a) `mail.<domain>` subdomain **8/10**:
   isolates root-domain reputation; (b) root domain **5/10**: simpler DNS,
   shared blast radius.

## Critique

*Reviewed 2026-07-09.*

- **Single light template: fine, but plan for client dark-mode
  auto-inversion.** Gmail/Outlook dark modes recolor light emails
  themselves; logos as transparent PNGs on assumed-light backgrounds
  turn invisible. Concretely: logo variants with padding-baked
  backgrounds (or dark-safe wordmark), test the template once in
  Gmail-dark + Apple Mail-dark during mobile plan_4's audit. This is
  the cheap version of "dark mode support" — do it; full dark
  templates stay correctly deferred.
- One-click List-Unsubscribe (RFC 8058) is a *requirement* at
  Gmail/Yahoo for bulk-ish senders now, not a nicety — the plan has it;
  flagging so it doesn't get descoped under deadline.
- The constrained content API (mailers physically can't interpolate
  bodies) is the best mechanism in this feature — no critique; add the
  same constraint to any future digest builder before it exists.
