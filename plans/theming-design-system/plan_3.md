# theming-design-system — Child Plan 3: Component Library & Gallery

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2 (tokens)
- **Last updated:** 2026-07-08

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
  pass-through except a constrained `className` for layout-only cases
  (documented rule — a pass-through that alters color/typography is a
  review flag).
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

- [ ] Gallery scaffold + prod exclusion + screenshot harness.
- [ ] Components in dependency order: primitives (Button, Badge, Input…)
      → composites (FormField, Card, Modal…) → patterns (Table,
      EmptyState, nav) — each lands with RTL spec + gallery entry +
      goldens in the same commit.
- [ ] Markdown component (coordinated with initiatives plan_3 pipeline).
- [ ] `docs/design/components.md`: the catalog + one-off rule + how to add
      a component (checklist).

## Tests

- RTL spec per component (behavior: keyboard interaction, aria, error
  states — not snapshot-only).
- Accessibility: axe checks run against the gallery page (violations
  fail).
- Negative: gallery route in production env → 404; component fixture with
  hardcoded color → lint failure (plan_2's rule, verified against real
  components here).
- Visual: golden diffs per theme × viewport.

## Open questions

1. **Headless primitives underneath** — (a) selective: Radix (or
   react-aria) only for genuinely hard widgets — Modal, Select, Tabs —
   hand-rolled rest **8/10**: a11y correctness where it's hard, zero
   dependency sprawl where it's easy; (b) all hand-rolled **5/10**:
   maximum control, we will get focus traps subtly wrong; (c) full
   component framework (MUI/Mantine) **2/10**: fights the design language
   and the no-hardcoded-color law.
   Answer: a

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
- Constrained `className` pass-through: the "layout-only" rule is
  unenforceable by lint as stated — make it concrete: allow only
  spacing/flex/grid utility classes via an allowlist pattern, error on
  anything color/typography-shaped. Now it's a lint, not a review vibe.

## Critique feedback
Great insights. Modify this plan if you think we should, based on the callouts.