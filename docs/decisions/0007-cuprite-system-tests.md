# 0007 — Capybara + Cuprite for system tests

- **Date:** 2026-07-09 (question F3)
- **Status:** accepted

## Context

System tests need a browser driver. Candidates: Cuprite (CDP, all-Ruby),
Playwright via ruby bindings, Selenium.

## Decision

Cuprite against Chrome for Testing (auto-discovered under
~/.cache/puppeteer locally, system Chrome in CI; CHROME_PATH overrides).
Registered as :cue_cuprite because driven_by(:cuprite) silently
re-registers Rails' own driver over a same-named custom one.
js_errors: true — a console error is a failing test.

## Why

One language, one test runner, transactional fixtures that just work,
no node subprocess. Verified current and maintained (2026).

## Revisit when

CDP flake shows up twice (gotcha protocol threshold) — then evaluate
capybara-playwright-driver.
