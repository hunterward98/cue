# cues — Child Plan 9: Request Templates

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Depends on:** plan_2 (cue model), plan_3 (fields/config), plan_6
  (create UI); organizations-users plan_2 (board owner role)
- **Last updated:** 2026-07-11

## Goal

Board owners turn any cue into a reusable **template**: a guided,
fill-in-the-blank starting point for common request types ("Reset my
password", "New hardware request", "Design review"). Requesters pick a
template instead of composing a cue from scratch, and only answer the
handful of fields the template author left open.

**Why this exists:** organizations-users plan_1's critique proposed a
per-cue `confidential` flag (O8, now cues plan_3 scope) so sensitive
requests (IT password resets, HR-adjacent asks) aren't org-readable by
default. Critique feedback on that plan: the flag alone doesn't help —
"someone requesting a password reset because they forgot it, probably
isn't going to know to use it." A template resolves the *actual*
problem: the board owner who understands the sensitivity sets
`confidential` (and category, and routing) once, on the template: the
requester just fills in what's different about their case and never
has to make a judgment call they're unequipped to make. This is a
bigger win than a narrow security fix — it's friction removal for every
common, repeated request type, not just sensitive ones.

## Design

- **Data model:** `CueTemplate` — board-scoped (a template lives on the
  board it creates cues on, same as the cues it generates), holding a
  name, description/instructions shown to the requester, and the fixed
  defaults it stamps onto every cue it creates (work category, stake,
  priority, `confidential`, custom-field values). Requester-fillable
  fields reuse cues plan_1's `jsonb` custom-field schema shape (field
  name, type, required) rather than inventing a second schema
  mechanism — one pattern for "structured extra fields" everywhere in
  this domain.
- **Authoring flow:** "Make this a template" action on an existing cue
  (board owner only). The board owner picks which of the cue's fields
  stay fixed (defaults) vs become a requester-fillable blank; title and
  description support `{{placeholder}}` tokens for guided fill-in
  ("My password for **{{system}}** needs resetting because
  {{reason}}."). No freeform template-authoring language beyond that —
  a scripting layer is out of scope for v1 (mirrors cues plan_1's
  hooks-as-toggles-not-scripting stance).
- **Requester flow:** the cue-creation screen (plan_6) gets a "Start
  from a template" entry point alongside the blank-cue composer,
  listing the org's active templates (name + description, filterable by
  board). Picking one shows only the blanks the template defines;
  submitting creates a real cue in the template's board backlog, with
  the template's fixed defaults applied server-side (the requester
  never sees or sets `confidential`, category, etc. unless the template
  author explicitly exposed that field as a blank).
- **Tier gating:** available at every tier (basic included). This is an
  accessibility/usability feature, not a premium extra — gating it
  would undercut the exact users (small teams, non-technical
  requesters) it helps most.

## Implementation steps

- [ ] `CueTemplate` model + migration (board-scoped, jsonb field
      schema) + policy (board owner: full CRUD; org members: read
      active templates on boards they can see).
- [ ] "Make this a template" action on cue detail (board owner) +
      template editor (fixed fields vs blanks, placeholder tokens).
- [ ] Requester-facing template picker + fill-in form on the create
      screen (plan_6); submits through the same cue-creation write path
      as a freeform cue, template-stamped.
- [ ] Template management list (board settings) — activate/deactivate,
      edit, delete (with in-flight-cue safety: deleting a template never
      touches cues it already created).
- [ ] System tests: create a template from a cue, request from it as a
      different user, verify fixed fields land untouched and blanks are
      the only requester input.

## Tests

- RTL: template picker rendering, blank-field form validation, "which
  fields are blanks" editor state.
- System (both viewports): full loop — board owner templatizes a cue,
  a requester (different persona) creates a cue from it, resulting cue
  has the template's fixed defaults (including `confidential` when set)
  and only the requester-provided blanks differ from the template.
- Negative: a requester cannot set a fixed/non-blank field via a
  tampered request (server-side stamping, not just UI hiding — same
  discipline as plan_3's field-toggle enforcement); a non-board-owner
  cannot create/edit/delete a template on someone else's board;
  deleting a template does not alter or orphan cues it already created.

## Open questions

1. **Where do templates live in the requester's flow** — (a)
   **(Recommended)** a dedicated "Start from a template" entry point
   next to (not replacing) the blank-cue composer **8/10**: zero cost
   to the 95% of requesters who already know what they want, real help
   for the rest; (b) always show the template picker first, blank cue
   is a secondary link **5/10**: an extra tap for the common case to
   help the uncommon one; (c) surface templates contextually (e.g.
   suggest "Reset my password" when the description contains "forgot
   password") **3/10**: real magic if it worked, high false-positive
   risk and NLP scope creep for v1.
   Answer:
2. **Can a template be board-scoped only, or org-wide** — (a)
   board-scoped only (a template always creates cues on its own board)
   **7/10**: matches "board owner makes a template for their board's
   common asks," no cross-board routing complexity; (b) org-wide
   templates that route to a configurable board **5/10**: useful for
   "IT requests" spanning boards, but adds a routing decision every
   template author has to make even when they don't need it.
   Answer:
3. **Placeholder tokens in title/description — how much templating
   power** — (a) **(Recommended)** simple `{{name}}` substitution, no
   conditionals/loops **8/10**: covers Hunter's example exactly, no
   template-language footgun; (b) no tokens at all, blanks are always
   separate structured fields appended below a fixed description
   **6/10**: simpler to build, loses the natural-sentence feel of "my
   password for {{system}}"; (c) a real templating mini-language
   (conditionals, formatting) **2/10**: scope creep, this is a request
   form, not a document generator.
   Answer:

## Critique

*Self-reviewed 2026-07-11, on authoring — not yet through the
2026-07-09 batch pass the rest of the catalog got, so treat this one as
fresher and less battle-tested than its siblings.*

- The `jsonb` custom-field reuse assumes cues plan_1's custom-field
  schema (Recommended #4 there) survives Hunter's review unchanged. If
  that shape changes, this plan's data model changes with it — flag the
  dependency in plan_2/plan_3's PR if this lands first.
- Template deletion safety ("never touches cues it already created") is
  a copy-not-reference relationship: creating a cue from a template
  should snapshot the template's field values onto the cue, not keep a
  live foreign key the template's later edits or deletion could affect.
  Worth stating as an explicit non-negotiable in plan_2/plan_9's
  migration design, not just a test.
- Not scoped here: analytics on which templates get used (belongs to
  metrics-insights, cheap to add later since `cue_events`/audit already
  captures "created from template X").

## Critique feedback
