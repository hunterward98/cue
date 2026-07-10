# Manual Steps — Foundation

Human actions required. Check off and note the date when done.

- [x] Create the GitHub repository (or grant the agent a repo to push to) and
      confirm visibility (private recommended until launch). — done
      2026-07-10, github.com/hunterward98/cue; main pushed, CI live.
- [ ] Enable branch protection on `main` (Settings → Branches → require
      status checks: lint, gitleaks, react-doctor, test-frontend,
      test-backend, test-system, coverage, bin-setup) — needs the GitHub
      UI or a token; the agent can't reach the API without `gh` auth.
- [ ] Choose and provision the hosting VPS (Hetzner or DigitalOcean account,
      billing set up). ~$6–12/mo class machine is sufficient for MVP.
- [ ] Purchase the production domain (also needed by marketing-site-seo and
      notifications-email plans — one purchase covers all three).
- [ ] Provide container registry credentials if not using GHCR with the repo.
- [x] Ratify the two BLOCKING open questions in plan_1.md (Inertia; Kamal/VPS)
      — done 2026-07-08.

- [ ] (new, rides the domain purchase) Real contact address for
      public/.well-known/security.txt + ApplicationMailer from-address —
      both carry placeholders today.

Status 2026-07-10: foundation plans 2–4 are DONE and verified locally; the
three unchecked items above are now the only blockers for plan_5 (deploy)
and for CI actually running (needs the GitHub repo). Everything is
committed locally on `main`, ready to push the moment the repo exists.
