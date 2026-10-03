# so_portfolio — Project Context

> A web portfolio that replicates the macOS UI, built with Flutter.

## Overview

A personal portfolio that visually replicates the macOS desktop experience in the browser. Users interact with a virtual desktop featuring a top menu bar, a magnifying dock, and draggable/resizable windows with "traffic light" buttons (red, yellow, green). Each "OS" window displays portfolio content (about me, skills, projects, contact, CV, GitHub).

## Architecture

Feature-first: each window/screen lives in `features/`; reusable widgets live in `shared/widgets/`; portfolio content lives in a single data source (`data/portfolio_data.dart`).

```
lib/
├── main.dart                 # Entry point. BlocProvider(ThemeBloc) -> MaterialApp -> MultiBlocProvider(NotificationsBloc) -> BaseScreen
├── bloc/
│   ├── notifications/        # NotificationsBloc: add/remove desktop notifications (deduplicated by tag)
│   ├── theme/                # ThemeBloc: toggle dark/light mode (ThemeToggled)
│   └── windows/              # WindowsBloc: open/close/focus windows (z-ordering). State = data only (List<WindowTag>), no Flutter imports
├── core/
│   ├── constants.dart        # topBarHeight=20, bottomBarHeight=80, WindowsTagsIdentifiers, NotificationIdentifiers, AppImages
│   ├── date_utils.dart       # AppDateUtils (macOS-style clock/date) + DateTimeUtils (MM/dd/yy, same-day, differences)
│   ├── extensions.dart       # Text.withOutline
│   └── stateful_with_tag.dart # Abstract StatefulWidget with tag
├── data/
│   └── portfolio_data.dart   # PortfolioData: single source of portfolio data (info, projects, contacts); currently empty
├── models/
│   ├── info.dart             # Info, Skill, Project, Contact (portfolio data)
│   └── ui/
│       ├── notifications.dart # CustomNotification
│       ├── tag.dart          # Tag, WindowTag (identity only, Equatable by identifier), NotificationTag
│       └── window.dart       # WindowDefinition (tag, title, icon, dockColor, defaultSize, initialPosition, builder)
├── shared/
│   └── widgets/
│       ├── mac_window.dart   # DraggableMacWindow: draggable/resizable window (traffic lights, animations)
│       ├── separated_column.dart # Column with separatorBuilder
│       └── separated_row.dart    # Row with separatorBuilder
├── theme/
│   ├── theme_app.dart        # ThemeColorExtension + ThemeModeColors (light/dark)
│   └── theme_getter.dart     # Extensions: context.theme.appColors
└── features/
    ├── screens.dart          # BaseScreen: responsive routing by width (>1025 desktop, 787-1024 tablet, <=787 mobile)
    ├── desktop/              # IMPLEMENTED - Full macOS UI shell
    │   ├── desktop.dart      # DesktopScreen, DesktopBody (window Stack + icon grid), NotificationContainer
    │   ├── app.dart          # Desktop icons (Wrap grid, RTL)
    │   ├── dock.dart         # Dock with hover magnification (_kSpread=80, 120ms anim)
    │   ├── notifications.dart # DesktopNotification card (auto-dismiss after 7s)
    │   ├── top_bar.dart      # Menu bar (apple logo, window title from the catalog, live clock 30s)
    │   ├── window_base.dart  # WindowBase(tag): resolves the catalog and wraps the content in a DraggableMacWindow
    │   ├── window_catalog.dart # windowCatalog (single source of window chrome + content), dockOrder, desktopOrder, windowTitle()
    │   ├── window_extensions.dart # context.openWindow(tag)
    │   └── window_layer.dart # WindowLayer: stacks the open windows, reusing each WindowBase instance so other windows do not rebuild
    ├── about_me/
    │   └── about_me.dart     # AboutMe window content (placeholder)
    ├── mobile/               # Placeholder
    └── tablet/               # Placeholder

test/                         # Mirrors lib/ (bloc/, core/, features/desktop/, models/, shared/widgets/) + performance/ (rebuild counts)
test/integration/             # window_performance.dart (frame timings with 6/30/60 windows, profile mode) + driver.dart. Run with `flutter drive`; the names do not end in `_test.dart` so `flutter test` skips them
plan/                         # Plans: YYYY-MM-DD_HHMM_descriptive-title.md, in English (see plan/README.md)
reports/                      # Integration test reports, same naming (see reports/README.md)
```

## Tech Stack

- **Flutter** (Dart SDK ^3.8.0), run through FVM (`.fvmrc`)
- **flutter_bloc** ^9.1.1 — State management (BLoC pattern)
- **intl** ^0.19.0 — Date formatting (`DateTimeUtils`)
- **cupertino_icons** ^1.0.8 — Apple-style icons
- **flutter_lints** ^5.0.0 — Linting
- **equatable** ^3.0.0 — Value equality for `WindowTag`, `WindowsState` and window events
- **bloc_test** ^10.0.0 — BLoC testing (dev)

## Golden Rules

- No portfolio data hardcoded in widgets: everything comes from `data/portfolio_data.dart`.
- One BLoC per window only if the window has its own state.
- Reusable widgets go in `shared/widgets/`; anything specific to a window goes inside its feature.
- New dependencies: justify them in the commit.
- Every integration test run produces a report in `reports/` (see below).

## Integration test reports

All tests live under `test/` (unit and widget tests mirror `lib/`; integration tests go in `test/integration/`). Do not create test folders elsewhere. Integration tests are run with `flutter drive`, and their file names must not end in `_test.dart`, because `flutter test` would try to run them without a browser.

Every time an integration test (`test/integration/`) is run to measure or verify something, write a report of what was tested before closing the task. This includes re-runs after a change: each run gets its own report, with a before and after comparison when a change was tested.

- Create it in `reports/`, named `YYYY-MM-DD_HHMM_descriptive-title.md` (local time, 24 h, no colons), written in English. The convention and the list of reports are in `reports/README.md`.
- Follow the sections listed in `reports/README.md`: question, what was tested, environment, results, findings, limits, next steps, how to reproduce and an appendix with the full metrics.
- Keep the raw output in a sibling `.data` folder, because `build/` is ignored by git and is erased by `flutter clean`.
- Report only what was measured. Keep hypotheses apart from findings, state how many runs back each number and what the measurement does not cover. If a run failed or was stopped, say so in the report.
- Add the new report to the table in `reports/README.md`.

## Code Patterns & Conventions

### BLoC Pattern
- Each BLoC uses `part 'xxx_event.dart'` and `part 'xxx_state.dart'`
- Events: `WindowOpened`, `WindowClosed`, `WindowFocused`, `ThemeToggled`, `NotificationsAdd`, `NotificationsRemove`
- States: immutable with `copyWith()`
- `WindowsState` and the window events extend `Equatable` (equal states are not re-emitted)

### Theme System
- `ThemeColorExtension` extends `ThemeExtension` with custom macOS colors
- Access via `context.theme.appColors` (extension on BuildContext)
- Light: `windowHeaderColor: 0xfffffdfa`, Dark: `windowHeaderColor: 0xff25262d`

### Window Management
- `WindowsState.windows` is a `List<WindowTag>` (data only); order = z-index in Stack
- `WindowsState.currentTag` is derived: the last window, or `WindowTag.finder` when none is open
- `WindowTag` is identity only (`Equatable` on `identifier`); titles, icons, dock colors, default size and content live in `windowCatalog` (`features/desktop/window_catalog.dart`), a `Map<String, WindowDefinition>` keyed by `WindowsTagsIdentifiers`
- `dockOrder` / `desktopOrder` list the identifiers each surface shows; `windowTitle(tag)` returns the title (`'Finder'` for `finder` and unknown tags)
- `DesktopBody`, `Dock`, `TopBar` and `WindowBase` read the catalog; open windows with `context.openWindow(tag)`
- `WindowLayer` renders the open windows and keeps one `WindowBase` instance per open window: opening, focusing or closing a window does not rebuild the others. Do not make `DesktopBody` or `DesktopScreen` watch `WindowsBloc` again (a test in `test/performance/` guards this)
- To add a window: add its identifier to `WindowsTagsIdentifiers`, an entry to the catalog and the identifier to the order lists

### Layout
- `SeparatedColumn` / `SeparatedRow` — reusable widgets with `separatorBuilder`
- `StatefulWithTag` — abstract base class for stateful widgets with a tag
- `WindowsTagsIdentifiers` — string constants for window IDs

### Key Constants
```dart
topBarHeight = 20
bottomBarHeight = 80
WindowsTagsIdentifiers: aboutMe, skills, projects, contact, github, cv
```

## Current State / Work in Progress

- **Desktop**: fully implemented (top bar, dock, windows, drag, resize, animations, notifications)
- **Mobile/Tablet**: placeholders (text only)
- **Window content**: only `AboutMe` exists (placeholder); Skills, Projects, Contact, CV, Github are `Text` placeholders built by the catalog builders in `window_catalog.dart`
- **Data models**: `Info`, `Skill`, `Project`, `Contact` exist; `PortfolioData` in `data/portfolio_data.dart` is empty and not populated with real data yet
- **GLSL Shader**: registered in pubspec.yaml but not integrated into visible UI
- **Tests**: 11 test files under `test/` (blocs, date utils, tag model, window catalog, dock, top bar, desktop body, mac window, window rebuild counts), plus the integration test in `test/integration/` (run with `flutter drive`)
- **README**: needs updating (`lib/` tree is stale)

## Useful Commands

```bash
fvm flutter run                    # Run app
fvm flutter run -d chrome          # Run in browser
fvm flutter run -d macos           # Run on native macOS
fvm flutter build web              # Build for web
fvm flutter pub get                # Install dependencies
fvm flutter analyze                # Lint check
fvm flutter test                   # Run tests
fvm flutter test test/performance/window_rebuilds_test.dart   # Count window rebuilds per action

# Frame timings in Chrome (needs chromedriver matching Chrome, running on port 4444). Write a report in reports/ afterwards.
fvm flutter drive --driver=test/integration/driver.dart --target=test/integration/window_performance.dart --profile -d web-server --browser-name=chrome --no-headless --browser-dimension=1440,900
```

## Future Development Notes

1. Populate `PortfolioData` (`Info`, `Skill`, `Project`, `Contact`) with real portfolio data
2. Implement window content for: Skills, Projects, Contact, CV, Github
3. Integrate `liquid_glass_lens.frag` shader into dock or windows
4. Implement mobile and tablet views
5. Expand tests
6. Consider theme persistence (shared_preferences)
7. Add minimize animation (scale down to dock)
