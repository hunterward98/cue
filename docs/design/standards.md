# Cue design standards (v1 — theming plan_2)

For: anyone styling anything in this repo. The companion enforcement:
tokens (this doc), the contrast gate (`spec/design/theme_contrast_spec.rb`),
the ESLint rule (`eslint-rules/no-style-literals.ts`), and the ERB guard
(`spec/design/erb_color_literals_spec.rb`).

## The token law

Components never carry a color. They use **semantic utilities** mapped in
`app/frontend/entrypoints/application.css` from the runtime tokens in
`tokens.css`. The raw Tailwind palette is deleted (`--color-*: initial`,
ADR 0013) — `text-red-500` does not compile. Arbitrary color values and
inline styles are lint errors. Mailer views are the one sanctioned
exception (email clients need inline styles; light-theme literals only).

### Token API

| Utility suffix                                                 | Use for                                                                          |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `surface` / `surface-raised`                                   | page background / cards, inputs, list rows                                       |
| `ink` / `ink-muted`                                            | body text / secondary text (both AA on both surfaces)                            |
| `border` / `border-strong`                                     | hairline dividers / input borders (3:1 checked)                                  |
| `focus`                                                        | focus rings only (3:1 checked)                                                   |
| `accent`, `accent-hover`, `accent-ink`                         | important buttons, links; ink goes on accent                                     |
| `destructive`, `destructive-hover`, `destructive-ink`          | destructive buttons only — red means "gone"                                      |
| `success-surface`/`success-ink`, `danger-surface`/`danger-ink` | flash banners, status lines                                                      |
| `coding-{scarlet,ochre,moss,teal,indigo,plum}-{surface,ink}`   | color-coding: badges, priorities. Ink is also legal as colored text on `surface` |

Every pair above is contrast-checked in both themes by the spec — add a
new token without adding its pair to the spec and review should bounce it.

## Themes

- `html[data-theme='light' | 'dark']` — stamped before first paint by the
  layout's nonce'd script; account preference wins, then localStorage
  (`cue-theme`), then `prefers-color-scheme`. Client twin:
  `app/frontend/lib/theme.ts` (keep the two in sync).
- Org accent presets (plan_4) will add `html[data-accent=…]` overriding
  only the accent group. Never theme base surfaces per org.

## Type & spacing

- `font-display` (EB Garamond, variable) — display/headings only, ~20px
  and up. Body text is always `font-body` (Inter, variable): Garamond
  below 20px drifts "wedding invitation" (plan_1 critique).
- Headings: `font-display text-3xl font-semibold tracking-tight` is the
  page-title idiom.
- Spacing/radius: Tailwind defaults; gaps in 2/4/6/8 steps. Variance is
  meaningful or it's noise.

## Color usage rules

- Stark color = color-coding + important buttons, nothing else.
- Destructive actions are red (`destructive`), and their confirmations
  are snark-free (voice guide, plan_5).
- No accented side borders. Minimal flair generally.
- **Charcoal texturing** (ratified 2026-07-11): only on small elements
  with no content inside them — priority arrows on cue cards, small
  background contrast in compact components. Never under body text,
  never on large surfaces; texture bypasses the contrast checker, so it
  gets no benefit of the doubt.

## Adding a token

1. Add the value to BOTH themes in `tokens.css`.
2. Map it in `@theme inline` in `application.css`.
3. Add its contrast pair(s) to `theme_contrast_spec.rb`.
4. Document the row in the table above.
