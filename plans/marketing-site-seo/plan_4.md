# marketing-site-seo — Child Plan 4: Legal Pages & Update Process

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Sequencing:** v1 published before first external signup (queue-jump).
- **Depends on:** manual step (lawyer review before billing goes live)
- **Last updated:** 2026-07-08

## Goal

Privacy policy and Terms of Service that are honest, current, and
mechanically kept current — the master plan's "continuously updated with
each feature" turned into process, not intention.

## Design

- **Format:** markdown in `content/legal/` (privacy.md, terms.md),
  version front-matter (semver-ish + effective date), rendered on public
  routes with a change log section; prior versions retained in-repo
  (git + an explicit `content/legal/archive/`) — "what did I agree to
  in March" is answerable.
- **Drafting:** start from reputable SaaS templates, rewritten in plain
  language (legal pages are a trust surface for non-lawyers; plain
  English main text). Cue-specific realities covered: email-only
  notifications, encrypted-at-rest content, no content in emails,
  support break-glass with org-owner notification (support-admin Q1 —
  if ratified, it's a privacy-policy selling point), subprocessor list
  (host, R2, email provider, Stripe, analytics — auto-checked against
  the actual gem/service inventory each release, see process), data
  retention (org soft-delete grace, backup windows), no sale of data,
  GDPR/CCPA basics — with the lawyer pass (manual step) before money
  moves.
- **The update process (the actual feature of this plan):** PR-template
  line "user-data surface changed? → legal diff required or explicit
  n/a"; releases (self-improvement plan_3's ritual) run a legal
  checklist step — new subprocessor? new data category? → diff legal +
  bump version + changelog entry; **material changes** → notice: banner
  to org owners + email, 14 days before effective date (see Q1).
- **Acceptance tracking:** ToS version accepted at signup (stored on
  user), org owner accepts on org creation (binds the org); material
  updates re-prompt via banner acknowledgment — not a hard wall except
  where legally required (Q1).
- **Cookie posture:** session-only first-party cookies + cookieless
  analytics = a short honest cookies section, no consent banner
  (documented reasoning; revisit if any tracking tech ever lands).

## Implementation steps

- [ ] Content structure + rendering + version/changelog machinery +
      archive.
- [ ] Drafts of both documents (plain-language, Cue-specific realities).
- [ ] Acceptance tracking (signup + org creation + re-acknowledgment).
- [ ] PR template + release checklist wiring.
- [ ] Subprocessor inventory check task.
- [ ] Lawyer review round (manual) → v1.0 published.

## Tests

- Acceptance: signup records exact version; version bump → owner banner
  appears (and only for material=true bumps); unaccepted material
  version past effective date behaves per Q1 outcome.
- Rendering: archive routes serve prior versions; changelog complete
  (every version in archive appears).
- Negative: legal pages are public (never behind auth), and the
  subprocessor task fails when a known-service credential exists without
  a policy mention (the drift catcher).

## Open questions

1. **Material-change mechanism** — (a) banner + email, 14-day notice,
   acknowledgment tracked, hard wall only for org owners on billing-term
   changes **8/10**: proportionate, standard; (b) hard re-accept wall
   for everyone **4/10**: hostile for requesters who just want their
   flyer; (c) email only **4/10**: acknowledgment untrackable.

## Critique

*Reviewed 2026-07-09.*

- Versioned in-repo legal with acceptance tracking and a
  subprocessor-drift check: no critique on the machinery — the drift
  check (credentials exist for a service the policy doesn't mention →
  fail) is the mechanism most legal pages lack.
- **Jurisdiction needs one early decision the plan defers implicitly:**
  hosting region (F9) + audience (US real-estate offices) + EU-hosted
  analytics (S2) = a US-centric product with some EU data flows. Tell
  the lawyer exactly this shape and ask for a CCPA-first policy with
  GDPR-lite coverage, rather than a generic template trying to be
  everything — cheaper review, tighter policy. One line in the lawyer
  brief (manual step), decided by F9's answer.
- Material-change banner + 14-day notice (S5a): stands. No further
  critique.
