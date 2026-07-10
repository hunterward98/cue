# Market Research: Cue's Competitive Landscape

*Researched 2026-07-09. Sources linked inline; pricing verified via search
this week — recheck before the pricing page ships.*

## Executive summary

Cue sits at the intersection of five categories, and **no incumbent
occupies the specific quadrant Cue targets: internal request intake for
small non-technical teams at a consumer-grade flat price.** Competitors
either price per user (punishing the many-requesters model), price for
enterprises ($99–399+/mo), are free-but-technical (self-hosted helpdesks),
or are simple boards with no intake semantics (Trello, Fizzy). The
closest *pricing-model* relative is Jira Service Management (free
requesters, pay per agent) — which is also the product the master plan
defines itself against. The closest *price-point* threat is 37signals'
Fizzy (free, open source) — which lacks the entire request-workflow layer
that is Cue's actual product.

## The five adjacent categories

### 1. General work management (per-user pricing)

| Tool | Price (2026) | Model |
|------|-------------|-------|
| Trello | ~$5/user/mo | Boards; Power-Ups drive real costs up |
| ClickUp | ~$7/user/mo | Everything-app; feature overwhelm |
| Monday.com | ~$9–12/user/mo, 3-seat min | Visual PM, cross-dept |
| Asana | from $13.49/user/mo | PM for 20–200 person orgs |

([pricing comparison](https://softwarefinder.com/resources/trello-vs-asana-vs-monday-vs-clickup),
[hidden-cost analysis](https://productive.io/blog/trello-vs-asana-vs-monday-vs-clickup/))

**How Cue differs:** a 15-person office on Trello Standard is ~$75/mo vs
Cue basic at $3.99/mo — a ~19× gap. Per-user pricing makes every
requester a cost, so these tools structurally discourage exactly the
usage pattern Cue is built for (many requesters, few doers). None of them
distinguish requester from assignee as a first-class role; all of them
model peers collaborating, not intake.

### 2. Simple kanban (the race to free)

- **Trello free tier**: 10 collaborators/workspace.
- **Fizzy (37signals, Dec 2025)**: open-source kanban, hosted version
  **free as of March 2026**, native mobile apps, self-hostable
  ([announcement](https://world.hey.com/dhh/fizzy-is-our-fun-modern-take-on-kanban-and-we-made-it-open-source-54ac41b6),
  [AlternativeTo coverage](https://alternativeto.net/news/2025/12/37signals-launches-fizzy-a-modern-open-source-kanban-software-to-rival-trello-and-asana/),
  [fizzy.do](https://www.fizzy.do/)).

**How Cue differs / the threat:** Fizzy is the most dangerous *framing*
competitor — "why pay $4 when Fizzy is free" — and it shares our stack
(Rails) and our simplicity ethos, backed by a beloved brand. But it is a
board, not a workflow: no requester role, no intake queue, no per-assignee
WIP caps, no field configuration, no insights, no org billing. **The
strategic lesson: never market Cue as "a kanban tool" — that category's
price floor is now $0.** Cue sells the request lifecycle (submit → triage
→ capped board → resolved → insights), of which the board is one screen.

### 3. Helpdesk / service desk (the pricing-model twin)

| Tool | Price (2026) | Notes |
|------|-------------|-------|
| Jira Service Management | Free ≤3 agents; $20/agent/mo Standard | **Unlimited free requesters** ([Atlassian](https://www.atlassian.com/collections/service/pricing)) |
| Freshdesk | Free ≤2 agents; paid ~$15–26+/agent | Support-inbox flavored |
| Spiceworks | Free (ad-supported) | IT-only, dated UX |
| Zammad / osTicket / FreeScout | Free self-hosted | Requires an IT person to run — which is the whole joke for a 10-person office |

([free helpdesk roundup](https://hiverhq.com/blog/best-free-helpdesk-ticketing-software),
[SMB ticketing guide](https://www.desk365.io/blog/free-ticketing-systems/))

**How Cue differs:** JSM validates Cue's economic model exactly —
requesters free, pay for agents — but wraps it in ITIL vocabulary
(incidents, SLAs, change management) and the Jira ecosystem, which is the
overkill the master plan exists to escape. JSM's free tier is a real
competitor for the pure-IT use case (Zammad replacement); Cue's counter
is that the same tool also runs the design/marketing queue, in a UI a
designer would choose, without an admin manual. The self-hosted options
compete on price but not on effort: our buyer doesn't want to run a
server.

### 4. Creative ops / work intake (enterprise-priced)

| Tool | Price (2026) | Notes |
|------|-------------|-------|
| Lytho | Custom (enterprise) | Intake forms → production → DAM ([product](https://www.lytho.com/product/creative-workflow-software/)) |
| Ziflow | ~$249/mo (15 users) | Proofing/compliance focus |
| Wrike | $10–25/user/mo | PM + proofing + request forms |

([creative workflow tools 2026](https://www.usewonderful.com/blog/best-creative-workflow-software))

**How Cue differs:** these prove the *workflow* demand (structured
intake for creative work is a real category) but serve brand teams at
enterprises. Nobody has brought "creative request intake" downmarket to
the one-designer office. That downmarket absence is Cue's opening —
same shape, 1/50th the price, none of the DAM/compliance weight.

### 5. Agency client portals (adjacent, don't chase)

- **ManyRequests**: $99–399/mo ([pricing](https://www.manyrequests.com/pricing))
- **SPP (Service Provider Pro)**: comparable pricing; both bundle
  invoicing, checkout, white-label client portals.

**How Cue differs:** these serve agencies billing *external* clients —
they're commerce platforms with a request queue attached. Cue serves
*internal* teams. Some downmarket agency users will still pick Cue on
price (a freelancer serving two offices fits our multi-org membership
model); welcome them, but don't build invoicing to chase this category —
that's a different product.

## Where Cue wins: the differentiation thesis

1. **Pricing model as positioning: "requesters shouldn't cost money."**
   Flat per-org pricing at $3.99/$13.99 against per-user incumbents is a
   19–50× visible gap for our exact buyer. Basecamp proved flat pricing
   is a durable differentiator at $299/mo
   ([pricing](https://basecamp.com/pricing)); Cue takes the same message
   two orders of magnitude lower. **Product suggestion (new question
   B11):** lean all the way in — make requesters unlimited (or very
   generously capped) and let tiers limit *board owners* only, mirroring
   JSM's agent model. The current 15/200-user caps tax exactly the growth
   we want (more requesters = more org lock-in at near-zero marginal
   cost to us).
2. **The WIP cap as brand, not feature.** No competitor *enforces* focus
   (max 10 on your board — "ten things. that's the point."). Everyone
   else sells unlimited flexibility, which for a solo designer is
   unlimited chaos. This is Cue's opinionated core; market it like
   Basecamp markets calm.
3. **Role asymmetry without ITIL.** The only tools that model
   requester-vs-doer are helpdesks wearing enterprise-IT clothes. Cue is
   the first to give that shape to creative and office work with
   designer-grade aesthetics and voice.
4. **Taste as moat.** The buyer is often literally a designer. Papyrus/
   charcoal themes, the snarky-classy voice, org theming — incumbent
   ticketing tools are beige by design. Taste is hard to fast-follow.
5. **Trust posture as SMB differentiator.** No-content-in-emails,
   break-glass with owner notification, encrypted backups — enterprise
   privacy behavior at $4/mo, worth a dedicated trust page (marketing
   plan already carries this).
6. **Two-month trial** vs the industry's 14–30 days — an acquisition
   wedge that matches a slow-deciding, non-technical buyer.

**Positioning statement (working):** *Cue is the request queue for small
teams that make things — the fastest way for an office to ask its
designer, marketer, or IT person for something, and the calmest way for
that person to get it done. Not a project manager. Not a helpdesk.
Requesters are always free.*

## Implications for existing plans

- **B10 (enterprise differentiation): reinforced.** Capability-based
  differentiation (required-2FA, audit export, break-glass reports,
  priority support) matches how the 100+ seat segment buys; JSM's
  Standard→Premium ladder is the pattern.
- **New question B11** (added to questions.md): requester-based vs
  user-based tier limits.
- **Marketing plan_2 hero copy:** "requesters are always free" belongs in
  the hero or pricing page regardless of B11's outcome; the anti-Jira
  wedge copy is validated by the 2026 "leaner tools for non-technical
  teams" demand ([market context](https://blog.jestor.com/jira-alternatives-non-software-teams/)).
- **Marketing plan_6 SEO ordering:** long-tail audience content first —
  confirmed; also add comparison targets beyond Jira: "Trello alternative
  for design requests," "Jira Service Management too complicated," and a
  deliberate "Cue vs Fizzy" page (own the comparison before someone else
  frames it).
- **Do not build:** invoicing/client billing (ManyRequests' turf), SLA
  engines (JSM's turf), DAM (Lytho's turf). The moat is what we refuse.

## Limitations of this research

Search-based, US-market, single pass (2026-07): pricing changes fast
(Fizzy went free *this March*); Lytho hides pricing; no win/loss or user
interviews behind it. Re-run before the pricing page ships and after the
first ten customer conversations — real buyer objections outrank
category analysis.

## Critique

*Reviewed 2026-07-09 (self-review at write time).*

- The B11 suggestion (unlimited requesters) has a real cost this doc
  underweights: support burden and abuse surface scale with total users
  even when marginal infra cost doesn't. If adopted, pair it with the
  soft storage quotas (cues plan_5) and per-org rate limits already
  planned.
- "Taste as moat" is asserted, not proven — taste attracts but doesn't
  retain by itself; the retention mechanism is the workflow lock-in
  (completed history + insights). Treat taste as the top of the funnel.
- The Fizzy threat could grow: 37signals iterates fast and could add
  intake semantics. Watch it quarterly (add to retro's standing scan).
