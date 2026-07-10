# 0006 — TS strict-plus, single @/ alias, types fail the build

- **Date:** 2026-07-09
- **Status:** accepted

## Context

The master plan bans `any` outright. A type error that only fails CI is
discovered late; one that fails the build is discovered instantly.

## Decision

`strict` + `noUncheckedIndexedAccess` + `exactOptionalPropertyTypes`;
`@/` as the only import alias; vite-plugin-checker makes type errors fail
`vite build` (so assets:precompile and Docker builds too). ESLint layers
no-explicit-any and a ban-ts-comment rule requiring
`: reason (https://…)` on every ts-expect-error. typescript pinned ~5.9
because typescript-eslint needs the JS compiler API the TS7 Go port
doesn't expose.

## Why

"No any" enforced by machinery, not vigilance. The two extra strict
flags catch the classic undefined-index and optional-vs-undefined bug
families at compile time.

## Revisit when

typescript-eslint ships TS7 support (unpin typescript), or Inertia types
force an alias change.
