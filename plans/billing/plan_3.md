# billing — Child Plan 3: Stripe Integration

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; manual steps (Stripe account — long-lead)
- **Last updated:** 2026-07-08

## Goal

Money moves: checkout, the customer portal, webhooks mutating the
Subscription record, trial conversion, dunning → grace, and enterprise
per-seat quantities — with Stripe kept at arm's length behind plan_2's
model.

## Design

- **Integration style (Q1):** Pay gem **7/10** — handles
  customers/webhooks/sync conventions, active maintenance, but its
  abstractions occasionally fight custom state machines; direct `stripe`
  gem + our own thin layer **7/10** — more code we fully control, no
  fighting, more webhook surface to get right. Decide at implementation
  start with a 1-day spike each way; either sits behind plan_2's model so
  the blast radius is contained.
- **Products/prices:** seeded from `Billing::TIERS` by an idempotent rake
  task (basic/premium × monthly/annual; enterprise = per-seat monthly
  price with quantity) — Stripe Dashboard is never hand-edited (drift
  check task compares Stripe ↔ TIERS in CI weekly).
- **Checkout:** Stripe Checkout session (hosted — minimal PCI surface,
  parent decision) from trial conversion or tier change; enterprise floor
  (≥100 seats) validated before session creation.
- **Portal:** Stripe Customer Portal for card/invoice/cancel
  self-service, configured to route plan *changes* through our UI
  (downgrade-block logic lives with us, not Stripe).
- **Webhooks:** verified signature, idempotency ledger
  (`stripe_events` processed-id table — duplicate delivery = no-op,
  negative-tested), handled set: checkout completed, subscription
  updated/deleted, invoice paid/payment_failed. Each maps to plan_2
  state transitions; unknown events logged + acked. Out-of-order safety:
  handlers converge on Stripe-fetched truth, never event-payload math.
- **Enterprise seats:** quantity = active members + reserved invites,
  pushed on membership change (debounced daily true-up job + immediate
  push when crossing thresholds — see Q2), proration left to Stripe.
- **Dunning:** payment_failed → past_due (plan_2 timers take over);
  Stripe Smart Retries on; paid → active restore.
- **Refunds:** manual via Stripe Dashboard (support-admin plan_4
  deep-links; no in-app refund automation at this scale).

## Implementation steps

- [ ] Spike + decide Q1; adapter skeleton behind plan_2.
- [ ] Seeding task + drift check.
- [ ] Checkout flow (trial conversion with card, tier changes) +
      enterprise floor validation.
- [ ] Webhook endpoint + ledger + handler set (fixture-driven specs from
      recorded events; stripe-mock or VCR — decide with Q1 spike).
- [ ] Portal config + return flows.
- [ ] Seat sync + true-up job.
- [ ] Test-mode E2E on staging incl. `stripe trigger` dunning rehearsal;
      then production keys (manual step) + first live transaction
      checklist.

## Tests

- Webhook: signature negative, duplicate no-op, out-of-order convergence
  (deleted-then-updated arrives → final state correct), each handler's
  state transition with clock travel.
- Checkout: enterprise 99 seats → blocked with message; basic→premium
  upgrade mid-cycle → entitlements flip on webhook, not on redirect
  (redirect races the webhook — negative test the optimistic path).
- Seat sync: membership add/remove/invite-reserve → expected quantity
  timeline (debounce table test).

## Open questions

1. *(above)* Pay gem 7/10 vs direct stripe gem 7/10 — spike decides.
2. **Seat push cadence (enterprise)** — (a) immediate push on change +
   daily true-up net **8/10**: invoice accuracy, self-healing;
   (b) daily only **5/10**: simpler, day-long drift windows;
   (c) monthly true-up **3/10**: surprise invoices.
3. **Cancellation** — (a) end-of-period with reads-forever (soft-delete
   policy from organizations plan_2 Q1 governs data) **8/10**;
   (b) immediate + prorated refund **4/10**: refund surface without need.

## Critique

*Reviewed 2026-07-09.*

- The arm's-length shape (Stripe mutates only the Subscription record;
  handlers converge on fetched truth; idempotency ledger) is exactly
  right — no critique on architecture.
- B3 (Pay gem vs direct): the 1-day-spike-each plan is honest; one
  thumb on the scale — our Subscription state machine is already
  designed and owned (plan_2), which reduces Pay's main value-add and
  raises its impedance-mismatch risk. Expect the spike to favor direct
  `stripe` gem + thin layer; let it prove otherwise.
- Enterprise seat push with proration will generate invoice line-item
  noise every membership change — for a 300-person org that's a messy
  invoice. B4's daily-true-up-net component matters more than the
  immediate push; consider *threshold-only* immediate pushes (±5 seats)
  with the daily net as the norm. Refinement of the ranked answer, not
  a reversal.
- Weekly Stripe↔TIERS drift check in CI: keep — that one prevents the
  classic "price changed in dashboard, app disagrees" incident.
