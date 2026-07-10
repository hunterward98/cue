# notifications-email — Child Plan 3: Notification Engine & Preferences

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, cues plan_2 (events exist)
- **Last updated:** 2026-07-08

## Goal

The routing brain between domain events and inboxes: who gets told about
what, recorded durably, deduplicated, and governed by per-user
preferences — email today, in-app bell tomorrow, without rework.

## Design

- **Event source:** CueEvents (and membership/auth events) are already
  written transactionally (cues plan_2). The engine subscribes
  after-commit: an `EventFanout` job per qualifying event resolves the
  audience and writes `Notification` rows.
- **Notification record:** recipient, category (enum: mention, comment,
  status_change, cue_created, cue_pulled, cue_resolved, membership,
  digest-reserved), notifiable (event ref), `read_at` (null — reserved
  for the future bell; email-first now, parent decision), `emailed_at`.
  The row is the durable fact; email is one delivery channel of it —
  the bell later just renders unread rows. No schema change needed.
- **Audience resolution per category:** mentions → mentioned user;
  comment → cue participants (cues plan_4's materialized set) minus
  author; status_change/pulled/resolved → requester (+ participants for
  resolved — see Q1); cue_created → org fan-out setting (parent Q1:
  all owners / none / selected — org setting from organizations plan_4).
- **Dedup + suppression rules:** author never notified of own action;
  mention inside a comment → one email (mention wins, comment
  notification suppressed — parent 9/10 rule); N events on one cue
  within a short window → still N emails at v1 (batching = digest
  territory, deferred) except comment-storms: max 1 comment email per
  cue per 10 min per recipient with "and 3 more comments" rollup.
- **Preferences:** per-user × per-category toggles (mentions locked ON,
  rendered as such — personal address must always reach you);
  per-category unsubscribe links (plan_2 tokens) land here pre-checked.
  Account-level "mute this cue" — cheap, prevents the one noisy cue from
  training users to ignore everything.

## Implementation steps

- [ ] Notification model + categories + engine job + audience resolvers
      (pure, table-tested).
- [ ] Dedup/suppression rules + comment-storm rollup.
- [ ] Preference model + settings UI + unsubscribe landing + mute-cue.
- [ ] Delivery job: preference check → suppression check (plan_2) →
      render → send → `emailed_at`.
- [ ] Wire the org fan-out setting.

## Tests

- Audience tables: for each category × cast (requester, owner,
  commenters, mentioned, muted, opted-out, suppressed, deactivated) →
  exact recipient set. Negative: author self-notification, deactivated
  member, opted-out category, muted cue → zero rows/sends; mention
  dedup → exactly one email; storm rollup → 1 email + correct count.
- Idempotency: fan-out job retried → no duplicate Notification rows
  (unique index on event+recipient).

## Open questions

1. **cue_resolved audience** — (a) requester + participants **7/10**:
   people who touched it learn it closed; (b) requester only **6/10**:
   quieter, participants can check; comment volume will decide — pick (a),
   demote on complaint.
2. **In-app bell timing** — (a) post-MVP, schema-ready as designed
   **8/10** (parent decision, restated for the record); (b) MVP **4/10**.

## Critique

*Reviewed 2026-07-09.*

- **The comment-storm rollup is the one v1 over-build here.** It adds a
  windowing job, a rollup template, and dedup state to solve a problem
  small orgs may never have. Alternative shape: ship without it, keep
  the per-cue mute (the actual pressure valve), and let the retro add
  rollups when a real org hits a storm (the gotcha protocol will
  catch it). Keeping it is defensible; building it *first* is not —
  sequence it last within this plan and cut it if Phase 2 timing
  tightens.
- Audience resolvers as pure table-tested functions + unique index
  idempotency: no critique — this is the right architecture for the
  bell to arrive later without rework.
- One rule to add: notifications for a cue a user has lost access to
  (removed from org between event and send) must no-op at *send time*,
  not just enqueue time — the delivery job re-checks membership. Cheap
  negative test, real privacy edge.
