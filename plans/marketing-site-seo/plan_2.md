# marketing-site-seo — Child Plan 2: Landing, Pricing & About

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** theming plan_2 (tokens); billing plan_4 (pricing page
  content — co-built); manual steps (name/domain pending)
- **Note:** final copy hinges on the product name/domain decision
  (manual step) — this plan is concrete on structure/mechanics and
  slot-based on copy, per the parent-question rule.
- **Last updated:** 2026-07-08

## Goal

The public face that converts a searching office manager into a trial:
landing page, pricing (billing plan_4 owns the tier logic; this plan
owns the frame), and about — fast, honest, on-voice.

## Design

- **Mechanics:** server-rendered ERB on the marketing layout (no
  Inertia/React payload — zero-JS pages except the pricing calculator's
  sprinkle), same design tokens (brand cohesion without shipping the app
  bundle), edge-cacheable (public, no session reads), Lighthouse CI
  budgets ≥95 across the board (parent gate).
- **Landing structure (copy in slots pending name):** hero — the
  one-sentence promise (working thesis: "the ticket system for teams who
  hate ticket systems"; final copy post-name) + product screenshot
  (real app, both themes, refreshed by a screenshot-from-gallery build
  step so marketing never shows a stale UI); problem section (Jira's
  too much, email threads are too little — the wedge); how-it-works
  (request → backlog → Charlie's board → done, in four illustrated
  steps); audience strips (design teams / marketing / office IT — each
  echoing plan_6's audience pages); trial CTA (two months free, no
  card); footer (legal, about, contact, updates, security posture line).
- **About:** short, human, why-we-built-it; feeds the trust decision
  small offices make. **Contact/feedback** entry points route to plan_5.
- **Conversion instrumentation:** page → signup-start → verified →
  org-created funnel events via the analytics choice (plan_3 Q2) — no
  personal data in events, consistent with the privacy stance.

## Implementation steps

- [ ] Marketing layout + tokens + zero-JS discipline + cache headers.
- [ ] Landing structure with copy slots; working copy drafted for
      everything name-independent.
- [ ] Screenshot-from-gallery build step (placeholder art until Phase 2
      screens exist).
- [ ] Pricing frame (billing plan_4 docks) + about + footer.
- [ ] Lighthouse CI wiring + budgets.
- [ ] Funnel events.
- [ ] Copy finalization pass once name lands (voice review).

## Tests

- Lighthouse budgets as CI gates; zero-JS assertion on landing/about
  (no script tags beyond analytics snippet — negative test); links
  valid (crawler spec); screenshots build step produces current-version
  images (hash check against gallery build); funnel events fire in
  system test without PII payloads (negative content assertion).

## Open questions

1. **Product screenshots vs illustrations in hero** — (a) real
   screenshots via the automated gallery step **8/10**: honest, always
   current, this product is its UI; (b) stylized illustrations **5/10**:
   prettier at launch, drifts from reality, ongoing art cost.

## Critique

*Reviewed 2026-07-09.*

- Zero-JS server-rendered marketing pages + tokens + Lighthouse gates:
  no critique on the architecture; the screenshot-from-gallery build
  step (marketing can never show a stale UI) is the standout idea and
  worth the build cost.
- One gap: **social share images.** Public marketing/content pages need
  real OG images (the app-side generic card is deliberate; the
  marketing side needs designed ones). Cheapest coherent version: an
  OG-image template rendered by the same gallery/screenshot step —
  add it as an implementation step rather than discovering it when the
  first shared link looks naked on LinkedIn.
- Working-thesis hero copy ("the ticket system for teams who hate
  ticket systems") punches at the right wedge; keep the final line
  A/B-honest — one hero claim, tested against "fewer clicks from
  request to done," once analytics exist. No further critique.
