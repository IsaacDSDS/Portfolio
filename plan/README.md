# Project plans

This folder contains all the plans for `so_portfolio`.

## Naming convention

```
YYYY-MM-DD_HHMM_descriptive-title.md
```

- Date and time are in **local time**, 24 h format, with no colon (`HHMM`), because Windows does not allow `:` in file names.
- The date and time are those of the plan's creation.
- Title in lowercase English kebab-case, with no accents.

## Rule

**Every new plan is created directly in this folder, written in English, with this convention.**

## Plans

| File | Status | Description |
|---|---|---|
| [2026-05-08_1844_general-improvement-plan.md](2026-05-08_1844_general-improvement-plan.md) | in progress | General improvement plan by priority (critical to optional), with checkboxes. C1 (tests) is done; the rest is pending except H6, which is partial (`ThemeState`). |
| [2026-10-03_1230_architecture-recommendations.md](2026-10-03_1230_architecture-recommendations.md) | in progress | Keep BLoC, move to a feature-first organization and centralize the data in a single source. Steps 1-3 are done; steps 4-6 are pending. |
| [2026-10-03_1230_windows-state-refactor.md](2026-10-03_1230_windows-state-refactor.md) | done | Refactor of `WindowsBloc`: the state holds only data and the UI resolves tag to content with a static catalog. |
