# marketing-site-seo — Child Plan 3: Leak-Proofing & Technical SEO

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED
- **Sequencing:** leak-proofing lands with Phase 1 (parent's queue-jump);
  technical SEO lands with plan_2.
- **Depends on:** auth-security plan_2 (the auth wall it verifies)
- **Last updated:** 2026-07-08

## Goal

Two jobs with one boundary: nothing behind the auth wall ever reaches a
crawler, a preview card, or an analytics payload — and everything public
is maximally indexable.

## Design

### Leak-proofing (Phase 1 rider)

- **Route bifurcation as the invariant:** app routes (org-scoped +
  account) vs public routes (marketing, legal, updates) declared
  explicitly; a routing spec walks the full route set and fails on any
  route not classified — new routes must declare their side (the
  self-strengthening negative test pattern).
- App responses: `X-Robots-Tag: noindex, nofollow` (middleware on the
  app side of the bifurcation); unauthenticated hit → redirect to login,
  zero content bytes (covered per-route by the walking spec).
- **OG/unfurl behavior for app URLs:** Slack/iMessage previews of a
  shared cue link show wordmark + "A cue on Cue — sign in to see it",
  never titles (dedicated OG endpoint serving the generic card for any
  app path, incl. invalid/foreign ids — indistinguishable, no existence
  oracle).
- robots.txt: marketing allowed, app disallowed (belt + suspenders);
  sitemap.xml enumerates public routes only (generated from the
  bifurcation list — can't drift).
- Analytics only on public pages at v1; if app-side product analytics
  ever lands, it's a separate privacy-reviewed decision (noted in
  threat model).

### Technical SEO (with plan_2)

- Canonicals, meta descriptions per page, structured data
  (`SoftwareApplication` + `FAQPage` on pricing, `Article` on updates/
  content), OG/Twitter cards for public pages (real ones — the generic
  card is app-side only), clean-URL discipline, 301 hygiene from day one
  (www/apex + trailing-slash policy picked once).
- **Analytics (Q1):** Plausible **8/10** — cookieless, ~$9/mo, EU-hosted,
  no consent banner burden; self-hosted Umami **6/10** — free but our
  VPS babysits it; GA4 **3/10** — consent/banner/weight cost contradicts
  the privacy posture.

## Implementation steps

- [ ] Route bifurcation + walking spec + noindex middleware (Phase 1).
- [ ] Generic OG endpoint + unfurl verification (Phase 1).
- [ ] robots.txt + sitemap generation from the bifurcation (Phase 1
      skeleton, populated as public pages ship).
- [ ] Structured data + canonicals + cards (with plan_2).
- [ ] Analytics (Q1) on public pages + funnel events for plan_2.
- [ ] Search Console/Bing registration (manual step) + sitemap submit.

## Tests

- The walking spec (unclassified route = failure; every app route:
  noindex header + redirect + zero content); OG endpoint: valid cue id
  vs garbage id → byte-identical generic cards (negative oracle test);
  sitemap contains zero app URLs (generated, then asserted anyway);
  structured data validates (schema.org validator in CI for public
  pages).

## Open questions

1. *(above)* Analytics: Plausible 8/10 / self-hosted Umami 6/10 /
   GA4 3/10.

## Critique

*Reviewed 2026-07-09.*

- Route bifurcation with a walking spec, byte-identical OG negative
  oracle, sitemap generated from the same list: no critique — this is
  the reference implementation of the master plan's "be careful about
  previews" mandate.
- S2 (analytics): Plausible ranking stands; note its EU hosting is a
  *feature* for the privacy story ("we can't see your visitors" class
  claims) — mention it on the privacy policy page, it's free trust.
- One addition: register the domain's `dmarc` reporting address
  (notifications plan_2 dependency) before Search Console verification —
  both DNS sessions collapse into one manual-steps sitting. Logistics,
  not design.
