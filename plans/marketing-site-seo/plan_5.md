# marketing-site-seo — Child Plan 5: Feedback, Bug Reports & Contact

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** theming plan_3; support-admin plan_2 (triage surface
  docks there, built in support-admin plan_5)
- **Last updated:** 2026-07-08

## Goal

The listening apparatus: in-app feedback/bug/question submission from any
member, a public contact channel, and the pipeline landing both in the
support console — we are our own first requesters, and this is our own
first intake queue.

## Design

- **In-app (`FeedbackItem`):** authenticated form (category:
  feedback | bug | question; body; optional screenshot via the upload
  machinery with the same validations; auto-captured context: app
  version/commit, viewport, route — never cue content), reachable from
  the help menu on every app screen (≤2 taps). On-voice confirmations by
  category (bug: "Ugh. Our fault, probably. We're on it."). Status:
  new → triaged → resolved (support-side, plan_5 of support-admin);
  optional email-me-when-resolved flag.
- **Public contact:** marketing-frame page — form (name, email, message,
  honeypot + submit-time check, Rack::Attack throttle) → same intake
  table (source: public) + notification email to us; plus a plain
  mailto for form-haters. No CAPTCHA at v1 (consistent with auth plan_3
  Q1 posture); escalate if spam demands.
- **Intake notification:** each new item → email to the support address
  (notifications infra); daily digest if volume grows (deferred toggle).
- **The loop closes:** resolved-with-note + flag set → requester gets a
  short email (template on plan_2 infra). Feedback that becomes a
  feature lands in these plans; the item links the plan file in its
  resolution note (self-improvement hygiene).
- Data handling: bodies may contain anything users type — treated as
  sensitive (encrypted at rest like cue content), covered in the privacy
  policy (plan_4 checklist line).

## Implementation steps

- [ ] FeedbackItem model + statuses + context capture + encryption.
- [ ] In-app form + help-menu entry + confirmations + screenshot attach.
- [ ] Public contact page + anti-spam + throttles.
- [ ] Intake notification emails.
- [ ] Resolution-notification loop.
- [ ] Handoff interface for support-admin plan_5's triage queue
      (statuses + assignment fields exist here; UI there).

## Tests

- Negative: unauthenticated in-app endpoint → denied; honeypot-filled
  public submission → dropped silently; throttle trips on burst;
  screenshot validation reuses upload suite (spoofed type rejected);
  context capture contains no cue-content fields (schema-level negative
  assertion).
- Loop: resolve-with-flag → exactly one email to submitter; without
  flag → none.

## Open questions

1. **Feedback visibility to org owners** — (a) private to submitter +
   us **8/10**: feedback about the tool isn't org business, and people
   report honestly when the boss can't read it; (b) org owners see their
   members' items **3/10**: chills bug reports.

## Critique

*Reviewed 2026-07-09.*

- In-app feedback with content-free context capture, private-to-
  submitter visibility (S6a), and the triage handoff to the support
  console: no critique — being our own first requester is the right
  dogfooding posture.
- One simplification available: the public contact form and the in-app
  form share a table but not abuse posture — if public-form spam gets
  past the honeypot+throttle once, don't escalate to CAPTCHA
  immediately; drop the public *form* and keep mailto (the audience
  that matters is already in-app). Pre-deciding the fallback prevents
  the reflexive CAPTCHA.
