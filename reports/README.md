# Reports

This folder contains the reports of the integration tests of `so_portfolio`. Every integration test run produces one report here (see "Integration test reports" in `AGENTS.md`).

## Naming convention

```
YYYY-MM-DD_HHMM_descriptive-title.md
```

- Date and time are in **local time**, 24 h format, with no colon (`HHMM`), because Windows does not allow `:` in file names.
- The date and time are those of the test run.
- Title in lowercase English kebab-case, with no accents. It names what was tested.
- Reports are written in English.
- Raw data goes in a sibling folder named like the report, with the extension `.data` instead of `.md`.

## What a report contains

1. Question: what the test is meant to answer.
2. What was tested: the test files, scenarios and actions.
3. Environment: Flutter version, browser or device, mode, OS, hardware.
4. Results: the numbers, with a before and after table when a change was tested.
5. Findings: what the results say, kept apart from what is only a hypothesis.
6. Limits: what the measurement does not show.
7. Next steps.
8. How to reproduce: the exact commands.
9. Appendix with the full metrics.

## Reports

| File | Test | Summary |
|---|---|---|
| [2026-10-03_1336_window-state-rebuild-performance-chrome.md](2026-10-03_1336_window-state-rebuild-performance-chrome.md) | `test/integration/window_performance.dart` (Chrome) | Open, focus and close no longer rebuild every window or drop frames with 30 and 60 windows. Drag is unchanged. |
