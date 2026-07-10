# support-admin — Child Plan 5: Break-Glass & Feedback Triage

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
  (Phase 3–4)
- **Depends on:** plan_2; marketing plan_5 (FeedbackItem);
  parent Q1 (org-owner notification on break-glass — rec 8/10 yes)
- **Last updated:** 2026-07-08

## Goal

The two remaining rooms: the break-glass mechanism that lets support see
customer content only deliberately, temporarily, and loudly — and the
triage queue where feedback/bug reports get worked.

## Design

### Break-glass

- **Grant:** staff requests access to ONE org's content with a typed
  reason (≥20 chars, no boilerplate — reason quality is reviewed in
  auth plan_5's phase review) → `BreakGlassGrant` (staff, org, reason,
  expires_at = 1h, revoked_at) → support_event + **org-owner
  notification email** (pending parent Q1; designed in, flag-off until
  ratified) + a banner in the console for the grant's duration.
- **Effect:** support serializers for that org switch from allowlist-
  metadata to content-inclusive **read-only** views (cue detail,
  comments, initiative docs — rendered through the same policy layer
  with an explicit `break_glass` context; no editing of customer
  content, ever — support fixes accounts, not cues). File downloads
  during grant are themselves individually evented.
- **Expiry/revoke:** hard stop at 1h (re-grant = new reason, new
  notification); self-revoke button for the 5-minute jobs; all views
  drop to metadata at expiry mid-session (no cached content — the
  serializer check is per-request).
- **Audit surface:** break-glass history per org visible in the console
  AND to org owners in their settings ("support access log" — the trust
  feature the privacy policy advertises, marketing plan_4).

### Feedback triage

- **Queue (FeedbackItem from marketing plan_5):** lanes new/triaged/
  resolved; filters (category, org, version); assignment (solo-scale:
  a claimed-by field, not workflow); item view shows body + context
  capture (which is already content-free by design — no break-glass
  needed for triage); actions: status moves, internal note,
  resolve-with-note (fires the submitter email when flagged).
- **Bug → gotcha wiring:** resolving a bug item prompts the gotcha
  question (self-improvement plan_2 protocol) — support intake feeds
  the improvement loop mechanically, not aspirationally.

## Implementation steps

- [ ] Grant model + ceremony (reason, expiry, notification flag, banner).
- [ ] Serializer context switching + read-only content views + download
      eventing.
- [ ] Expiry/revoke + per-request enforcement.
- [ ] Owner-facing access log + settings surface.
- [ ] Triage queue + lanes + resolution loop + gotcha prompt.
- [ ] Runbook: when break-glass is warranted (short list) and when it
      is not (everything else).

## Tests

- Negative (the point of the feature): content endpooints without active
  grant → metadata only (introspection spec from plan_2 re-run under
  each grant state); expired grant mid-session → next request drops
  content; grant for org A never exposes org B (seeded look-alike);
  write attempt on content under grant → rejected; reason < 20 chars →
  rejected; notification (when flag on) sent exactly once per grant.
- Access log: owners see every grant; entries immutable (append-only
  shared example).
- Triage: resolution email fires per flag; gotcha prompt fires on bug
  resolution.

## Open questions

1. *(parent Q1, restated for ratification)* **Org-owner notification on
   break-glass** — (a) yes, every grant, at grant time **8/10**: the
   trust feature; support hesitation before glass-breaking is a feature,
   not a bug; (b) monthly access-log digest instead **5/10**: visibility
   without the real-time deterrent; (c) no **2/10**: contradicts the
   privacy posture we advertise.

## Critique

*Reviewed 2026-07-09.*

- Reason-gated 1-hour grants, read-only content views, per-request
  enforcement, per-download eventing, and the owner-visible access
  log: no critique on the mechanism — this is the trust feature the
  privacy policy should advertise (SU1a's case makes itself).
- One design sharpening: **the reason field will decay into "user
  asked for help" boilerplate.** The plan already routes reason-quality
  review to the phase security check — add a structural assist: the
  grant form requires selecting the *linked feedback/support item* (or
  explicitly "no ticket — explain"), tying every glass-break to a
  traceable request. Boilerplate needs a ticket to hide behind; most
  can't.
- Bug-resolution → gotcha prompt wiring: the single best
  self-improvement integration in the plan set. Keep.
