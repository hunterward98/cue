# 0013 — No raw palette: semantic-only tokens + a narrow custom lint

- **Date:** 2026-07-11 (theming plan_2; critique adopted, custom-rule ask
  ratified by user: "Can we make custom es-lint rules for our styles
  then? Great insight and we should do those things.")
- **Status:** accepted

## Context

The master plan calls hardcoded colors in components "a massive no-no."
The original design enforced this with a broad ESLint rule banning hex,
rgb(), and Tailwind palette classes. The plan_2 critique pointed out
Tailwind v4 allows something stronger: if the default palette is never
defined, `text-red-500` doesn't compile at all.

## Decision

1. `@theme { --color-*: initial; --font-*: initial }` deletes Tailwind's
   default palette and font stacks. The only color utilities that exist
   are semantic ones (`bg-surface`, `text-ink`, `bg-coding-moss-surface`,
   …) mapped from runtime tokens in `tokens.css` via `@theme inline`.
   Violations are _unrepresentable_, not linted — same philosophy as the
   DB constraints.
2. What compilation can't catch, a custom ESLint rule does
   (`eslint-rules/no-style-literals.ts`, RuleTester-covered): arbitrary
   values that smuggle colors (`bg-[#…]`, `text-[rgb(…)]`, `bg-(--var)`)
   and inline `style` attributes.
3. Server-rendered ERB gets a spec-level guard
   (`spec/design/erb_color_literals_spec.rb`); mailer views are exempt by
   design — email clients require inline styles, so mailer templates use
   light-theme literal values (notifications plan_2 owns that layout).
4. Theme values live in exactly one file (`tokens.css`), which the WCAG
   contrast spec parses and enforces for every documented pair, both
   themes, including the color-coding set.

## Why

A lint list chases violations; an empty palette prevents them. The
remaining lint is small enough to be obviously correct, and the contrast
gate turns "accessible in both themes" from a review vibe into a build
failure.

## Revisit when

A legitimate need for one-off colors appears (data viz is the likely
candidate — metrics-insights should extend the coding set or add a
chart palette through the same token + contrast-spec pipeline, not
arbitrary values).
