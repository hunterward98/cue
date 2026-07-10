# docs/ — house rules

For: anyone (human or agent) writing or reading documentation here.

- Every doc opens with one line saying who it's for.
- Concise beats complete. A doc nobody reads gets deleted, not maintained.
- Decisions live in [decisions/](decisions/) (ADRs; template in
  [decisions/template.md](decisions/template.md)). Every architectural
  choice gets one — that's a PR-checklist item.
- Repeated problems become entries in [gotchas.md](gotchas.md), and every
  entry must link the mechanism that now prevents it (a rule, cop, lint,
  test, or skill). An entry without a mechanism is an open task.
- Layout: `decisions/` (why things are), `design/` (standards + voice,
  owned by theming), `runbooks/` (deploy/backup/incident, owned by
  deployment), `security/` (owned by auth-security), `testing.md`,
  `gotchas.md`.
