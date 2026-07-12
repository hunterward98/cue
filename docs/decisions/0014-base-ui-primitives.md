# 0014 — Headless primitives: selective Base UI (Modal, Select, Tabs, popovers)

- **Date:** 2026-07-11 (theming plan_3 T4; critique re-ranking, user:
  "Great insights. Modify this plan if you think we should")
- **Status:** accepted

## Context

The focus-trap/keyboard/aria class of widget is where hand-rolled
components go subtly wrong, so plan_3 always intended a headless library
for Modal/Select/Tabs only. The original candidate was Radix; by the
2026-07-09 research pass Radix (acquired by WorkOS) had visibly slowed,
while MUI's Base UI hit 1.0 (Dec 2025, 35 components, staffed
maintenance) and became shadcn/ui's default for new projects.

## Decision

`@base-ui/react` for the genuinely hard widgets — Dialog
(Modal/ConfirmDialog), Select, Tabs, and Popover (coach marks, plan_5) —
unstyled, wrapped once in our component library so product code never
imports Base UI directly. Everything easy (Button, Badge, Card, inputs,
Table, EmptyState…) stays hand-rolled on semantic tokens.

## Why

A11y correctness where it's hard to get right, zero dependency sprawl
where it isn't, and one wrap-layer so swapping libraries later touches
only the library components.

## Revisit when

Base UI breaks two upgrades in a row (gotcha threshold), or react-aria
becomes materially better maintained.
