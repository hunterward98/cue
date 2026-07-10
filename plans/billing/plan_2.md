# billing — Child Plan 2: Entitlements Layer & Tier Enforcement

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** organizations-users plan_2 (the stub seam it replaces)
- **Sequenced with Phase 2** — gates exist before Stripe does.
- **Last updated:** 2026-07-08

## Goal

Replace the entitlements stub with the real thing: tier definitions as
data, a Subscription record independent of Stripe, and every limit in the
ratified tier matrix enforced and negative-tested at one seam.

## Design

- **Tier definitions in code** (`Billing::TIERS` frozen config — parent
  Q-adjacent choice: config constant 8/10 vs DB table 6/10; versioned,
  reviewable, no admin UI to secure): per tier — user cap, board-owner
  cap, feature set (custom_fields, cue_linking, initiatives,
  custom_theme), upload_bytes, active_cue cap, trial length, prices
  (single source: pricing page and Stripe seeding both read this).
- **Subscription (on Organization, exactly one active):** tier, state
  machine `trialing → active → past_due → read_only → canceled`
  (+ `trialing → trial_expired(read_only-equivalent)`), period
  (monthly/annual), current_period_end, seats (enterprise), Stripe ids
  (null until plan_3). Trials start at org creation with tier selection
  (parent decision, no card).
- **Entitlements service (the seam):** `allows?(feature)`,
  `limit_for(metric)`, `within_limit?(metric, current)` — resolves from
  subscription state: read_only/trial_expired states force a global
  mutations-off answer that a controller-level guard consults (reads
  always work; the parent's never-hold-data-hostage rule). Solid-Cache
  cached per org, busted on subscription change.
- **Enforcement inventory (each = code + negative test, the tier
  matrix cells):** members ≤ cap at invite/approve (seat reservation per
  organizations plan_3); board owners ≤ cap at role grant; active cues ≤
  50 basic at create+reopen (count = non-resolved org-wide; resolved
  excluded — matrix-tested); upload bytes at attach; feature gates at
  their seams (cues plan_7, theming plan_4, initiatives plan_2);
  enterprise seat floor (≥100) at checkout + downgrade-block logic
  (can't drop to a tier your usage exceeds — structured explainer
  payload the UI renders as "you'd need to remove 12 members first").
- **Grace lifecycle mechanics** (states + timers here; Stripe triggers in
  plan_3): past_due day 0/7/12 warning mails (notifications infra),
  day 14 → read_only; read_only banner org-wide; restore on payment.

## Implementation steps

- [ ] TIERS config + Subscription model/state machine + org-creation
      trial hookup.
- [ ] Entitlements service replacing the stub (same interface — Phase 2
      call sites just start telling the truth) + cache.
- [ ] Read-only guard + banner + reads-still-work verification.
- [ ] Enforcement inventory audit: every matrix cell traced to a call
      site + negative test (tracked as a checklist in this file when
      executed).
- [ ] Grace timers (Solid Queue scheduled checks) + warning mails.
- [ ] Downgrade-block explainer payloads.

## Tests

- The tier matrix as a spec table: every cell positive + negative per
  tier (parent's "negative-test bonanza").
- State machine: every transition + timer with clock travel; read_only
  blocks every mutation endpoint (request-spec sweep tagged
  :write_endpoint — auto-covers new endpoints via shared example) while
  reads pass.
- Cache: stale-entitlement window after upgrade ≤ request boundary
  (bust-on-write asserted).

## Open questions

1. **Trial tier default at org creation** — (a) premium trial by default
   (experience the full product, downgrade to basic at conversion)
   **8/10**: classic PLG, the 2-month premium taste sells linking/
   initiatives; (b) chosen tier trialed as-is **6/10**: honest but
   undersells; (c) basic default **3/10**: hides the paid surface.
2. **Annual billing for trials** — (a) trial converts to either period at
   card entry **8/10**; (b) annual only post-trial **2/10**: pointless
   friction.

## Critique

*Reviewed 2026-07-09.*

- Config-constant tier definitions, subscription state machine, single
  entitlements seam, read-only-never-delete: no critique — this is the
  textbook shape for early-stage billing.
- One subtlety to pin down when B1 (premium-trial-for-all) is decided:
  the *trial* subscription must record both the trialed tier (premium)
  and the *chosen* tier so expiry/conversion lands on intent, not on
  the trial's elevated state — and downgrade-at-conversion (premium
  trial → basic paid) will trip the over-limit blocker if the org used
  premium features (11 board owners, custom fields). Design the
  conversion flow to run the same downgrade-explainer ("you're using 3
  premium things — keep premium or remove them") rather than
  discovering it as a bug report. This is the one place trial UX and
  the entitlement blocker collide.
- Grace timers via scheduled checks: prefer one idempotent daily sweep
  over per-org scheduled jobs (fewer moving pieces, same outcome);
  minor.
