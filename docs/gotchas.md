# Gotchas

For: anyone hitting a weird problem — check here before debugging from
scratch.

**Protocol (master plan mandate):** the _second_ time any problem
appears, it gets an entry here AND a mechanism that prevents the third
time — a CLAUDE.md rule, a lint/cop, a test, or a skill. Entries link
their mechanism; an entry without one is an open task. When a skill
should have fired and didn't, rewrite its trigger the same day.

Format:

```
## <symptom, one line>
- Cause:
- Mechanism: <link to the rule/cop/test/skill that now prevents it>
- Seen: <dates/contexts>
```

No entries yet. First-encounter oddities worth knowing (not yet
protocol-eligible) live where they bit: endless-method coverage
laundering in docs/testing.md, the driven_by(:cuprite) re-registration
trap in spec/support/capybara.rb, the Postgres 18 volume-path change in
docker-compose.yml, the TS7/typescript-eslint pin in ADR 0006.
