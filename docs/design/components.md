# Cue component catalog (theming plan_3)

For: anyone adding a screen or a component. Product screens compose from
this catalog; they do not invent their own buttons, cards, or dialogs.
Everything here is themed automatically — components never carry a
color of their own (docs/design/standards.md), so they render correctly
in both themes with zero per-component work.

See every entry live, in both themes and both viewports, at `/gallery`
(dev + staging only — production 404s it, negative-tested in
`spec/requests/gallery_spec.rb`).

## The catalog

| Component                     | Purpose                                                                                                                                                          |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AppShell`                    | Shell for signed-in screens: wordmark, page header, flash banners.                                                                                               |
| `AuthCard`                    | Shell for signed-out screens: centered card, title, flash banners.                                                                                               |
| `Avatar`                      | Initials-in-a-circle, hue derived from name, decorative (`aria-hidden`, name is the tooltip).                                                                    |
| `Badge`                       | Neutral or color-coded (`coding-*`) label — priorities, statuses, board identity.                                                                                |
| `Button`                      | `primary` / `secondary` / `destructive` / `ghost`.                                                                                                               |
| `Card`                        | Generic titled container. Accepts a **layout-only** `className` (see below).                                                                                     |
| `Checkbox`, `Radio`, `Switch` | Form controls with real semantics (native inputs for the first two, a hand-rolled `role="switch"` for the third — not hard enough to earn Base UI).              |
| `ConfirmDialog`               | Destructive-confirmation `Modal` — snark-free by voice rule, destructive variant is the default.                                                                 |
| `Drawer`                      | Mobile nav pattern: left-sliding panel on the same Base UI dialog machinery as `Modal`.                                                                          |
| `EmptyState`                  | Title + on-voice copy slot + optional illustration slot + optional action.                                                                                       |
| `FormField`                   | Label + hint + error composition; wires aria via context so `Input`/`Textarea`/`Select` never forget it.                                                         |
| `Input`, `Textarea`           | Bare form fields — read their id/aria wiring from `FormField`'s context.                                                                                         |
| `Modal`                       | Base UI `Dialog` wrapped once; product code never imports Base UI directly (ADR 0014).                                                                           |
| `PageHeader`                  | Title + subtitle + actions row.                                                                                                                                  |
| `Select`                      | Base UI `Select` wrapped once.                                                                                                                                   |
| `SideNav`                     | Section nav: side rail on desktop, accordion on mobile.                                                                                                          |
| `Skeleton`                    | Loading placeholder block. Accepts a **layout-only** `className` (see below).                                                                                    |
| `Spinner`                     | Quiet circular spinner, `aria-label` for screen readers.                                                                                                         |
| `Table`                       | Responsive: a real `<table>` from `sm` up, stacked cards below — same column defs either way.                                                                    |
| `Tabs`                        | Base UI `Tabs` wrapped once.                                                                                                                                     |
| `TextField`                   | The label+input convenience nearly every form wants — composed from `FormField` + `Input`.                                                                       |
| `ThemeToggle`                 | Cycles system → light → dark; applies instantly, persists to the account.                                                                                        |
| `Toast`                       | `ToastProvider` + `useToast()` — success/danger, auto-dismiss, `aria-live="polite"`. Flash banners (server-driven) are separate; toasts are client-side moments. |
| `Wordmark`                    | Inline SVG wordmark — self-hosted display font, no raster asset.                                                                                                 |

`Markdown` (the render pipeline shared with initiatives' sanitization
rules) isn't built yet — it lands when initiatives plan_3 does, since
the sanitization rules live there.

## Headless primitives

Modal, Select, Tabs, and Drawer (built on the same `Dialog` as Modal)
wrap Base UI (`@base-ui/react`) for the a11y-hard parts — focus trap,
roving tabindex, positioning. Everything else is hand-rolled on semantic
tokens. Full rationale: [ADR 0014](../decisions/0014-base-ui-primitives.md).
Product code imports `Modal`/`Select`/`Tabs`/`Drawer` from
`@/components`, never `@base-ui/react` directly — if a screen needs a
Base UI widget the catalog doesn't wrap yet, that's a new catalog entry,
not a direct import.

## Props discipline

- Strict TS, no `any`.
- Variant unions, not booleans (`variant="destructive"`, not
  `destructive`).
- No style/className pass-through, with one constrained exception:

### The `className` escape hatch

`Card` and `Skeleton` accept a `className` prop for layout-only
composition (`p-4`, `flex flex-col gap-2`, `w-40`, …) — spacing, flex,
grid, and width/height utilities only. Anything color- or
typography-shaped is a lint error: `cue/layout-only-classname`
(`eslint-rules/layout-only-classname.ts`), configured with the exact
component list in `eslint.config.ts`. It only checks statically
resolvable className values (string literals, `{"..."}`, untagged
template literals) — a value built from a variable or a `cn(...)` call
stays a review flag, same as it was before this rule existed.

**Extending the list:** if a new component earns a layout-only
`className` prop, add its name to the `cue/layout-only-classname` array
in `eslint.config.ts` in the same PR that adds the prop.

## Adding a component

1. Build it hand-rolled on semantic tokens, or wrapped once around Base
   UI if it's a hard a11y widget (focus trap, listbox, roving tabindex —
   ask before reaching for a new headless dependency).
2. RTL spec: behavior (keyboard interaction, aria, error states), not
   snapshot-only.
3. Add a section to `/gallery` (`app/frontend/pages/gallery/show.tsx`)
   showing every variant.
4. Add the row to the catalog table above.
5. If it needs a `className` escape hatch, make the case for it in the
   PR description and add it to the lint allowlist (above).

**One-off rule:** a product screen needing a new component adds it to
the library + gallery in the same PR, or justifies the one-off in the
PR description (PR template line; reviewer enforces).

## Tests

- RTL spec per component — behavior, not snapshot-only.
- Accessibility: axe runs against `/gallery` in both themes
  (`spec/system/gallery_spec.rb`) — through a small hand-rolled helper
  (`spec/support/axe.rb`), not the `axe-core-rspec` gem, which assumes a
  Selenium driver this suite's Cuprite driver doesn't provide.
- Visual: `/gallery` screenshots (`#gallery-root`, both themes × both
  viewports) pixel-diffed against committed goldens in
  `spec/goldens/gallery/` (`spec/support/visual_regression.rb`), 1%
  differing-pixel tolerance. Update deliberately:
  `UPDATE_GOLDENS=1 bundle exec rspec spec/system/gallery_spec.rb` — a
  reviewed diff, never automatic.
- Negative: `/gallery` 404s in production
  (`spec/requests/gallery_spec.rb`); a component fixture with a
  hardcoded color fails `cue/no-style-literals`; a layout-only
  component's `className` with a color/typography token fails
  `cue/layout-only-classname`.
