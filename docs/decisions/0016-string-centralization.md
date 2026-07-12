# 0016 — String centralization: typed strings.ts, no i18n runtime

- **Date:** 2026-07-11 (theming plan_5 Q1; user: "Yeah don't think I
  will ever add multi-language")
- **Status:** accepted

## Context

Voice review (plan_5) needs one diff surface to check, and copy needs
to be testable against the voice guide's denylist. The candidates were:
typed `strings.ts` modules per frontend feature with no i18n runtime,
a real i18n runtime (react-i18next) ahead of any second language to
justify it, or leaving strings inline in JSX.

## Decision

Frontend user-facing strings live in typed `strings.ts` modules,
one per feature area, imported by the components that use them — no
i18n runtime, no translation-key indirection. Server-rendered strings
(mailers, marketing, validation messages) stay in Rails i18n
(`config/locales/en.yml`), which the framework already gives us for
free.

**The seam (plan_5 critique):** validation/error copy is server-decided
and arrives at the client as Inertia props — `strings.ts` never
rewrites or duplicates it. Only strings the frontend itself originates
(labels, empty states, tutorial copy, static page text) go in
`strings.ts`.

## Why

No second language is coming (user, ratified) — a translation-key
indirection layer bought for a future that isn't happening is exactly
the "poor design choice" the master plan warns against. Plain typed
modules get full TS safety and zero runtime cost, and if a second
language ever does become real, mechanically extracting values from
`strings.ts` into a runtime i18n format is a bounded refactor, not an
architecture change made speculatively today.

## Scope note

This ADR ratifies the mechanism; it does not retrofit the strings that
already exist across auth/org/gallery pages, and it does not add the
literal-JSX-string lint plan_5 describes. Both are deferred — see
Revisit when.

## Revisit when

The `strings.ts` retrofit and its lint are worth doing once cues (and
ideally boards-workflow) have landed: most of the app's user-facing
surface exists then, so the mechanical move happens once instead of
twice. Doing it now, before those plans are even reviewed, means
redoing it. A second language ever becoming real reopens the "no i18n
runtime" half of this decision.
