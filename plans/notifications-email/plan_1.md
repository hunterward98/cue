# Parent Plan: Notifications & Email

- **Status:** NOT_STARTED
- **Phase:** 2
- **Depends on:** auth-security (verification mails), cues (events)
- **Blocks:** —
- **Manual steps:** [manual_steps_plan_1.md](manual_steps_plan_1.md)
- **Last updated:** 2026-07-08

## Objective

Email is the primary notification channel (master plan). Build one coherent
notification layer: transactional auth mail, cue-event notifications,
@-mention alerts — reliable, private, and unsubscribable per category.

## Scope (from master_plan.md)

- Email as primary notification method.
- Tagged users in comments get notified via email.
- Privacy strictness applies: emails must not leak sensitive content to the
  wrong audience and must assume inboxes are less secure than the app.

## Key decisions

### Recommended

1. **Provider: Postmark** (transactional-grade deliverability, simple,
   ~$15/mo at MVP volume; Amazon SES as the cheap fallback if cost trumps
   simplicity — decide in manual steps). Dev/test use letter_opener +
   mailer specs; no real sends.
2. **Privacy-first email content:** notification emails contain the event
   type, cue number/title, and actor — **not** cue descriptions, comment
   bodies, or attachments. One click deep-links into the app (auth wall).
   This keeps sensitive data out of inboxes and is a negative-tested rule.
3. **Notification events v1:** cue created (→ relevant board owners... see
   open q), status changed (→ requester), comment added (→ cue participants),
   @-mention (→ mentioned user), cue pulled onto a board (→ requester),
   resolved (→ requester). Invitation + auth mails come from their plans but
   share layout/infrastructure.
4. **Delivery via Solid Queue jobs** with retry/backoff; bounce + complaint
   webhooks mark addresses problematic and surface to org admins.
5. **Per-user notification preferences** by category (mentions always on —
   they're personal); **digest option deferred** post-MVP.
6. **In-app notification bell deferred** post-MVP (email-first per master
   plan); design the `Notification` record now so the bell is a UI add later.

## Child plans to create

- `plan_2.md` — Mail infrastructure: provider setup, layouts (theme-aware,
  both product themes), base mailer, deliverability (SPF/DKIM/DMARC),
  bounce handling.
- `plan_3.md` — Notification engine: event subscriptions, `Notification`
  record, fan-out jobs, per-user preferences UI.
- `plan_4.md` — Cue/board event notifications + @-mention pipeline
  (parsing mentions is in cues plan_4; delivery is here).

## Implementation order

1. [ ] Manual: provider account + domain DNS (blocks real sending only —
   development proceeds with letter_opener).
2. [ ] plan_2 infrastructure.
3. [ ] plan_3 engine + preferences.
4. [ ] plan_4 event wiring.

## Test strategy

- Mailer specs for every mail: recipient set, subject, and the **negative
  content assertions** (no comment bodies, no descriptions in any
  notification mail).
- Fan-out tests: mention of N users enqueues exactly N jobs, deduplicated
  when mentioned twice; author never notified of own action.
- Preference tests: opted-out category sends nothing (negative).

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Provider live with SPF/DKIM/DMARC verified
- [ ] Engine + preferences shipped
- [ ] All v1 events wired
- [ ] Privacy policy updated (email handling)

## Open questions

1. When a requester submits a cue to the backlog, who gets notified? All
   board owners could be noisy in a busy org. (Recommendation: org setting —
   all owners / no one / specific owners; default all owners for small orgs.)
2. Reply-by-email to add a comment? Genuinely useful but a spoofing/privacy
   surface. (Recommendation: defer, revisit post-MVP with security review.)

## Critique

*Reviewed 2026-07-09.*

- **Postmark pricing verified:** $15/mo Basic includes 10k emails, no
  annual discount; DMARC monitoring is a $14/mo add-on
  ([pricing survey](https://www.saaspricepulse.com/tools/postmark)) —
  use the free tier of a DMARC report analyzer instead at our volume.
  N1 ranking stands.
- The privacy-first content rule (no bodies in emails) is the plan's
  spine and survives critique — one honest cost to state: every email
  becomes a click-through, which requesters on flaky sessions will feel.
  The deep-link + return-to-target work in plan_4 is what makes the
  privacy rule livable; treat that flow's polish as part of THIS
  decision, not an optional nicety.
- In-app bell deferred with schema-ready Notification rows: right.
  No further critique.
