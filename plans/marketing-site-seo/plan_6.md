# marketing-site-seo — Child Plan 6: Content Library & Product Updates

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED (post-MVP)
- **Depends on:** plan_2 (marketing frame), plan_3 (SEO plumbing);
  self-improvement plan_3 (release ritual generates update posts)
- **Last updated:** 2026-07-08

## Goal

The organic-traffic engine and the changelog-as-blog: markdown content in
the repo rendered as SEO articles, plus product update posts generated
with each significant release (master plan's post-MVP blog).

## Design

- **Content system (one engine, two sections):** `content/articles/` +
  `content/updates/` — markdown with front-matter (title, description,
  slug, date, audience tag, draft flag), rendered through the shared
  sanitized pipeline (initiatives plan_3's module — same hardening,
  static trusted source but no second pipeline to maintain), served on
  marketing routes with the plan_3 SEO treatment (Article structured
  data, cards, sitemap inclusion), RSS feed for updates. Runtime render
  + edge/action caching (parent lean: runtime 7/10 vs static build
  6/10 — no second build system, cache makes it free).
- **Updates section:** one post per significant release, written by the
  release ritual (self-improvement plan_3): features in user language,
  screenshots via the plan_2 gallery step, on-voice. Doubles as the
  living proof-of-life small buyers check before trusting a small
  vendor.
- **Article strategy (the SEO wedge, from the parent):**
  - Comparison/alternative: "simple Jira alternative", "Trello vs Cue
    for design requests", "Jira for small teams: when it's too much".
  - Audience how-tos: "managing design requests in a real-estate
    office", "stop taking marketing requests over email", "tiny IT
    helpdesk without the helpdesk software".
  - Product-adjacent: "what's a cue? (it's a ticket. we know.)".
  - Cadence: 2/month post-MVP; topics tracked as a checklist in this
    file when active; internal linking articles ↔ landing audience
    strips ↔ pricing.
- **Quality gates:** content PRs get the voice review line; Lighthouse
  budgets apply; description + title length lints (cheap SEO hygiene
  automated, no plugin sprawl).

## Implementation steps

- [ ] Content engine (front-matter loader, routes, caching, drafts).
- [ ] Updates section + RSS + release-ritual hook.
- [ ] Article templates + internal-linking conventions + SEO lints.
- [ ] First three articles (one per category above) as the launch set.
- [ ] Topic backlog checklist seeded (10 titles).

## Tests

- Front-matter validation (missing description/title → build task
  fails); draft flag excludes from routes + sitemap + RSS (negative);
  RSS validates; slug collisions rejected; pipeline reuse means the XSS
  corpus already covers rendering (spot-check spec included anyway).

## Open questions

1. **Author byline** — (a) "the Cue team" collectively **7/10**: honest
   for a tiny shop, no fake-persona cringe; (b) named humans **6/10**:
   warmer if you want your name on it — your call, zero code impact.

## Critique

*Reviewed 2026-07-09.*

- Content engine reusing the hardened markdown pipeline, front-matter
  lints, RSS, release-ritual generation: no critique on machinery.
- Sequencing critique from plan_1 applies here concretely: the launch
  trio should be three *audience how-tos*, not one-per-category — the
  comparison piece ("Jira alternative") waits for domain authority
  (~6 months of indexed content) before it can pull rank. Update the
  first-articles step when this plan starts.
- 2/month cadence is honest for a solo shop; a stale updates blog reads
  worse than none, so the release ritual generating update posts (not
  willpower) is the load-bearing part — no change, just naming it.
