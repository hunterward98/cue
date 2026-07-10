# cues — Child Plan 6: Cue UI (Create, Detail, My Requests)

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2, plan_3; theming plan_3 (components)
- **Sequenced early** (right after plan_2) — it makes every later child
  demoable end-to-end.
- **Last updated:** 2026-07-08

## Goal

The three screens that carry the product's minimal-click promise: a
create form a requester finishes on a phone in under a minute, a cue
detail page that is the whole story of a request, and a "my requests"
list. Budgets: ≤3 taps logged-in → submitted cue; ≤2 taps → status of my
request (asserted by mobile plan_2's click-budget tests).

## Design

- **Create (`/o/:slug/cues/new`, and THE primary CTA everywhere):**
  title + description + only the fields the effective config (plan_3)
  enables, optional fields collapsed behind "add details" on mobile —
  the 80% path is title + description + category + submit. Uploads
  attachable pre-submit (plan_5 direct upload). On-voice success state
  pointing to "my requests". First-run coach mark = tutorial #1
  (theming plan_5).
- **Detail (`/o/:slug/cues/PREFIX-N` — human-readable URLs):** header
  (number, title, status Badge, stake/deadline chips), description,
  attachments, comment thread (plan_4), activity tab (CueEvents rendered
  readably), action area strictly filtered by the plan_2 policy (what you
  can't do isn't disabled — it's absent; less clutter, the anti-Jira
  stance). Board owner extras: transition buttons with hook enforcement
  (plan_8), edit, link/initiative affordances arriving with plan_7.
  Requester extras (while `cued`, pending Q1 outcome): edit, cancel.
- **My Requests (`/o/:slug/mine`):** requester home — their cues by
  status, newest activity first; empty state teaches (tutorial #1 target).
  This page is a requester's whole product; it must be excellent on a
  phone.
- All three render from the same typed cue serializer (one shape, no
  per-page drift); Inertia partial reloads for comment/transition updates
  (no SPA-style client cache to invalidate — simplicity win, documented).

## Implementation steps

- [ ] Typed serializer + shared page props contract.
- [ ] Create form (form object from plan_3 is the single write path) +
      upload integration + success flow.
- [ ] Detail page composition + activity tab + policy-filtered actions.
- [ ] My Requests list + empty state.
- [ ] Click-budget + viewport system tests for all three.
- [ ] Coach-mark hookpoints for tutorials.

## Tests

- System (both viewports): submit-a-cue full path within tap budget;
  detail renders every field configuration (toggled-off fields absent);
  action area matrix — each persona sees exactly their policy's actions
  (negative: board-owner buttons never render for requesters, AND the
  endpoints reject them — UI and policy tested separately).
- RTL: form validation states, collapsed-details behavior, activity tab
  rendering of each event type.

## Open questions

1. **Description editor** — (a) same markdown-lite as comments, with
   image paste→attachment **8/10**: one pipeline, designers paste
   screenshots constantly; (b) plain textarea **6/10**: simplest, loses
   paste-to-attach; (c) full markdown with headings **4/10**: requests
   aren't documents — that's what initiatives are for.

## Critique

*Reviewed 2026-07-09.*

- No critique on structure, budgets, or the policy-filtered action area
  (absent-not-disabled is the right anti-Jira stance and the separate
  UI/endpoint testing keeps it honest).
- One addition from the O8 critique thread: the create form gets the
  `confidential` toggle (plan_3) — keep it visually quiet (a lock icon
  toggle, not a big checkbox) so the 95% non-sensitive path pays no
  attention cost.
- C11 (paste-to-attach markdown-lite): stands; ensure pasted-image
  uploads respect the same tier size validation *before* the paste
  visually succeeds — a paste that uploads then errors feels broken.
