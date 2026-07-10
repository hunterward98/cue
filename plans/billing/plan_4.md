# billing — Child Plan 4: Pricing Page & Upgrade/Downgrade UX

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_3; marketing plan_2 (public frame);
  organizations-users plan_4 (settings frame)
- **Last updated:** 2026-07-08

## Goal

The two faces of billing users actually see: the public pricing page that
converts, and the in-app billing panel where org owners manage their
plan — plus the tasteful upsell moments at gated features.

## Design

- **Public pricing page** (marketing frame, server-rendered): three tier
  cards rendered from `Billing::TIERS` (single source — a price change is
  one diff), monthly/annual toggle showing the 2-months-free math,
  feature comparison table, trial CTA ("two months free; we're patient"),
  enterprise card with seat calculator (slider → monthly cost, floor
  visible). FAQ section (trial terms, what read-only means, cancellation
  policy — honest answers, conversion through clarity).
- **In-app billing panel** (org owner settings dock): current plan +
  state banner (trialing with days left, past_due warning, read_only
  explainer), usage meters vs limits (members, board owners, active
  cues, storage — reading the same entitlements seam the enforcement
  uses, so meters never lie), invoice history (portal link), actions:
  convert trial / upgrade / downgrade / change period / cancel — upgrade
  = checkout; downgrade runs the block-check and renders the explainer
  payload ("remove 12 members first") when blocked.
- **Upsell touchpoints:** gated-feature encounters (linking, custom
  fields, themes, initiatives) render the locked state with one on-voice
  line + who-can-fix-it awareness: org owners get the upgrade CTA;
  non-owners get "ask your org owner" (no dead-end CTAs). One pattern
  component (`FeatureLock`), used everywhere, gallery-tested. No modals
  chasing users, no countdown-pressure patterns — trust posture extends
  to sales.
- **Trial nudges:** banner at 14/7/1 days remaining (dismissable until
  the last), conversion email at day 7-remaining (notifications infra).

## Implementation steps

- [ ] TIERS → pricing page rendering + annual toggle + enterprise
      calculator.
- [ ] FAQ copy (voice pass) + ToS/refund-policy links (marketing plan_4
      dependency for the linked docs).
- [ ] Billing panel: state banners, meters, action flows incl.
      downgrade-block explainer rendering.
- [ ] FeatureLock component + rollout across the four gated features.
- [ ] Trial nudge banners + email.
- [ ] Conversion analytics events (marketing plan_3's analytics choice).

## Tests

- Pricing page renders every TIERS value correctly (drift-proof: spec
  computes expected strings from the config); annual math exact;
  enterprise slider at 99 → floor message.
- Panel: each subscription state → correct banner + available actions
  (matrix); meters equal enforcement truth (seeded at-limit org shows
  full meter AND blocked action — one fixture, both assertions).
- Negative: non-owner sees no billing panel (404) and no upgrade CTAs in
  FeatureLock; billing actions POSTed by non-owner → rejected.
- Lighthouse budget on pricing page (marketing plan_2's gates).

## Open questions

1. **Show enterprise pricing publicly** — (a) yes, full transparency
   ($0.15/user, $19.99 floor, calculator) **8/10**: self-serve parent
   decision implies it; "contact us" pricing repels the small orgs we
   serve; (b) hide behind contact **3/10**.

## Critique

*Reviewed 2026-07-09.*

- Single-source pricing from `Billing::TIERS`, meters that read the
  enforcement seam, FeatureLock with role-aware CTAs, no dark
  patterns: no critique on the design.
- If B10 (enterprise differentiation) lands, the pricing page's
  "premium and enterprise have the same features" framing changes —
  the comparison table needs a real enterprise column, not a caps-only
  one. Sequence this plan after B10 is answered to avoid rewriting the
  table copy.
- The trial countdown banner: cap it at one dismissal-respecting
  banner — trial-pressure UI is where trust postures usually die;
  the plan already says this, flagging it as the line to hold under
  future conversion-rate anxiety.
