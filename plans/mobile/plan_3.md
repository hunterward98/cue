# mobile — Child Plan 3: PWA Packaging

- **Parent:** [plan_1.md](plan_1.md) · **Status:** NOT_STARTED (Phase 4)
- **Depends on:** theming plan_2 (tokens for manifest colors/icons),
  Phase 2 core shipped
- **Last updated:** 2026-07-08

## Goal

Home-screen installability with an app-like shell — the "mobile app"
promise delivered as a PWA (parent's ratified no-native decision),
without pretending to be offline-first.

## Design

- **Manifest:** name/short_name (post name-decision), theme/background
  colors from tokens (light theme values; matching meta tags handle
  dark), display: standalone, start_url = post-login landing (my
  requests for requesters — deep, not the marketing page), icon set
  generated from the wordmark (all sizes + maskable variant).
- **Service worker (deliberately minimal):** precache the static shell
  (fonts, icons, the offline page) only; **no runtime caching of authed
  content** (parent's 9/10 privacy stance — cue data never sits in cache
  storage on a shared device); offline navigation → on-voice offline
  page ("No internet. Your cues are safe; they'll wait."). Versioned
  activation tied to deploys (stale-SW bugs are the PWA tax — an
  update-available toast triggers reload).
- **Install prompt:** subtle menu entry + contextual nudge after the
  Nth mobile session (never a blocking interstitial; theming plan_5
  voice); iOS gets the add-to-home-screen instruction sheet (no
  beforeinstallprompt there).
- **iOS quirks handled here:** apple-touch-icons, status-bar meta,
  safe-area CSS env() insets in the app shell, 16px-minimum inputs
  (zoom-on-focus prevention — actually a plan_4 audit line; the token
  scale guarantees it structurally).
- **Push notifications: explicitly out** (email is primary, parent
  decision); the SW is written so web-push could be added without
  rearchitecting (documented seam only).

## Implementation steps

- [ ] Manifest + icon generation pipeline + meta tags.
- [ ] SW: shell precache + offline page + versioned activation +
      update toast.
- [ ] Install entry + nudge + iOS instruction sheet.
- [ ] Safe-area insets in app chrome.
- [ ] Lighthouse PWA checks added to CI budget for the app shell.

## Tests

- SW: offline navigation serves the offline page (Capybara with network
  interception via CDP); authed responses absent from cache storage
  after browsing (the privacy negative test — enumerate caches, assert
  no org-scoped URLs); new deploy → update toast → reload activates.
- Manifest validates; icons present at all sizes; install entry renders
  on mobile only.

## Open questions

1. **Install nudge threshold** — (a) after 3rd mobile session **7/10**:
   demonstrated habit, not a first-date proposal; (b) after first cue
   submitted **6/10**: value-moment timing, but one-off requesters don't
   need the install; (c) immediately **3/10**: naggy.

## Critique

*Reviewed 2026-07-09.*

- No-runtime-caching-of-authed-content is the correct privacy-first SW
  posture and the enumerate-caches negative test makes it durable — no
  critique on the core.
- One integration note: Inertia already forces full reloads on asset
  version change; the SW update toast must not fight it (two competing
  "reload now" mechanisms = double reload or a stale race). Wire the SW
  activation check into Inertia's version event rather than a parallel
  timer — one reload path, both triggers.
- start_url to the post-login landing: iOS standalone PWAs handle
  session cookies fine today, but test logged-out cold-start from the
  home-screen icon explicitly (plan_4 journey list has PWA repeat-
  journey; make cold-start-logged-out a named case).
