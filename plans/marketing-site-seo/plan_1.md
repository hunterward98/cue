# Parent Plan: Marketing Site, SEO & Legal

- **Status:** NOT_STARTED
- **Phase:** 4 (legal pages needed at first real signup — see ordering note)
- **Depends on:** theming-design-system
- **Blocks:** public launch
- **Manual steps:** [manual_steps_plan_1.md](manual_steps_plan_1.md)
- **Last updated:** 2026-07-08

## Objective

Drive organic traffic and convert visitors, while guaranteeing zero leakage
of customer content into public pages or search indexes. Plus the operational
basics: legal pages, feedback/bug/contact channels, about, and a product
updates blog.

## Scope (from master_plan.md)

- Naturally drive traffic via search; generate content people stumble into.
- Strict preview hygiene: org content requires login + approved membership —
  cue previews/link unfurls/search results must never expose it.
- Privacy policy + ToS, continuously updated with each feature (every feature
  plan carries a checklist item; this plan owns the pages and process).
- Feedback collection, bug reports, contact, about.
- Focus on advertising the product well and converting visitors.
- Post-MVP: product updates section, blog-like, from markdown files in the
  codebase generated with each big release.

## Key decisions

### Recommended

1. **Marketing pages are server-rendered Rails views** (not the Inertia app):
   fast, crawlable, cacheable at the edge, zero JS budget. Same design
   tokens, so brand cohesion holds.
2. **Leak-proofing is negative-tested infrastructure:** app routes send
   `X-Robots-Tag: noindex`; OpenGraph unfurls for app URLs show only the
   logo + "a cue on Cue" (never titles); robots.txt + sitemap cover
   marketing pages only; a CI test asserts no app route renders without
   authentication.
3. **SEO content strategy:** comparison/alternative pages ("simple Jira
   alternative for design teams"), audience pages (real-estate marketing
   coordinators, in-house designers, small IT), and a short how-to library.
   Content in markdown, rendered through the same pipeline as product
   updates. Cadence and topics tracked in a child plan.
4. **Legal:** privacy policy + ToS drafted from templates, versioned in-repo
   (markdown, dated versions, changelog), reviewed by a human lawyer before
   charging money (manual step). The "update legal with each feature" rule
   becomes a PR-checklist item enforced via the self-improvement plan.
5. **Feedback/bugs/contact:** simple authenticated in-app form (category:
   feedback/bug/question) writing to an internal table + email to us — we
   are our own ticket system's first requester. Public contact = mailto +
   form. No third-party widget spend.
6. **Product updates:** markdown files in `content/updates/`, rendered as a
   blog with RSS; a release ritual (self-improvement plan) generates one per
   significant release.

## Child plans to create

- `plan_2.md` — Landing page + pricing page + about (conversion-focused,
  on-voice, mobile-first, Lighthouse ≥ 95).
- `plan_3.md` — Leak-proofing + technical SEO (noindex on app, OG behavior,
  sitemap, structured data, analytics choice — privacy-respecting, e.g.
  Plausible vs self-hosted).
- `plan_4.md` — Legal pages + versioning process + cookie/consent posture.
- `plan_5.md` — Feedback/bug/contact forms + internal triage view.
- `plan_6.md` — Content library + product updates blog + RSS (post-MVP).

## Implementation order

**Note:** plan_4 (legal) and plan_3 (leak-proofing) jump the phase queue —
they must exist the moment any external user can sign up. Only content/SEO
work is truly Phase 4.

1. [ ] plan_3 leak-proofing (land with auth-security in Phase 1).
2. [ ] plan_4 legal v1 (land before first external signup).
3. [ ] plan_2 landing/pricing/about (launch-blocking).
4. [ ] plan_5 feedback/contact (launch-blocking).
5. [ ] plan_6 content + updates blog (post-MVP).

## Test strategy

- Negative tests: unauthenticated fetch of any app route → redirect, never
  content; app routes carry noindex; OG endpoint for a cue URL returns the
  generic card; sitemap contains zero app URLs.
- Lighthouse CI budget on marketing pages (perf ≥ 95, SEO ≥ 95, a11y ≥ 95).

## Progress

- [x] Child plans authored (2026-07-08)
- [ ] Leak-proofing shipped (Phase 1 rider)
- [ ] Legal v1 published
- [ ] Landing/pricing/about live
- [ ] Feedback/contact live
- [ ] Updates blog live

## Open questions

1. Product name/domain availability — "cue" is heavily contested; getcue.*,
   cueboard.*, usecue.*? Needs your call (manual step).
2. Analytics: Plausible (~$9/mo, zero-cookie) vs self-hosted Umami (free,
   ops burden)? Recommendation: Plausible.
3. Launch markets/languages: English-only at MVP? (Recommendation: yes;
   i18n scaffolding is cheap to add early though — flag for foundation.)

## Critique

*Reviewed 2026-07-09.*

- **Add a trademark knockout search to the manual steps before any
  brand investment.** "Cue" is a crowded mark (Cue Health and others);
  a $300 knockout search before the logo/domain/content spend is cheap
  insurance against a rename at launch. (Added to
  manual_steps_plan_1.md.)
- **SEO strategy sequencing critique:** comparison pages ("Jira
  alternative") target brutally competitive keywords a zero-authority
  domain won't rank for in year one. Invert the plan_6 cadence:
  long-tail audience how-tos first ("managing design requests in a
  real-estate office" has almost no competition and is *exactly* our
  buyer), comparison pages later once domain authority exists. Same
  content, better order.
- Leak-proofing as Phase-1 infrastructure with self-strengthening
  tests: no critique — it's the strongest privacy work in the whole
  plan set.
