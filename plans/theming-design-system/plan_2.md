# theming-design-system — Child Plan 2: Tokens, Themes & Enforcement

- **Parent:** [plan_1.md](plan_1.md) · **Status:** DONE (2026-07-11)
- **Depends on:** foundation plan_2
- **Note:** the font pairing (parent Q1) is a taste call pending your
  answer — the token architecture ships with font *slots* and a placeholder
  pairing, so nothing here blocks on it.
- **Last updated:** 2026-07-08

## Goal

The token system that makes hardcoded colors impossible and themes a pure
data swap: semantic CSS custom properties, Tailwind v4 mapping, light
("papyrus") and dark ("charcoal") themes, and the lint machinery enforcing
all of it.

## Design

- **Token layers:** raw palette (private, defined only in the theme
  files) → semantic tokens (public API: `--color-surface`,
  `--color-surface-raised`, `--color-ink`, `--color-ink-muted`,
  `--color-accent`, `--color-accent-ink`, `--color-destructive`,
  `--color-border`, `--color-focus`, spacing/radius/type-scale tokens) →
  Tailwind v4 `@theme` maps semantic tokens to utilities. Components may
  only use semantic utilities.
- **Themes:** `html[data-theme=light|dark]`; default follows
  `prefers-color-scheme`, user override persisted on account (and
  localStorage pre-login). Org accent layer (plan_4) will override only
  the accent group — structure for that exists now.
- **Light "papyrus":** cream/warm-paper surfaces, charcoal ink, dark
  scarlet accent, muted deep-vibrant color-coding set. **Dark
  "charcoal":** charcoal surfaces, warm off-white ink, same accent family
  lifted for contrast. Every semantic pair ships with an automated WCAG AA
  check: a spec computes contrast ratios from the actual theme files —
  a failing pair is a failing build, both themes.
- **Fonts:** self-hosted (CSP: no external hosts), `--font-display` (the
  "older style" serif) + `--font-body` slots; placeholder pairing until
  parent Q1 is answered via rendered samples on the gallery page.
- **Enforcement:** ESLint rule banning color/size literals in
  `app/frontend` (hex, rgb/hsl, Tailwind palette classes like `red-500`,
  arbitrary values `[#...]`); RuboCop equivalent for any inline styles in
  ERB (marketing pages use the same tokens); react-doctor already at 100.
  Allowlist: the two theme definition files only.

## Implementation steps

- [x] Token architecture + theme files + Tailwind mapping — critique
      adopted: NO raw palette (`--color-*: initial`), semantic tokens
      only; palette classes don't compile (ADR 0013). Existing auth/org
      screens retrofitted in the same pass.
- [x] Theme switching (attr, persistence, no-flash inline script — CSP
      nonce-compatible; `javascript_tag nonce: true`, verified under the
      real CSP by the system suite). Account column
      `users.theme_preference` + PATCH /theme_preference + ThemeToggle;
      localStorage covers pre-login devices.
- [x] Contrast-check spec harness (parses tokens.css, computes WCAG
      ratios — text pairs 4.5:1, focus/borders 3:1, color-coding set
      against both surfaces per critique).
- [x] Lint rules + fixture tests — custom ESLint rule
      `cue/no-style-literals` (user ask, ratified): inline styles +
      color-shaped arbitrary values; RuleTester-covered; verified-fail
      2026-07-11. ERB equivalent is a spec guard (mailer views exempt —
      email clients need inline styles).
- [x] Font slots + self-hosting pipeline — EB Garamond Variable
      (display) + Inter Variable (body) via @fontsource (Q1 answered:
      "EB Garamond and humanist sans"); no sample page needed.
- [x] `docs/design/standards.md` v1: token API, scales, color usage
      rules incl. the ratified charcoal-texturing rule (small
      content-free elements only).

## Tests

- Negative: hex/rgb/palette-class in a component → lint failure (fixture
  specs for the rule itself); contrast below AA in either theme → spec
  failure; theme switch system test (both themes render, persist across
  reload, respect OS preference when unset).

## Open questions

1. *(parent Q1, to be decided from rendered samples)* **Font pairing** —
   (a) EB Garamond display + Inter body **7/10**: classic old-style, free,
   variable, safe; (b) Cormorant display + Source Sans 3 body **7/10**:
   more distinctive/cursive-adjacent display, slightly precious at small
   sizes; (c) Playfair Display + system sans **6/10**: handsome but
   overused in "classy" templates; (d) commission/custom **3/10** now:
   cost before product-market fit. Samples on the gallery page will make
   this a 10-minute decision.
   Answer: EB Garamond and humanist sans.

## Critique

*Reviewed 2026-07-09.*

- **Structural improvement — don't ship a raw palette at all.** Tailwind
  v4's `@theme` lets us define *only* semantic tokens; if `red-500` et
  al. are never defined, `text-red-500` doesn't compile and can't be
  written. That turns most of the color-literal lint into a
  can't-happen: the ESLint rule shrinks to banning arbitrary values
  (`[#…]`, `[rgb(…)]`) and inline styles. Prefer making violations
  *unrepresentable* over linting them — same philosophy as the DB
  constraints.
- The contrast-check spec computing WCAG ratios from actual theme files
  is the best mechanism in this plan — extend it to also cover the
  color-coding set against both surfaces (badges are where stark colors
  meet cream).
- Theme-switch no-flash inline script + nonce CSP: verify order of
  operations early (script must run before first paint AND satisfy the
  nonce) — this is a classic integration gotcha; budget an hour, not a
  surprise.
- Fonts: prefer variable fonts (single file per family) for the two
  slots — weight range without four font files; helps the Lighthouse
  budgets marketing plan_2 gates on.

## Critique feedback
Can we make custom es-lint rules for our styles then?
Great insight and we should do those things.