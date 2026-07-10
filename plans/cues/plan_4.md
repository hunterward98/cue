# cues — Child Plan 4: Comments & @-Mentions

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; notifications plan_3 (delivery)
- **Last updated:** 2026-07-08

## Goal

Conversation on a cue: comments from org members, @-mentions that notify,
and the participant model that later drives notification fan-out.

## Design

- **Comment:** cue, author, body (encrypted at rest like descriptions;
  markdown-lite: bold/italic/links/lists via the shared Markdown component
  pipeline — no headings/images in comments, keep them conversational),
  soft-delete (`deleted_at`, body redacted in UI as "comment removed",
  events preserved), edited_at with a 15-minute edit window — see Q1.
- **Mentions:** `@`-trigger typeahead over active org members (component
  from theming plan_3's primitives); stored as structured references
  (`comment_mentions` join: comment ↔ user) parsed server-side from a
  stable token format (`@[user:uuid]` in the raw body, rendered as a
  styled mention chip) — display names change, mentions shouldn't break.
  Mentioning triggers notification (notifications plan_4 delivers);
  self-mention doesn't notify.
- **Participants:** derived set per cue — requester, board owner (when on
  a board), commenters, mentioned users. Materialized as
  `cue_participants` join maintained on write (cheap, queryable for
  fan-out) rather than computed per notification.
- **Permissions:** active org members read + comment (per parent
  visibility answer); authors edit within window / soft-delete own;
  board owner of the cue may soft-delete any comment on it (moderation);
  required-comment hooks (plan_8) count only non-deleted comments.
- Comments emit CueEvents (commented, comment_deleted) — activity tab and
  hooks read events, not the comments table.

## Implementation steps

- [ ] Comment model + soft-delete + edit window + policy additions.
- [ ] Mention token format + parser + comment_mentions + participants
      maintenance.
- [ ] Typeahead composer (mobile-first: mention picker usable on touch).
- [ ] Markdown-lite pipeline config (subset of shared sanitizer).
- [ ] Notification handoff events (consumed by notifications plan_4).
- [ ] Comment thread UI on cue detail (plan_6 composition).

## Tests

- Negative: non-member comments → denied; edit after window → denied;
  edit others' comments → denied (owner delete ≠ edit); mention of
  non-member or cross-org user → parser drops it, no notification; XSS
  payloads in body → sanitized (shared pipeline suite); deleted comment
  body absent from responses (not just hidden — content never serialized).
- Participants: each write path (comment, mention, pull) updates the set
  exactly once; dedup asserted.

## Open questions

1. **Edit window** — (a) 15 minutes, then immutable **7/10**: typo-fixing
   without history-rewriting (comments can carry decisions/hook
   requirements); (b) unlimited edits with edited-at marker **5/10**:
   friendlier but lets a required done-comment be gutted after the fact;
   (c) no edits **4/10**: punishing on mobile keyboards.
2. **Reactions (👍 etc.)** — (a) defer **8/10**: nice-to-have, zero
   MVP value; (b) ship tiny ack-reaction now **4/10**: scope creep with
   notification questions attached.

## Critique

*Reviewed 2026-07-09.*

- **The `@[user:uuid]` token format vs the plain-textarea composer is an
  unresolved tension.** In a plain textarea, users see raw
  `@[user:9f3c…]` tokens after picking from the typeahead — ugly and
  editable into corruption. Honest options:
  1. **(Recommended)** Composer inserts `@DisplayName`, and the *server*
     resolves mentions at save time against the typeahead-confirmed
     list sent alongside the body (ids travel in a separate field, body
     stays human-readable). Ambiguity (two Dana's) is resolved by the
     explicit id list; body text is just text.
  2. A lightweight contenteditable composer rendering chips — the
     "right" UX, meaningfully more code and a11y surface than a
     textarea; would need to be a library component with real tests.
  Option 1 keeps the plain-textarea simplicity the plan wants; take it
  unless the composer grows rich-text ambitions anyway.
- 15-min edit window + required-comment hooks: ensure the hook counts a
  comment only if it still has non-empty body after edits — presence
  validation on update covers it; add the negative test (edit-to-empty
  a hook-satisfying comment → rejected).
- Participants as a maintained join table: right call (fan-out reads it
  constantly). No further critique.
