# cues — Child Plan 8: Hooks v1 & Completed Section (Search)

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_4 (comments for require-comment)
- **Last updated:** 2026-07-08

## Goal

Board-owner-configurable transition hooks (the master plan example:
"moving to done requires a comment") and the searchable completed section
where resolved cues live.

## Design

### Hooks v1 (built-in toggles, not scripting)

- `BoardConfig.hooks`: typed set of known hooks, each on/off (+ small
  config where noted):
  - `require_comment_on_resolve` (per substatus selectable: done only, or
    all) — the master-plan example.
  - `require_category_before_pull` — backlog cue must have a category
    before it can land on this board.
  - `require_deadline_on_pull` — same pattern for acceptable_deadline.
  - `notify_requester_on_status_change` (default ON — overlaps
    notifications defaults; single source of truth lives here per-board).
- Enforcement inside `transition_to!` guards (plan_2) — a blocked
  transition returns a structured reason the UI renders as an inline
  prompt ("done needs a note — what did you do?" on-voice), not a toast
  failure. Hook checks also emit nothing — only satisfied transitions
  write events.
- Extensible enum design: adding hook #5 later = new guard + config key +
  tests; no framework.

### Completed section

- `/o/:slug/completed` — all resolved cues in the org (per parent
  visibility answer), filterable (substatus, category, board owner,
  requester, date range) + full-text search: generated `tsvector` column
  (title + description + number) with GIN index, `websearch_to_tsquery`
  parsing; comment bodies excluded from the index at v1 (encrypted
  columns + index-size tradeoff — see Q1). Number search short-circuits
  to exact match.
- Reopen action (board owner; cap-checked) surfaces here.
- Board-scoped search (boards plan_4) reuses the same query object
  restricted to one board.

## Implementation steps

- [ ] Hook config schema + guards + structured-reason returns.
- [ ] Hook settings UI (owner board settings) + inline prompt UX on
      blocked transitions.
- [ ] tsvector column + trigger/generated column + query object.
- [ ] Completed page (filters, search, pagination) both viewports.
- [ ] Reopen flow end-to-end.

## Tests

- Negative per hook: resolve-done without comment while hook ON →
  blocked with reason (and succeeds with hook OFF — toggle matrix); pull
  without category/deadline while respective hook ON → blocked; hook
  config from a non-owner → rejected.
- Search: quoted phrases, category+date composite filters, number
  exact-match, cross-org leakage (negative — the important one),
  pagination stability.

## Open questions

1. **Index comment bodies in completed search** — (a) no at v1 **7/10**:
   titles/descriptions catch most recall needs; encrypted comment
   indexing needs a blind-index design — real work, defer until users
   ask "find the cue where someone said X"; (b) yes now **4/10**: cost
   before evidence.
2. **Who sees org-wide completed** — follows organizations-users plan_2
   Q2 (visibility); no separate question here.

## Critique

*Reviewed 2026-07-09.*

- **This plan owns the collision with AR encryption (question D5).** The
  generated tsvector over title+description requires those columns
  plaintext in Postgres. Under D5's recommended resolution (narrow
  encryption: comments/feedback encrypted, title+description plaintext),
  this plan proceeds exactly as written. Under full-encryption
  alternatives, the tsvector shrinks to title/number only or moves to a
  blind-index design — decide D5 before the tsvector migration.
- Hook design (typed toggles, structured block reasons, inline
  fix-prompts): no critique — this is the right size for "hooks" in an
  anti-Jira product.
- One search-quality note: `websearch_to_tsquery` + English stemming
  will underperform on design jargon and partial words ("insta" won't
  match "Instagram"). Add a `pg_trgm` GIN index on title as a companion
  for substring matching — one migration line, and number+title covers
  the dominant recall pattern ("that flyer cue from March").
