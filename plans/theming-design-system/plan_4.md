# theming-design-system — Child Plan 4: Organization Themes

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_3; billing plan_2 (entitlements gate);
  organizations-users plan_4 (settings frame)
- **Last updated:** 2026-07-11

## Goal

Premium/enterprise orgs pick a preset accent palette and upload a logo,
and the whole app (for their members) wears it — without ever letting an
org theme break contrast, cohesion, or the token law.

## Design

- **Presets, not free color pickers (master plan: "selecting a preset of
  colors"):** each preset defines the accent token group
  (`--color-accent`, `--color-accent-ink`, hover/active states) for BOTH
  light and dark themes, pre-validated for AA contrast at build time by
  plan_2's harness. Launch set: **8 presets** (parent Q3 and this plan's
  Q2 both answered 8, overriding the 6-preset recommendation — Design
  updated to match) in the deep-vibrant family — scarlet (default),
  forest, indigo, bronze, plum, slate, plus two more in the same family
  to reach 8: **amber** and **cobalt**. Exact hex values are a taste
  pass at implementation time (build-time AA validation gates all 8 ×
  both themes before any ships); the names here are placeholders for
  "which 8," not final color decisions.
- **Application** (critique, adopted — simplification): each preset is
  static CSS keyed on `html[data-accent="scarlet"]` etc. (an attribute
  set alongside `data-theme`), living in the same file plan_2's contrast
  checker already reads — **no inline style injection, no CSP nonce
  surface for this feature.** Inline injection is only needed for
  *arbitrary* org colors, which the master plan explicitly rejected
  ("selecting a preset of colors") — a finite, known preset set doesn't
  need it. Base surfaces/ink never change — org themes recolor the
  accent, not the app, which is how cohesion survives customization.
- **Logo:** replaces the wordmark in org-scoped chrome. Formats: see Q1.
  Constraints: max 1MB, min/max dimensions, rendered in a fixed-height
  slot on both themes (preview shows both).
- **Settings UI (docks in org settings):** preset swatches with live
  preview (gallery components rendered in-place with the candidate
  accent), logo upload with both-theme preview, reset-to-default. Basic
  tier: section visible but locked with an on-voice upsell line —
  **"your theme is waiting"** (critique, adopted: the preset choice is
  retained through a downgrade, so re-upgrading restores it for free —
  the copy should say so) — gated by
  `Entitlements#allows?(:custom_theme)`.
- Downgrade behavior: org theme reverts to default automatically when
  entitlement lapses (billing plan_2's read-only/downgrade hooks call a
  revert); the preset choice itself is retained on the org record, not
  cleared, so re-upgrading is a free restore.

## Implementation steps

- [ ] Preset definitions (`html[data-accent]` static CSS, critique) +
      build-time AA validation for all 8 presets × both themes.
- [ ] `data-accent` attribute set alongside `data-theme` (no-flash
      script + client theme.ts, same pattern plan_2 already established)
      + membership-scoped application.
- [ ] Logo upload (Active Storage, validation, variants for chrome + 
      email header usage by notifications plan_2).
- [ ] Settings panel + live preview + gate + upsell state.
- [ ] Downgrade revert hook.
- [ ] Gallery gains an org-theme dimension (preview any preset).

## Tests

- Negative: basic-tier org POSTing a theme change → rejected at the seam
  (UI lock is not the enforcement); preset id outside the known set →
  rejected (no arbitrary color injection); oversized/wrong-format logo →
  rejected; lapsed entitlement → revert applied.
- Contrast spec covers every preset in both themes; visual goldens for
  2 presets × 2 themes on key gallery sections.

## Open questions

1. **Logo formats** — (a) PNG/JPEG/WebP only **8/10**: no SVG attack
   surface (scripts/external refs), designers can export anything to PNG;
   (b) + SVG with strict sanitization **5/10**: crisper, but sanitizers
   miss things and this is a paid-tier feature touching every page;
   (c) SVG unsanitized **0/10**.
   Answer: A for simplicity.
2. *(parent Q3)* **Preset count at launch** — (a) 6 **8/10**: enough
   choice, all hand-validated; (b) 10+ **5/10**: validation and taste
   burden grows linearly; (c) 3 **5/10**: feels stingy for a paid
   feature.
   Ansewr: I think I said 8.
   *Confirmed 2026-07-11: matches plan_1's Q3 ("Make it 8" — the same
   answer, not a new one), which overrides this question's own (a) 6
   recommendation. Design above updated to 8 named presets.*

## Critique

*Reviewed 2026-07-09.*

- **Simplification — presets don't need inline style injection.** With a
  finite preset set, ship each as static CSS under
  `html[data-accent="scarlet"]` etc., set the attribute alongside
  `data-theme`, and delete the nonce'd inline style block entirely: no
  dynamic CSS, no CSP style surface, presets live in the same file the
  contrast checker already reads. The inline-injection design is only
  needed for *arbitrary* org colors — which the master plan explicitly
  rejected ("selecting a preset"). Adopt the attribute approach.
  *Resolved 2026-07-11 (Critique feedback: "Great insights"): adopted —
  Design and Implementation steps above now specify `data-accent`
  static CSS, no inline injection, no nonce.*
- Raster-only logos (T-logo Q1a): stands; SVG sanitization is a losing
  game for a paid-tier feature rendered on every page.
- Downgrade auto-revert: right, and consistent with the never-vandalize
  rule elsewhere — since the org's preset choice is retained on the org
  record, re-upgrade restores it for free; say so in the upsell copy
  ("your theme is waiting").
  *Resolved 2026-07-11: adopted — "your theme is waiting" is the
  specified upsell line for the Settings UI's locked/basic-tier state.*
- No other critique.

## Critique feedback
Great insights.
