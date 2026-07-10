# Parent Plan: Initiatives

- **Status:** NOT_STARTED
- **Phase:** 3
- **Depends on:** cues, billing (premium/enterprise gate), theming-design-system
- **Blocks:** —
- **Last updated:** 2026-07-08

## Objective

Initiatives are parents of cues that function as lightweight workspaces — a
Confluence-flavored file tree of markdown documents and uploaded marketing
materials, org-wide, multi-contributor. Premium/enterprise only.

## Scope (from master_plan.md)

- Initiative = workspace: users create text files (markdown only, images and
  links may be embedded) and upload/organize marketing materials.
- Confluence-like file structure (folders/pages hierarchy).
- Every initiative must have a summary (required field).
- Cues link to an initiative → badge on the cue; clicking navigates to the
  initiative; a left-side "cues" button lists all linked cues.
- Org-wide; multiple board owners contribute.

## Key decisions

### Recommended

1. **Model:** `Initiative` (title, required summary, org-scoped) →
   `InitiativeNode` tree (folder | document | asset) via adjacency list with
   a path cache (materialized path column) — simple, indexable, fine at this
   scale. `CueInitiativeLink` join (a cue links to at most one initiative?
   see open questions).
2. **Markdown documents:** stored as text, rendered server-side with a
   hardened pipeline (Commonmarker + strict sanitization — XSS negative
   tests). Editor: plain textarea + preview toggle at v1; no WYSIWYG
   (master plan says "made simplistic" — take it at its word). Embedded
   images reference uploaded assets in the same initiative.
3. **Assets:** Active Storage on the same R2 bucket as cue uploads, with
   initiative-scoped authorization on every download URL (signed, expiring).
4. **Permissions:** all org members can view; board owners and admins can
   create/edit initiatives and documents; requesters read + comment on
   linked cues only (initiatives are the owners' planning space). Open
   question below.
5. **Versioning of documents:** keep it to "last edited by/at" + soft-delete
   at v1; full version history is a documented deferral.

## Child plans to create

- `plan_2.md` — Models, tree structure, permissions, billing gate, summary
  requirement (negative test: no summary → invalid; basic tier → 404s).
- `plan_3.md` — Document editing: markdown pipeline, sanitization, image
  embedding, asset uploads/organization.
- `plan_4.md` — Navigation UX: initiative page layout (left rail with
  "cues" button), cue badge + two-way navigation, initiative index.

## Implementation order

1. [ ] plan_2 models + gate.
2. [ ] plan_3 documents/assets.
3. [ ] plan_4 navigation + cue linkage UX.

## Test strategy

- XSS negative tests on the markdown pipeline (script tags, event handlers,
  javascript: URLs, SVG payloads).
- Tree integrity: no cycles, orphan handling on folder delete, path cache
  consistency.
- Gate tests: basic-tier org cannot create, view, or deep-link into
  initiatives (404, not upsell-leak of content).
- Authorization on asset URLs (cross-org fetch of a signed URL → fail).

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Models + gating shipped
- [ ] Documents + assets shipped
- [ ] Navigation UX shipped
- [ ] Privacy policy updated (initiative content storage)

## Open questions

1. Can a cue belong to multiple initiatives, or exactly one? Badge UX implies
   one. (Recommendation: one — simpler mental model; revisit on demand.)
2. Can requesters create/edit initiative documents, or read-only?
   (Recommendation: read-only at v1.)
3. Folder depth limit? (Recommendation: 5 — prevents pathological trees and
   keeps mobile navigation sane.)

## Critique

*Reviewed 2026-07-09.*

- Scope and the workspace model match the master plan; the
  simplistic-markdown reading (no WYSIWYG) is the right taste call for
  v1. No critique on the shape.
- One forward-looking note the plans don't state: **initiatives have no
  search of their own** at v1, and if document bodies are encrypted
  (question D5), in-document search stays hard permanently. When D5 is
  answered, apply the same resolution to initiative documents
  explicitly — don't let it be decided by accident for this feature
  (the plan_3 critique carries the detail).
- I1 (one initiative per cue) recommendation stands — worth noting the
  migration path if "multiple" wins later: `initiative_id` column →
  join table is a mechanical migration; starting single costs little.
