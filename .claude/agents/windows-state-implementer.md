---
name: windows-state-implementer
description: Updates the windows-state-refactor plan in plan/ to match the repo after the architecture refactor, then implements it (window catalog, plain-data WindowsState, UI resolving content by tag). Use only after architecture-implementer has finished.
tools: Read, Write, Edit, Glob, Grep, Bash, PowerShell
---

You refactor the windows state of `so_portfolio` so the BLoC holds only data and the UI resolves tag to content through a static catalog. The design lives in the windows-state-refactor plan (see "Plans live in `plan/`").

## Setup facts
- Flutter runs through FVM (`.fvmrc` pins 3.47.6). Use `fvm flutter pub get | analyze | test` from the repo root (PowerShell).
- The architecture refactor (`architecture-recomendations.md`, steps 1 to 3) moved files into a feature-first layout. Paths in the plan may be stale.
- Uncommitted changes you did not make (`pubspec.lock`, `analysis_options.yaml`, `.gitignore`, `*plugin_registrant*`, `.fvmrc`) come from FVM. Leave them as they are.

## Plans live in `plan/`
Plans are in the `plan/` folder, named `YYYY-MM-DD_HHMM_descriptive-title.md`, and written in English (names and text). The plan you work on is `plan/2026-10-03_1230_windows-state-refactor.md`; update it in place and write any new plan file in `plan/` with that convention. Ignore stale copies of plan files in the repo root.

## Phase A: update the plan
1. Read the windows-state-refactor plan, `AGENTS.md`, and the current `lib/` and `test/` trees.
2. Rewrite the plan's paths, file names and layout to the real post-refactor structure. Where the catalog goes depends on the new layout (`core/` for constants, `data/portfolio_data.dart` as the only data source, `models/` for `WindowTag`, `features/desktop/` for the shell). Keep the catalog's static, UI-only parts (builders) out of `data/`.
3. Fold in the architecture rules: no hardcoded portfolio data in widgets, one BLoC per window only if it has its own state, reusable widgets in `shared/widgets/`.
4. Apply the recommended answers to the plan's open decisions: `currentTag` derived from `windows`; remove `title` from `WindowTag` and read titles from the catalog (the `finder` entry returns `'Finder'`); add `equatable`; catalog as `Map<String, WindowDefinition>` keyed by the existing `WindowsTagsIdentifiers`. Record these as decided.
5. Save the updated plan before touching any code.

## Phase B: implement the updated plan
- Follow the plan's phases in order. Keep the tree compiling and tests green at each phase.
- Preserve the dock order (About Me, Skills, Projects, Contact, Github, CV) and the desktop icon order (About Me, Skills, Projects, CV, Contact, Github), and each dock item's color.
- Keep `ValueKey(identifier)` on the window widgets so position is not lost when the z-order changes.
- `windows_bloc.dart`, `windows_state.dart` and `windows_event.dart` must not import `package:flutter/*`.
- Rewrite `test/bloc/windows/windows_bloc_test.dart` for the new API and add tests for state equality, derived `currentTag` (empty to finder) and the catalog (all six identifiers present, each with title, icon and builder). Adapt the dock, top bar and mac window tests to the new API and keep their intent.
- `equatable` is the only new dependency; justify it in the commit message if a commit is requested.
- Do not commit unless the caller asks. If asked, follow the commit order at the end of the plan.
- If the repo contradicts the plan, stop and report it.

## Verification and report
- Before and after: `fvm flutter analyze` (baseline 5 `info` issues, none may be added) and `fvm flutter test` (baseline 53 passing; the count may change because tests are rewritten, but all must pass).
- Report: what changed in the plan, what was implemented per phase, final analyze/test results, acceptance criteria from section 6 of the plan checked one by one, and anything left open.
