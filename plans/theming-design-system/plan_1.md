# Parent Plan: Theming & Design System

- **Status:** NOT_STARTED
- **Phase:** 1
- **Depends on:** foundation
- **Blocks:** every UI surface (cues, boards, initiatives, marketing site)
- **Last updated:** 2026-07-08

## Objective

A token-driven design system where hardcoded colors are impossible, every
component is reusable and theme-aware, and the product voice (slightly snarky,
classy, soft) is codified. This must exist before the first product screen is
built, or cohesion is lost forever.

## Scope (from master_plan.md)

- Two built-in themes (light, dark) + organization themes (logo + choosing
  from color presets — org themes are premium/enterprise only).
- Light theme direction: older-style font, cursive logo, cream papyrus
  colors, charcoal texturing, deep darkened vibrant accents (dark scarlet).
- Minimal flair (explicitly: no accented side borders). Stark color reserved
  for color-coding and important buttons; destructive actions are red.
- **Hardcoded colors in components are a massive no-no** — enforced, not
  suggested.
- Coherent spacing/typography scales; variance only where meaningful
  (headers vs subtext).
- Snarky-but-helpful copy voice (canonical example: "normal people just call
  this a ticket; you can do that if you really want").
- Guided tutorials; minimal-click workflows (login → see a cue → manage it in
  very few clicks).

## Key decisions

### Recommended

1. **Semantic design tokens as CSS custom properties**, consumed by Tailwind
   v4 `@theme`. Tokens are semantic (`--color-surface`, `--color-ink`,
   `--color-accent`, `--color-destructive`), never raw palette names, so
   light/dark/org themes are pure token swaps. Org theme = preset accent
   palette + logo stored on the org, injected as a token layer.
2. **Enforcement (the "massive no-no" made mechanical):**
   - ESLint rule + custom lint banning color literals (`#…`, `rgb(`, Tailwind
     palette classes like `red-500`) in component files; only token-based
     classes allowed.
   - react-doctor at 100 (foundation gate).
   - A visual-regression smoke (Playwright screenshots per theme) on the
     component gallery.
3. **Component library first:** Button, Input, Select, Badge, Card, Modal,
   Toast, EmptyState, Avatar, Markdown renderer — built in a gallery page
   (Lookbook-style or a simple internal route) before any product screen.
   One-off components require a written justification in the PR.
4. **Voice & copy guide** (`docs/design/voice.md`): rules + examples for the
   snark level; all user-facing strings centralized so copy is reviewable and
   testable.
5. **Design standards doc** (`docs/design/standards.md`): spacing scale, type
   scale, color usage rules, do/don't examples — the enforcement companion
   the master plan asks for.

## Child plans to create

- `plan_2.md` — Token system + light/dark themes + theme switcher +
  enforcement lints (with negative tests: a hardcoded hex fails CI).
- `plan_3.md` — Core component library + gallery + visual regression.
- `plan_4.md` — Org themes: preset palettes, logo upload, admin UI, gating
  hook for billing (basic tier: locked).
- `plan_5.md` — Voice/copy guide + guided tutorial framework (first tutorial:
  "what's a cue?").

## Implementation order

1. [ ] plan_2 tokens/themes/enforcement (blocks all UI work).
2. [ ] plan_3 component library (blocks product screens).
3. [ ] plan_5 voice guide (cheap, do early — copy is everywhere).
4. [ ] plan_4 org themes (needs billing gating; can land with Phase 3).

## Test strategy

- Negative tests: hardcoded color literal fails lint; component without both
  theme renderings fails the gallery check; `any` in component props fails.
- Every component gets an RTL spec; gallery screenshots diffed per theme.

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Tokens + light/dark shipped with enforcement
- [ ] Component library v1 shipped
- [ ] Voice guide adopted
- [ ] Org themes shipped (billing-gated)

## Open questions

1. Font selection: "older style font" — serif like Cormorant/EB Garamond for
   headings with a humanist sans for body? Needs a taste decision from you;
   I'll present 2–3 candidate pairings as rendered samples during plan_2.
2. Cursive logo: generate placeholder wordmark now and commission/design a
   real one later? (Recommendation: placeholder now, noted in manual steps
   when a decision is due.)
3. How many org color presets at launch? (Recommendation: 6.)

## Critique

*Reviewed 2026-07-09.*

- **"Charcoal texturing" is the riskiest aesthetic instruction in the
  master plan.** Literal texture images under content hurt readability,
  fight the contrast checker, and age the design fast ("2012 wooden-desk
  app" territory). Recommend interpreting it as *at most* a ≤3%-opacity
  noise on large empty surfaces (marketing hero, empty states) and
  **never under body text**; flat charcoal surfaces carry the mood fine.
  The plan's automated AA checks would catch the worst of it, but only
  for token pairs — textures bypass token checks, hence this rule.
- The cream + dark-scarlet direction reads "classy stationery" and can
  drift "wedding invitation" if the serif gets ornate — the existing
  minimal-flair stance is the correct counterweight; hold the line on
  serif-for-display-only (body stays the humanist sans at all sizes
  below ~20px).
- Headless-primitive recommendation changed by research — see plan_3
  critique (Base UI over Radix; T4 re-ranked in questions.md).
- Enforcement stack (tokens + lint + gallery + goldens): no critique;
  see plan_2 critique for a structural simplification that makes the
  lint mostly redundant.
