# so_portfolio — Project Context

> A web portfolio that replicates the macOS UI, built with Flutter.

## Overview

A personal portfolio that visually replicates the macOS desktop experience in the browser. Users interact with a virtual desktop featuring a top menu bar, a magnifying dock, and draggable/resizable windows with "traffic light" buttons (red, yellow, green). Each "OS" window displays portfolio content (about me, skills, projects, contact, CV, GitHub).

## Architecture

```
lib/
├── main.dart                 # Entry point. BlocProvider(ThemeBloc) -> MaterialApp -> BaseScreen
├── bloc/
│   ├── theme/                # ThemeBloc: toggle dark/light mode
│   └── windows/              # WindowsBloc: open/close/focus windows (z-ordering)
├── core/
│   ├── constants.dart        # topBarHeight=20, bottomBarHeight=80, WindowsTagsIdentifiers
│   ├── date_utils.dart       # macOS-style date/time formatting
│   └── stateful_with_tag.dart # Abstract StatefulWidget with tag
├── models/
│   ├── info.dart             # Info, Skill, Project, Contact (portfolio data)
│   └── ui/tag.dart           # Tag to identify windows (equality by identifier)
├── screens/
│   ├── screens.dart          # BaseScreen: responsive routing by width (>1025 desktop, 787-1024 tablet, <=787 mobile)
│   ├── desktop/              # IMPLEMENTED - Full macOS UI replica
│   │   ├── desktop.dart      # DesktopScreen + DesktopBody (window Stack + icon grid)
│   │   └── widgets/
│   │       ├── app.dart      # Desktop icons (Wrap grid, RTL)
│   │       ├── dock.dart     # Dock with hover magnification (_kSpread=80, 120ms anim)
│   │       ├── top_bar.dart  # Menu bar (apple logo, window title, live clock 30s)
│   │       └── mac_window.dart # Draggable/resizable window (547 lines)
│   │   └── windows/
│   │       ├── window_base.dart # Content router by tag
│   │       └── about_me.dart    # Only implemented window content
│   ├── mobile/               # Placeholder
│   └── tablet/               # Placeholder
├── theme/
│   ├── theme_app.dart        # ThemeColorExtension + ThemeModeColors (light/dark)
│   └── theme_getter.dart     # Extensions: context.theme.appColors
└── widgets/
    ├── separated_column.dart # Column with separatorBuilder
    └── separated_row.dart    # Row with separatorBuilder
```

## Tech Stack

- **Flutter** (Dart SDK ^3.8.0)
- **flutter_bloc** ^9.1.1 — State management (BLoC pattern)
- **cupertino_icons** ^1.0.8 — Apple-style icons
- **flutter_lints** ^5.0.0 — Linting


## Code Patterns & Conventions

### BLoC Pattern
- Each BLoC uses `part 'xxx_event.dart'` and `part 'xxx_state.dart'`
- Events: `WindowOpened`, `WindowClosed`, `WindowFocused`, `ToggleTheme`
- States: immutable with `copyWith()`

### Theme System
- `ThemeColorExtension` extends `ThemeExtension` with custom macOS colors
- Access via `context.theme.appColors` (extension on BuildContext)
- Light: `windowHeaderColor: 0xfffffdfa`, Dark: `windowHeaderColor: 0xff25262d`

### Window Management
- `WindowsBloc` maintains a tag list; order = z-index in Stack
- `Tag.finder` is the default tag when no windows are open
- `Tag` overrides `==` and `hashCode` based solely on `identifier`

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

- **Desktop**: fully implemented (top bar, dock, windows, drag, resize, animations)
- **Mobile/Tablet**: placeholders (text only)
- **Window content**: only `AboutMe` implemented; Skills, Projects, Contact, CV, Github return `Text` widgets
- **Data models**: `Info`, `Skill`, `Project`, `Contact` exist but not populated with real data
- **GLSL Shader**: registered in pubspec.yaml but not integrated into visible UI
- **Tests**: empty `test/` directory
- **README**: needs updating (default Flutter template)

## Useful Commands

```bash
flutter run                    # Run app
flutter run -d chrome          # Run in browser
flutter run -d macos           # Run on native macOS
flutter build web              # Build for web
flutter pub get                # Install dependencies
flutter analyze                # Lint check
```

## Future Development Notes

1. Populate `Info`, `Skill`, `Project`, `Contact` models with real portfolio data
2. Implement window content for: Skills, Projects, Contact, CV, Github
3. Integrate `liquid_glass_lens.frag` shader into dock or windows
4. Implement mobile and tablet views
5. Add tests
6. Consider theme persistence (shared_preferences)
7. Add minimize animation (scale down to dock)
