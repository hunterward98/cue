# initiatives — Child Plan 3: Documents, Markdown Pipeline & Assets

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2; cues plan_5 (upload machinery reused)
- **Last updated:** 2026-07-08

## Goal

The content inside the tree: markdown-only documents (with embedded
images and links) and organized marketing-material assets — on one
hardened rendering pipeline shared with comments and cue descriptions.

## Design

- **The shared pipeline (this plan owns it, others consume subsets):**
  Commonmarker (CommonMark + tables/strikethrough/autolink extensions)
  → sanitize with a strict allowlist → rendered HTML. Profiles:
  `document` (full: headings, images, tables), `description` (cues
  plan_6: no headings), `comment` (cues plan_4: minimal). One module,
  one XSS suite covering all profiles (script/iframe/event-handler/
  javascript:-URL/data:-URL/SVG payload corpus). External links get
  rel="noopener noreferrer" + target rules; external images NOT fetched/
  hotlinked — see Q1.
- **Document:** node-attached body (text, encrypted at rest per the
  sensitive-content posture), last_edited_by/at; editing = textarea +
  server-rendered preview toggle (parity guaranteed: preview endpoint
  runs the exact pipeline — parent's "made simplistic" taken at its
  word, no WYSIWYG); soft autosave drafts (localStorage, not server —
  cheap, private, good enough); version history deferred (parent
  decision) — `document_revisions` append-only table stores prior body
  on each save *now* (cheap insurance, no UI until demanded — see Q2).
- **Embedded images:** `![...](asset:uuid)` references to asset nodes in
  the same initiative, resolved to signed URLs at render; upload-inline
  = create asset node in an "Uploads" folder + insert reference (paste
  and drag-drop in the editor).
- **Assets:** node kind=asset wrapping an Active Storage attachment
  (cues plan_5's validation/serving machinery reused — same allowlist +
  25MB premium limit, same EXIF stripping, same signed URLs); grid/list
  browsing views by folder; move/rename = tree ops from plan_2;
  bulk upload into a folder.

## Implementation steps

- [ ] Pipeline module + profiles + XSS corpus suite (lands first —
      cues plans consume it; coordinate sequencing: this module may ship
      early with Phase 2 even though initiatives is Phase 3).
- [ ] Document model + revisions insurance + editor + preview endpoint +
      autosave.
- [ ] Asset nodes on upload machinery + browsing views + bulk upload.
- [ ] Embedded image references + paste/drop insertion.
- [ ] Mobile pass: reading excellent, editing workable (documents are
      desktop-primary; reading is everyone's).

## Tests

- XSS corpus × profiles (the security centerpiece — every payload inert
  in every profile); asset reference to another initiative/org →
  render-time denial (negative); signed URL reuse cross-org → denied
  (plan_5 suite extended).
- Preview parity: fuzz bodies → preview HTML === saved render HTML.
- Revisions: every save appends exactly one (append-only shared
  example).

## Open questions

1. **External images in markdown** — (a) blocked; embedded images must
   be uploaded assets **8/10**: no tracking pixels/mixed content/CSP
   holes in a privacy-first product, and marketing materials belong in
   the workspace anyway; (b) proxied/camo-style **5/10**: infrastructure
   for a marginal want; (c) hotlinked **2/10**: CSP violation by design.
2. **Revision insurance table now** — (a) yes, storage is cheap, "I
   deleted everything" support tickets aren't **8/10**; (b) no, true
   deferral **5/10**: honest YAGNI but one bad day away from regret.

## Critique

*Reviewed 2026-07-09.*

- **The shared pipeline shipping early (Phase 2, ahead of this plan) is
  load-bearing for three features — pull it out of this plan.** As
  written, cues plan_4/6 consume a module this Phase-3 plan owns; the
  sequencing note admits it may ship early. Cleaner: move the pipeline
  module + XSS corpus into its own small child plan (or attach to cues
  plan_4) so Phase 2 doesn't depend on a Phase 3 plan's internals.
  Ownership clarity beats file count.
- **Document encryption (D5 again):** encrypted bodies mean initiative
  documents can never be full-text searched without redesign. If D5
  lands narrow-encryption for cues, decide documents the same way
  *deliberately*: marketing-materials workspaces are usually the least
  secret content in the product (they're ads) — plaintext + encrypted
  backups is arguably right here even if comments stay encrypted.
  Flag carried in D5's options.
- Revision-insurance table (I7a): keep — cheapest regret-prevention in
  the feature. localStorage autosave: add a "draft restored" toast so
  users know it happened; silent restoration reads as haunted.
- No further critique — the external-image block (I6a) is the correct
  privacy call and the preview-parity fuzz is a genuinely good test.
