# Open Questions — Consolidated Answer Sheet

Every open question across all plans, ranked out of 10 per option, grouped
by when the answer is needed. **Bold** = recommended (highest-ranked).
Full context lives in the referenced plan file.

**How to answer:** reply "accept all recommendations" and/or override
individual items ("A1: b", "C6: a but…"). Answers get recorded into the
owning plan and struck from this sheet.

⚠ = interpretation of the master plan that needs your confirmation, not
just a preference.

## Answer before Phase 0 (foundation work)

| ID | Question | Options (score) | Plan |
|----|----------|-----------------|------|
| F1 | Version manager | **mise (8)** · asdf (6) · README-only (3) | [foundation/plan_2](foundation/plan_2.md) |
| F2 | Node package manager | **pnpm (8)** · npm (7) · yarn (4) | foundation/plan_2 |
| F3 | System test driver | **Capybara+Cuprite (8)** · Playwright (6) · Selenium (4) | [foundation/plan_3](foundation/plan_3.md) |
| F4 | parallel_tests now? | **defer until suite >2min (8)** · now (5) | foundation/plan_3 |
| F5 | Pre-commit hooks | **lefthook (8)** · husky (6) · overcommit (5) · none (4) | [foundation/plan_4](foundation/plan_4.md) |
| F6 | Conventional commits | **no, plain messages (7)** · yes (5) | foundation/plan_4 |
| F7 | Staging env | **same VPS, 2nd Kamal destination (8)** · separate VPS (6) · none (4) | [foundation/plan_5](foundation/plan_5.md) |
| F8 | Error tracking | **Sentry free tier (8)** · GlitchTip self-hosted (6) · logs only (3) | foundation/plan_5 |
| F9 | VPS provider | **Hetzner US region (8)** · DigitalOcean (7) | foundation/plan_5 + manual step |
| F10 | Repo name + private? | free text (manual step) | foundation manual steps |
| D1 | Tenancy enforcement | **scoping idiom + custom cop (8)** · acts_as_tenant (6) · Postgres RLS (5) | [database-architecture/plan_2](database-architecture/plan_2.md) |
| SI1 | ADR numbering | **global counter (8)** · date-prefixed (5) | [self-improvement/plan_2](self-improvement/plan_2.md) |

## Answer before Phase 1 (auth, orgs, design system)

| ID | Question | Options (score) | Plan |
|----|----------|-----------------|------|
| A1 | Primary login method | **both, passwordless default (8)** · password-first (6) · passwordless-only (5) · password-only (3) | [auth-security/plan_2](auth-security/plan_2.md) |
| A2 | Post-signup landing | **create-or-join chooser (8)** · straight to org creation (5) | auth-security/plan_2 |
| A3 | Session lifetime | **30d requesters / 14d owners+org owners (7)** · 30d all (6) · 7d all (4) | [auth-security/plan_1](auth-security/plan_1.md) |
| A4 | CAPTCHA on signup | **none; throttles + verification (8)** · pre-wired flag (7) · always-on (4) | [auth-security/plan_3](auth-security/plan_3.md) |
| A6 | Dependency bot | **Renovate (8)** · Dependabot (7) · manual (4) | [auth-security/plan_5](auth-security/plan_5.md) |
| A7 | Bug bounty at launch | **no; disclosure policy only (8)** · small bounty (3) | auth-security/plan_5 |
| O1 | Org deletion | **soft-delete, 30-day purge grace (9)** · hard delete (3) · soft forever (4) | [organizations-users/plan_2](organizations-users/plan_2.md) |
| O2 ⚠ | Requester visibility | **members see all org boards/cues (7)** · own requests only (5) · per-board config (4) | organizations-users/plan_2 |
| O3 | Board owners count toward user limit | **yes (9)** · no (3) | organizations-users/plan_1 |
| O4 | Pending invites reserve seats | **yes (8)** · check at accept (5) | [organizations-users/plan_3](organizations-users/plan_3.md) |
| O5 | Join-approval default role | **always requester (9)** · pick at approval (6) | organizations-users/plan_3 |
| O6 | Org data export | **defer, design the button (7)** · MVP CSV (6) · never (1) | [organizations-users/plan_4](organizations-users/plan_4.md) |
| O7 | Org slug | **immutable v1 (8)** · mutable + redirects (5) | organizations-users/plan_4 |
| T1 | Font pairing (decide from rendered samples) | EB Garamond+Inter (7) · Cormorant+Source Sans 3 (7) · Playfair (6) · custom (3) | [theming/plan_2](theming-design-system/plan_2.md) |
| T2 | Logo | **placeholder wordmark now, real later (8)** · commission now (3) | theming/plan_1 |
| T4 | Headless primitives | **selective Radix/react-aria for Modal/Select/Tabs (8)** · all hand-rolled (5) · full framework (2) | [theming/plan_3](theming-design-system/plan_3.md) |
| T6 | Frontend strings | **typed strings.ts modules (8)** · react-i18next (5) · inline (2) | [theming/plan_5](theming-design-system/plan_5.md) |
| T7 | Tutorial mechanism | **own Popover coach marks (8)** · driver.js (5) | theming/plan_5 |
| MO1 | Mobile test width | **375px (8)** · 390px (6) · 320px (4) | [mobile/plan_2](mobile/plan_2.md) |
| SU2 | Support role granularity | **single full tier (8)** · read-only/full split (4) | support-admin/plan_1 |
| SU3 | Staff 2FA idle re-prompt | **12h (7)** · 4h (6) · per-login (4) | [support-admin/plan_2](support-admin/plan_2.md) |
| S3 | English-only at MVP | **yes (8)** · i18n runtime now (3) | marketing/plan_1 |

## Answer before Phase 2 (cues, boards, notifications)

| ID | Question | Options (score) | Plan |
|----|----------|-----------------|------|
| C1 | Policy layer | **Pundit (8)** · ActionPolicy (7) · hand-rolled (5) | [cues/plan_2](cues/plan_2.md) |
| C2 ⚠ | Requester status rights | **edit + cancel while cue'd only (8)** · transition anytime (4) · read-only after submit (5) | cues/plan_2 |
| C3 | Deadlines | **dates (8)** · datetimes (3) | cues/plan_1 |
| C4 | Default work categories | seed by org flavor at signup (design/marketing/IT lists in plan) — approve concept | [cues/plan_3](cues/plan_3.md) |
| C5 ⚠ | Category list scope | **one shared org list (7)** · per-owner lists (4) · hybrid (5) | cues/plan_3 |
| C6 ⚠ | Stake vs priorities | **one field: stake with configurable levels (8)** · two separate fields (4) | cues/plan_3 |
| C7 | Comment edit window | **15 min then immutable (7)** · unlimited + marker (5) · none (4) | [cues/plan_4](cues/plan_4.md) |
| C8 | Reactions | **defer (8)** · now (4) | cues/plan_4 |
| C9 | Upload type allowlist | **images+PDF+office docs (8)** · images+PDF (6) · all-but-executables (3) | [cues/plan_5](cues/plan_5.md) |
| C10 | Storage quotas | **generous soft quota per tier (7)** · hard (5) · none (4) | cues/plan_5 |
| C11 | Description editor | **markdown-lite + paste-to-attach (8)** · plain textarea (6) · full markdown (4) | [cues/plan_6](cues/plan_6.md) |
| C14 | Search comment bodies | **no at v1 (7)** · yes (4) | [cues/plan_8](cues/plan_8.md) |
| W1 | Archived board history | **keep forever for metrics (8)** · purge (3) | [boards/plan_2](boards-workflow/plan_2.md) |
| W2 | Returning in-review cues | **allow w/ confirm + notify requester (8)** · forbid (5) | boards/plan_2 |
| W3 | New-cue backlog position | **bottom (7)** · untriaged strip (6) · top (4) | [boards/plan_3](boards-workflow/plan_3.md) |
| W4 | Drag-and-drop library | **dnd-kit (8)** · pragmatic-drag-and-drop (7) · native (3) | [boards/plan_4](boards-workflow/plan_4.md) |
| W5 | Mobile board layout | **segmented control (8)** · column swipe (6) — prototype both | boards/plan_4 |
| W6 | Org-owner all-boards overview | **yes, read-only (8)** · no (4) | boards/plan_1 |
| W7 | Board cap policy | **per-owner setting + org default (8)** · org-enforced ceiling (5) | boards/plan_1 |
| N1 | Email provider (manual step) | **Postmark (8)** · SES (6) · Resend (6) | [notifications/plan_2](notifications-email/plan_2.md) |
| N2 | Sending domain | **mail.<domain> subdomain (8)** · root (5) | notifications/plan_2 |
| N3 | cue_resolved audience | **requester + participants (7)** · requester only (6) | [notifications/plan_3](notifications-email/plan_3.md) |
| N4 | New-cue fan-out default | **org setting, default all owners (8)** · always-all (5) · none (3) | notifications/plan_1 |
| N5 | Reply-by-email comments | **defer + security review (8)** · build now (3) | notifications/plan_1 |
| SU4 | Staff-on-staff ops | **console tasks only (8)** · web with dual-confirm (4) | [support-admin/plan_3](support-admin/plan_3.md) |

## Answer before Phase 3 (billing, initiatives, metrics)

| ID | Question | Options (score) | Plan |
|----|----------|-----------------|------|
| B1 | Trial tier default | **premium trial for everyone (8)** · trial as-chosen (6) · basic (3) | [billing/plan_2](billing/plan_2.md) |
| B2 | Trial → annual conversion | **either period at card entry (8)** · monthly only (2) | billing/plan_2 |
| B3 | Stripe integration style | Pay gem (7) · direct stripe gem (7) — 1-day spike decides | [billing/plan_3](billing/plan_3.md) |
| B4 | Enterprise seat sync | **immediate push + daily true-up (8)** · daily only (5) · monthly (3) | billing/plan_3 |
| B5 | Cancellation | **end-of-period, reads forever (8)** · immediate + refund (4) | billing/plan_3 |
| B6 | Enterprise pricing public + self-serve | **yes, with seat calculator (8)** · contact-us (3) | [billing/plan_4](billing/plan_4.md) |
| B7 | Premium/enterprise upload limit | **25MB (8)** · 10MB (6) · 100MB (4) | billing/plan_1 |
| B8 | Expired trial behavior | **read-only (8)** · full lock (3) | billing/plan_1 |
| B9 | Stripe Tax | **enable (8)** · ignore initially (4) — manual step, needs your entity info | billing manual steps |
| I1 ⚠ | Cue ↔ initiative | **exactly one (8)** · multiple (5) | initiatives/plan_1 |
| I2 ⚠ | Requesters in initiatives | **read-only (7)** · can contribute docs (5) | initiatives/plan_1 |
| I3 | Tree depth limit | **5 (8)** · 3 (5) · unlimited (3) | initiatives/plan_1 |
| I4 | Folder delete | **require-empty w/ explicit cascade option (8)** · always cascade (5) · forbid non-empty (4) | [initiatives/plan_2](initiatives/plan_2.md) |
| I5 | Initiatives on downgrade | **frozen read-only (8)** · hidden/404 (3) | initiatives/plan_2 |
| I6 | External images in markdown | **blocked; assets only (8)** · proxied (5) · hotlinked (2) | [initiatives/plan_3](initiatives/plan_3.md) |
| I7 | Revision insurance table | **yes, no UI yet (8)** · true deferral (5) | initiatives/plan_3 |
| M1 | Insights on basic tier | **all tiers (8)** · premium+ (4) | metrics/plan_1 |
| M2 | Duration semantics | **wall-clock, labeled (8)** · business-hours (5, deferred) | metrics/plan_1 |
| M3 | Requester leaderboard | **names visible to owners+org owners (7)** · anonymize option (5) | [metrics/plan_2](metrics-insights/plan_2.md) |
| M4 | Chart library | Recharts (7) · visx (6) · hand-rolled SVG (6) · Chart.js (5) — decide at build w/ dataviz skill | [metrics/plan_3](metrics-insights/plan_3.md) |
| D3 | Audit/completed retention | **keep forever v1 (7)** · configurable (5) · fixed TTL (3) | database-architecture/plan_1 |
| SU1 ⚠ | Break-glass notifies org owners | **yes, every grant (8)** · monthly digest (5) · no (2) — becomes a privacy-policy claim | [support-admin/plan_5](support-admin/plan_5.md) |
| SU5 | Notify owner on trial extension | **yes (8)** · silent (4) | [support-admin/plan_4](support-admin/plan_4.md) |
| A5 | Org-required-2FA grace | **7 days (8)** · immediate (5) · 30 days (4) | [auth-security/plan_4](auth-security/plan_4.md) |

## Answer before Phase 4 / launch

| ID | Question | Options (score) | Plan |
|----|----------|-----------------|------|
| S1 | Product name + domain | free text (manual step — "cue" domains contested: getcue/cueboard/usecue…) | marketing manual steps |
| S2 | Analytics | **Plausible (8)** · self-hosted Umami (6) · GA4 (3) | [marketing/plan_3](marketing-site-seo/plan_3.md) |
| S4 | Hero art | **real screenshots, auto-generated (8)** · illustrations (5) | [marketing/plan_2](marketing-site-seo/plan_2.md) |
| S5 | Legal material-change notice | **banner + email, 14-day (8)** · hard re-accept (4) · email only (4) | [marketing/plan_4](marketing-site-seo/plan_4.md) |
| S6 | Feedback visibility | **private to submitter + us (8)** · org owners see members' (3) | [marketing/plan_5](marketing-site-seo/plan_5.md) |
| S7 | Content byline | **"the Cue team" (7)** · named humans (6) | [marketing/plan_6](marketing-site-seo/plan_6.md) |
| MO2 | PWA install nudge | **after 3rd mobile session (7)** · after first cue (6) · immediate (3) | [mobile/plan_3](mobile/plan_3.md) |
| MO3 | Device testing | **own devices (8)** · BrowserStack (5) | mobile/plan_1 |
| SI2 | Retro depth | **full 8-section (7)** · lightweight (6, fallback) | [self-improvement/plan_4](self-improvement/plan_4.md) |
| SI3 | Manual-step notification | **session-end summary (8)** · email ping (5) | self-improvement/plan_1 |
| D2 | Backup encryption | **age (8)** · gpg (6) · bucket-privacy only (3) | [database-architecture/plan_4](database-architecture/plan_4.md) |

## Critique round (2026-07-09) — changes and new questions

A full critique pass (research-backed, `## Critique` section at the bottom
of every plan file) produced the following. Read the owning plan's
critique before answering these.

### Rankings changed by research

| ID | Change |
|----|--------|
| T4 | **REVISED:** selective **Base UI (8)** · react-aria (7) · Radix (5) — Base UI 1.0 (MUI, Dec 2025) is now the maintained default; Radix slowed post-WorkOS. See [theming/plan_3 critique](theming-design-system/plan_3.md). |
| F3, W4, N1 | **Confirmed by research** (Cuprite alive; dnd-kit alive and community default; Postmark $15/mo verified). Rankings stand. |

### New questions from the critique

| ID | Question | Options (score) | Plan critique |
|----|----------|-----------------|---------------|
| D4 | Primary key generation | **PG18 native `uuidv7()` DB default (9)** · app-side SecureRandom.uuid_v7 (5) | [foundation/plan_2](foundation/plan_2.md) |
| D5 ⚠ | Cue-content encryption vs search — **a real cross-plan conflict**: AR-encrypted descriptions can't feed the planned full-text search | **narrow encryption: comments/feedback encrypted, title+description plaintext + encrypted backups (8)** · encrypt all, search title/number via plaintext column (6) · encrypt all + blind index (3) | [database/plan_1](database-architecture/plan_1.md), [cues/plan_8](cues/plan_8.md) |
| O8 | Per-cue `confidential` flag at MVP (resolves the IT-password-reset vs org-transparency tension) | **yes (8)** · post-MVP (5) · no (2) | [organizations-users/plan_1](organizations-users/plan_1.md) |
| B10 ⚠ | Enterprise tier is price-dominated by premium for 100–200 users (enterprise floor $19.99 > premium $13.99, same features) | **differentiate on capabilities: required-2FA, SSO-later, audit export, break-glass reports, priority support (8)** · reprice the seam (6) · leave as-is (4) | [billing/plan_1](billing/plan_1.md) |
| F11 | react-doctor gate mechanics | **pinned version + score 100, deliberate upgrades (8)** · unpinned + ratchet (5) | [foundation/plan_1](foundation/plan_1.md) |
| F12 | Coverage-gate escape valve | **100% + justified `:nocov:` + retro-audited count, plus weekly mutation testing on policies/entitlements (8)** · hard 100% no exceptions (5) · 95% floor (4) | [foundation/plan_3](foundation/plan_3.md) |
| B11 ⚠ | Tier limits: users vs board owners — market research suggests requesters should be free/unlimited (JSM's agent model, our strongest wedge); master plan caps total users | **unlimited (or very generous) requesters; tiers cap board owners (8)** · keep user caps as specced (5) · hybrid: raise requester caps 5× (6) | [market-research.md](market-research.md), [billing/plan_1](billing/plan_1.md) |
| C6 | *(scope widened by critique)* stake-levels config should be **org-level**, not per-board, for metrics comparability — see [cues/plan_3 critique](cues/plan_3.md); answer together with original C6 | | |

### Design improvements adopted into critiques (no question needed — veto if you disagree)

- No raw Tailwind palette shipped at all → color violations become
  unrepresentable ([theming/plan_2](theming-design-system/plan_2.md)).
- Org accent via static `data-accent` CSS, not inline style injection
  ([theming/plan_4](theming-design-system/plan_4.md)).
- Composite tenant FKs on the hot spine ([database/plan_3](database-architecture/plan_3.md)).
- EXIF stripped at ingest, not just variants ([cues/plan_5](cues/plan_5.md)).
- Custom-field select options as `{id,label}`, not label strings ([cues/plan_7](cues/plan_7.md)).
- Mentions: plain `@Name` body + server-side id resolution ([cues/plan_4](cues/plan_4.md)).
- `pg_trgm` companion index on titles ([cues/plan_8](cues/plan_8.md)).
- WAL archiving (pgBackRest/wal-g) before billing launch — RPO 24h→minutes ([database/plan_4](database-architecture/plan_4.md)).
- Rails 8.1 + Postgres 18 as scaffold targets ([foundation/plan_1](foundation/plan_1.md)).
- Trademark knockout search added to marketing manual steps.
- Break-glass grants must link a support/feedback item ([support-admin/plan_5](support-admin/plan_5.md)).
- Retro template gains a standing "cross-plan conflict scan" section ([self-improvement/plan_4](self-improvement/plan_4.md)).

## Bookkeeping

When a question is answered: record it in the owning plan (RATIFIED +
date, as done for the first four), strike the row here, and add a line to
README's ratified-decisions log if it's architectural.
