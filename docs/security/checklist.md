# Phase-boundary security checklist (auth plan_5)

For: whoever runs the retro at each phase boundary. Work the list, date
it, file findings as issues.

- [ ] Authz matrix drift: new routes/roles since last pass all have
      policy tests (incl. cross-org negatives)?
- [ ] Token/expiry inventory still matches docs (AuthToken::TTLS)?
- [ ] Dependency risk: anything pinned-and-forgotten (typescript ~5.9,
      react-doctor exact, webrick CVE ignore)? Re-check each.
- [ ] gitleaks full-history scan (quarterly).
- [ ] Backup restore rehearsal date fresh (database plan_4 runbook)?
- [ ] Break-glass audit: support access grants all have linked reasons?
- [ ] Threat model: new surfaces since last pass documented above?

| Pass                               | Date | Notes |
| ---------------------------------- | ---- | ----- |
| (first pass due at end of Phase 1) |      |       |
