# support-admin — Child Plan 4: Billing Operations

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED (Phase 3,
  landing alongside billing plan_3)
- **Depends on:** plan_2, billing plans 2–3
- **Last updated:** 2026-07-08

## Goal

The money-adjacent support powers: see an org's billing truth, extend a
trial, comp an account, route refunds — bounded, audited, and never
duplicating what Stripe's dashboard already does well.

## Design

- **Subscription view (org detail extension):** tier, state, period,
  seats, trial/grace clocks, entitlement overrides in force, recent
  billing-relevant support_events, Stripe deep-links (customer +
  subscription pages) — read from OUR Subscription record (plan_2 of
  billing is truth for the app; Stripe link is for the money side).
- **Operation set (reason required, evented, org owners notified for
  anything they'd notice — surprise entitlement changes confuse the
  paying customer):**
  - **Extend trial:** +N days, bounded ≤30/action and ≤2 extensions per
    org without a second staff confirm (comp-culture guardrail; solo
    operation today, but the bound teaches the habit).
  - **Comp/override:** entitlement override object (tier-equivalent or
    single-feature grant) with **mandatory expiry ≤90 days** — no
    permanent comps by construction (renew deliberately or let it
    lapse); billing plan_2's Entitlements resolves overrides first.
  - **Grace nudge:** manually re-send dunning notice / extend grace ≤7
    days (the "their card expired while on vacation" op).
  - **Refunds: NOT in-app** (parent decision) — the op here is a
    support_event recording that a refund was issued in Stripe (reason +
    amount + Stripe ref), keeping our audit complete while Stripe does
    the money. Console shows a "record refund" form, not a refund
    button.
  - **Cancel-at-period-end on behalf** (customer emailed us instead of
    clicking) — confirm + owner notification.
- **Read-only lifecycle visibility:** orgs in past_due/read_only
  surfaced as a console dashboard lane (the proactive-outreach list).

## Implementation steps

- [ ] Subscription view + override display + deep-links.
- [ ] Override object in billing plan_2's resolver (co-built) + expiry
      sweep job.
- [ ] Trial extension + bounds; grace nudge; cancel-on-behalf; refund
      record — each with the full ceremony (reason/event/notify).
- [ ] Dunning-lane dashboard.
- [ ] Runbook: `docs/runbooks/support-billing.md` (incl. the
      no-permanent-comps policy in words).

## Tests

- Negative: extension beyond bounds → rejected; third extension without
  second confirm → rejected; override without expiry unrepresentable
  (model-level); lapsed override → entitlements revert (clock travel);
  owner notification sent for each visible op; refund "button"
  nonexistence (route sweep — the only refund path is the record form).
- Override precedence: override > subscription tier in Entitlements
  (matrix rows re-run under override).

## Open questions

1. **Owner notification on trial extensions** — (a) yes, always ("we
   added 14 days") **8/10**: it's a gift — say so, trust compounds;
   (b) silent **4/10**: invisible generosity buys nothing and surprises
   later.

## Critique

*Reviewed 2026-07-09.*

- Bounded extensions, mandatory-expiry overrides (no permanent comps by
  construction), refund-recording instead of refund-building, owner
  notifications on visible ops: no critique — the guardrails are
  right-sized for a solo operator and teach the habits a second staffer
  will need.
- The dunning-lane dashboard is quietly the most valuable piece for
  revenue retention — consider surfacing *why* (card expired vs
  payment declined, from Stripe's failure codes) in the lane so
  outreach emails can be specific; specificity doubles recovery rates
  on involuntary churn.
