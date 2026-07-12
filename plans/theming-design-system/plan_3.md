# theming-design-system — Child Plan 3: Component Library & Gallery

- **Parent:** [plan_1.md](plan_1.md) · **Status:** DONE (2026-07-11) — Markdown
  component deferred to initiatives plan_3 (needs its sanitization rules)
- **Depends on:** plan_2 (tokens)
- **Last updated:** 2026-07-11

## Goal

The reusable component set every product screen composes from, displayed
in an internal gallery that doubles as the visual-regression and
design-review surface. Product plans (cues plan_6, boards plan_3/4, etc.)
consume; they do not invent.

## Design

- **v1 component set:** Button (primary/secondary/destructive/ghost),
  Input, Textarea, Select, Checkbox/Radio/Switch, FormField (label +
  hint + error composition), Badge (incl. color-coded variants from the
  coding palette), Card, Modal/ConfirmDialog (destructive confirmation
  variant), Drawer (mobile nav pattern), Toast, Tabs, Avatar, EmptyState
  (illustration slot + on-voice copy slot), Spinner/Skeleton, Table
  (responsive: collapses to cards on mobile), Markdown (render pipeline
  shared with initiatives — sanitization rules from initiatives plan_3),
  PageHeader, SideNav/AccordionNav.
- **Props discipline:** strict TS, no `any`, variant unions not booleans
  (`variant="destructive"` not `destructive`), no style/className
  pass-through except a constrained `className` for layout-only cases —
  made concrete per critique (2026-07-11): the pass-through accepts only
  spacing/flex/grid/width utility classes; anything color- or
  typography-shaped in a className is caught by the dedicated
  `cue/layout-only-classname` lint rule (statically-resolvable values
  only — a value built from a variable stays a review flag). Components
  that need no layout hook take no className at all.
- **Gallery:** internal route `/gallery` (dev + staging only, excluded in
  prod routes — negative-tested) rendering every component × variant ×
  theme × viewport. Serves three jobs: dev workbench, screenshot target,
  and the page where font samples (plan_2 Q1) and org-theme previews
  (plan_4) are judged.
- **Visual regression:** Capybara-driven screenshots of gallery sections
  diffed against committed goldens (tolerance-tuned); update = deliberate
  golden refresh in the PR, so visual drift is always a reviewed diff.
- **One-off rule:** a product screen needing a new component adds it to
  the library + gallery in the same PR, or justifies the one-off in the PR
  description (PR template line; reviewer enforces).

## Implementation steps

- [x] Gallery scaffold + prod exclusion + screenshot harness (2026-07-11).
- [x] Components in dependency order: primitives (Button, Badge, Input…)
      → composites (FormField, Card, Modal…) → patterns (Table,
      EmptyState, nav) — each lands with RTL spec + gallery entry +
      goldens in the same commit (2026-07-11).
- [ ] Markdown component — deferred, needs initiatives plan_3's
      sanitization rules first; revisit when that plan starts.
- [x] `docs/design/components.md`: the catalog + one-off rule + how to add
      a component (checklist) (2026-07-11).

## Tests

- RTL spec per component (behavior: keyboard interaction, aria, error
  states — not snapshot-only). 100% coverage, frontend gate.
- Accessibility: axe runs against `/gallery` in both themes
  (`spec/system/gallery_spec.rb`) via a hand-rolled helper
  (`spec/support/axe.rb`) — `axe-core-rspec`'s own matcher assumes a
  Selenium driver this suite's Cuprite driver doesn't implement
  (`.manage.timeouts`, window-switching), so this injects axe-core's own
  JS bundle and drives it through Capybara's driver-agnostic script
  evaluation instead. Caught two real, pre-existing, app-wide bugs on
  first run: `<html>` had no `lang`, and Inertia's client head manager
  was wiping `document.title` on every page (no `title` callback
  configured) — both fixed at the root, not just gallery-scoped.
- Negative: gallery route in production env → 404
  (`spec/requests/gallery_spec.rb`); component fixture with a hardcoded
  color → `cue/no-style-literals` failure; layout-only `className` with
  a color/typography token → `cue/layout-only-classname` failure.
- Visual: `#gallery-root` screenshots pixel-diffed against committed
  goldens (`spec/goldens/gallery/`, `spec/support/visual_regression.rb`)
  per theme × viewport, 1% differing-pixel tolerance, pure-Ruby
  (`chunky_png`, no native image deps). `UPDATE_GOLDENS=1 bundle exec
  rspec spec/system/gallery_spec.rb` regenerates — a reviewed diff, not
  a rake task as originally sketched (simpler: reuses the same
  Rails+Vite+Chrome boot the spec already needs). Verified deterministic
  across repeat runs in this environment (same pinned Chrome-for-testing
  build + self-hosted webfonts, locally and in CI).

## Open questions

1. **Headless primitives underneath** — (a) selective: Radix (or
   react-aria) only for genuinely hard widgets — Modal, Select, Tabs —
   hand-rolled rest **8/10**: a11y correctness where it's hard, zero
   dependency sprawl where it's easy; (b) all hand-rolled **5/10**:
   maximum control, we will get focus traps subtly wrong; (c) full
   component framework (MUI/Mantine) **2/10**: fights the design language
   and the no-hardcoded-color law.
   Answer: a
   *Resolved 2026-07-11: selective **Base UI** (critique re-ranking
   adopted — Radix on the wrong side of the maintenance trend). ADR 0014.*

## Critique

*Reviewed 2026-07-09.*

- **T4 re-ranked by research — Base UI displaces Radix.** Since the plan
  was drafted: Radix (acquired by WorkOS) has visibly slowed on complex
  components, while MUI's Base UI hit 1.0 in Dec 2025 with 35 components
  and a staffed maintenance commitment
  ([InfoQ](https://www.infoq.com/news/2026/02/baseui-v1-accessible/));
  shadcn/ui defaults to Base UI for new projects as of mid-2026
  ([comparison](https://www.shadcndeck.com/blog/radix-vs-base-ui),
  [LogRocket roundup](https://blog.logrocket.com/headless-ui-alternatives/)).
  Revised ranking (updated in questions.md): **selective Base UI 8/10**;
  react-aria 7/10 (gold-standard a11y, more assembly); Radix 5/10
  (works today, wrong side of the maintenance trend). Same "selective:
  Modal/Select/Tabs only" scope as before.
- Visual-regression goldens: flake risk is real (font rasterization
  differs across machines). Mitigations to bake in from day one: render
  screenshots only inside the CI container image, self-hosted fonts
  (already planned), small per-pixel tolerance, and goldens regenerated
  via one rake task. If flake persists twice → gotcha protocol →
  consider a DOM-snapshot fallback for structure and reserve pixel
  goldens for the theme pages only.
  *Resolved 2026-07-11: no dedicated CI container image exists (CI runs
  on plain `ubuntu-latest`) — the actual consistency guarantee is a
  pinned Chrome-for-testing build (fetched identically by
  `pnpm install`'s puppeteer step, locally and in CI) plus self-hosted
  webfonts, so nothing depends on host OS fonts. Deterministic across
  repeat local runs; pixel goldens shipped for all four theme×viewport
  combos rather than reserving them for theme pages only — no flake
  observed yet, so no DOM-snapshot fallback needed. Refresh command is
  `UPDATE_GOLDENS=1 bundle exec rspec spec/system/gallery_spec.rb`, not
  a rake task — same mechanism, less to maintain.*
- Constrained `className` pass-through: the "layout-only" rule is
  unenforceable by lint as stated — make it concrete: allow only
  spacing/flex/grid utility classes via an allowlist pattern, error on
  anything color/typography-shaped. Now it's a lint, not a review vibe.
  *Resolved 2026-07-11: `cue/layout-only-classname`
  (`eslint-rules/layout-only-classname.ts`), scoped to `Card`/`Skeleton`
  via `eslint.config.ts` — a separate rule from `cue/no-style-literals`,
  since that rule's job is different (catch arbitrary/inline colors
  everywhere) and it deliberately allows semantic tokens like
  `bg-surface` anywhere else in the app.*

## Critique feedback
Great insights. Modify this plan if you think we should, based on the callouts.