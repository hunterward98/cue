# Parent Plan: Billing

- **Status:** NOT_STARTED
- **Phase:** 3
- **Depends on:** organizations-users, cues (features to gate)
- **Blocks:** premium feature launches (linking, custom fields, org themes, initiatives)
- **Manual steps:** [manual_steps_plan_1.md](manual_steps_plan_1.md)
- **Last updated:** 2026-07-08

## Objective

Organizations pay for a monthly or annual license across three tiers, and the
app enforces tier entitlements everywhere. Entitlements land first (as a
feature-flag layer with all limits testable), payment processing second.

## Tier matrix (from master_plan.md — the contract)

| | Basic | Premium | Enterprise |
|---|---|---|---|
| Price | $3.99/mo | $13.99/mo | $0.15/user/mo, min $19.99/mo |
| Users | ≤ 15 | ≤ 200 | ≥ 100 (minimum), unlimited above |
| Board owners | 2 | 10 | unlimited |
| Custom ticket fields | ✗ | ✓ | ✓ |
| Upload limit / cue | 2 MB | (default, define) | (default, define) |
| Active cue cap (backlog + boards, excl. completed) | 50 | — | — |
| Cue linking | ✗ | ✓ | ✓ |
| Initiatives | ✗ | ✓ | ✓ |
| Custom themes | ✗ | ✓ | ✓ |
| Trial | 2 months | 2 months | none |
| Billing period | monthly or annual | monthly or annual | monthly |

## Key decisions

### Recommended

1. **Stripe** (Checkout + Customer Portal + webhooks via the `stripe` gem —
   possibly Pay gem for Rails integration; decide in child plan). Stripe
   hosts card entry, tax, invoices, and the self-serve portal — minimal
   PCI/UI surface for us.
2. **Entitlements as a first-class internal layer**, independent of Stripe:
   `Plan` (basic/premium/enterprise) + `Subscription` on the org +
   `Entitlements` service answering `org.allows?(:cue_linking)` /
   `org.limit_for(:active_cues)`. Every gated feature calls this one seam —
   Stripe only mutates the subscription record via webhooks. This lets all
   gating ship and be tested before Stripe exists.
3. **Trials without a card:** 2-month trial on basic/premium starts at org
   creation with tier selection; card required to convert. Enterprise = sales
   conversation, no self-serve trial (per master plan).
4. **Grace handling:** payment failure → 14-day grace (email warnings) →
   read-only mode (data visible, mutations blocked) → never silent deletion.
   Downgrade with over-limit state (e.g. 30 users dropping to basic) → block
   the downgrade until under limits, with a clear explainer.
5. **Annual pricing (ratified 2026-07-08):** annual = 10× monthly
   (2 months free): basic $39.90/yr, premium $139.90/yr; enterprise is
   monthly-only per master plan.
6. **Support-side billing operations** (extend trial, comp an account,
   refunds, entitlement overrides) live in
   [support-admin plan_4](../support-admin/plan_1.md) and ship in Phase 3
   alongside plan_3 here; org-owner-facing billing UI is plan_4 below.

## Child plans to create

- `plan_2.md` — Entitlements layer + tier limits enforced across cues,
  boards, orgs, themes, initiatives (the negative-test bonanza).
- `plan_3.md` — Stripe integration: checkout, portal, webhooks, trials,
  grace/read-only lifecycle, invoices.
- `plan_4.md` — Pricing page + upgrade/downgrade UX in org settings
  (upsell moments where gated features are touched — tasteful, on-voice).

## Implementation order

1. [ ] plan_2 entitlements (ship with Phase 2 so gates exist from day one).
2. [ ] plan_3 Stripe (requires manual account setup).
3. [ ] plan_4 pricing/upgrade UX.

## Test strategy

- Every cell of the tier matrix has a positive and a negative test (basic org
  linking a cue → fail; premium 201st user → fail; enterprise 99 users → fail
  at checkout with clear message; basic 51st active cue → fail; resolved cues
  don't count toward the 50).
- Webhook tests with recorded Stripe fixtures; idempotency (duplicate webhook
  delivery) tested; clock-travel tests for trial expiry and grace windows.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Entitlements layer shipped
- [ ] Stripe live in test mode
- [ ] Stripe live in production
- [ ] Pricing/upgrade UX shipped
- [ ] ToS updated with billing terms; refund policy written

## Open questions

1. ~~Annual discount amount.~~ **RATIFIED 2026-07-08** — 2 months free
   (annual = 10× monthly).
2. Upload limit for premium/enterprise (recommendation: 25 MB/cue).
3. Per-tier trial→expiry behavior: does an expired trial org go read-only
   (recommendation) or lock entirely?
4. Enterprise sales flow: self-serve with a 100-seat floor, or contact-us?
   (Recommendation: self-serve; contact-us costs a salesperson we don't have.)

## Critique

*Reviewed 2026-07-09.*

- **⚠ Business-model critique: enterprise is dominated by premium for
  most of its addressable range.** Run the numbers: enterprise at 100
  users = $0.15 × 100 = $15.00 → below the $19.99 floor, so a 100-user
  org pays **$19.99**; premium serves up to 200 users at **$13.99**
  with (per the master plan) the *same features* — enterprise's only
  differentiator is unlimited board owners vs 10. So a rational buyer
  picks premium until they exceed 200 users or 10 board owners; the
  100–200-user "enterprise" range is priced above a cheaper identical
  product. Not fatal — but it makes the enterprise tier a dead zone.
  Two alternatives (new question **B10**):
  1. **(Recommended) Differentiate enterprise on capabilities, not just
     caps:** org-required-2FA policy, SSO (when built), audit-log
     export, support-access (break-glass) reports, priority support.
     These map to what >100-user orgs actually procure on, cost us
     little (several are already planned features gated one tier
     higher), and give the tier a reason to exist at its price.
  2. **Reprice the seam:** drop premium's cap to ~100 users so
     enterprise begins where premium ends (cleaner ladder), or price
     enterprise at $0.12/user with a $24 floor so it undercuts premium
     near the boundary. Pure pricing surgery, your call — the master
     plan's numbers are preserved-by-default until you say otherwise.
- Tier limits as negative tests, entitlements-before-Stripe: no
  critique — that sequencing is the strongest engineering decision in
  this feature.
- 2-month trials are unusually long (industry: 14–30 days). Deliberate
  and stated in the master plan, so no change — but instrument
  trial-week-N activity from day one so the retro can see whether
  months 1–2 convert or just delay the decision.
