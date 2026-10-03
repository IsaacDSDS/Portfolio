# Plan — Improve the windows state (`WindowsBloc`)

> Goal: the state holds **only data** (which windows are open and in what order), and the UI resolves tag → content through a **static catalog**.

Status: **implemented** (analyze: same 5 pre-existing infos; tests: 80 passing, baseline was 56). Updated to the post-architecture layout (feature-first, see `2026-10-03_1230_architecture-recommendations.md`, steps 1-3, already done). All paths below are the real ones.

Related to `2026-05-08_1844_general-improvement-plan.md`: **H2** (single source of data), **H5/H6** (equality in events/state), **M1** (registry instead of switch), **M10** (window_base part), **M11**.

---

## 1. Diagnosis

| # | Problem | Where |
|---|----------|-------|
| 1 | The state contains a `Widget` (`WindowConfig.child`) → the bloc depends on the Flutter UI | `lib/models/ui/window.dart:6`, `lib/bloc/windows/windows_state.dart:4` |
| 2 | `WindowsState` has no value equality; with a `Widget` inside it could not have it | `lib/bloc/windows/windows_state.dart` |
| 3 | Events have no equality | `lib/bloc/windows/windows_event.dart` |
| 4 | Tag → content is duplicated: `openWindow(...)` copied in the dock and the desktop; the app list is repeated twice | `lib/features/desktop/dock.dart:24-187`, `lib/features/desktop/desktop.dart:82-182` |
| 5 | `WindowTag` mixes identity (`identifier`) with presentation (`title`); equality ignores `title` | `lib/models/ui/tag.dart` |
| 6 | `width/height/initialPosition` are per-window-type defaults, not state | `lib/models/ui/window.dart` |
| 7 | `async` handlers without `await` | `lib/bloc/windows/windows_bloc.dart` (M11) |
| 8 | `currentTag` is redundant: it is always the last one in the list (or `finder` if the list is empty) | `lib/bloc/windows/windows_bloc.dart` |

---

## 2. Decisions (all decided)

1. **`currentTag` is derived** from `windows` (getter), not stored. It removes a field that can become inconsistent with `windows`. `top_bar.dart` keeps reading `state.currentTag`; tests stop passing `currentTag` in the seed.
2. **`title` is removed from `WindowTag`**; titles are read from the catalog. `windowTitle(WindowTag.finder)` returns `'Finder'`, and so does any unknown identifier (today's top-bar fallback).
3. **`equatable`** is added as a dependency (the only new one; resolved to `^3.0.0`). Used only on `WindowTag`, `WindowsState` and the events. In equatable 3.x `EquatableMixin` no longer exists: `Equatable` is an `abstract mixin class`, so `WindowTag` is `class WindowTag extends Tag with Equatable`. The abstract `Tag` and `NotificationTag` stay untouched because `NotificationsBloc` deduplicates with `==`.
4. **Catalog is a `Map<String, WindowDefinition>`** keyed by the existing `WindowsTagsIdentifiers` constants (no enum migration). `finder` is not an entry of the map.
5. **Catalog location: `lib/features/desktop/window_catalog.dart`**, NOT `core/`: it imports `features/about_me`, and `core/` must not depend on `features/`. No Flutter UI in `data/`.
6. **Titles, icons and dock colors are UI chrome, not portfolio content**, so they do not violate the rule "portfolio data only in `data/portfolio_data.dart`". Window *content* will read from `PortfolioData` (architecture steps 4-6, out of scope here).
7. **Old phases 2 and 3 are merged** into one block: separated, the tree does not compile (the bloc API change breaks `desktop.dart`, `dock.dart`, `window_base.dart` and their tests at once).
8. **No `showInDock` / `showOnDesktop` flags.** Both surfaces list all six windows today. Two const identifier lists instead (`dockOrder`, `desktopOrder`), because the order differs:
   - Dock: aboutMe, skills, projects, contact, github, cv.
   - Desktop: aboutMe, skills, projects, cv, contact, github.
9. **Equal states are no longer emitted** (Bloc skips `emit` when the new state `==` the old one). The test "Close an inexistent window" goes from one emission to `<WindowsState>[]`; document it in the test.
10. `windows_bloc.dart`, `windows_state.dart`, `windows_event.dart` import only `bloc` (not `flutter_bloc`) and `models/ui/tag.dart`, never `package:flutter*`.
11. `DraggableMacWindow`'s public API does not change. `WindowBase` keeps `ValueKey(tag.identifier)` (set by `DesktopBody`).

### Architecture rules (from the architecture plan, apply to this work)

- No portfolio data hardcoded in widgets: it comes from `data/portfolio_data.dart`. (Window chrome — title, icon, color — lives in the catalog and is not portfolio content.)
- One BLoC per window only if the window has its own state. Window content widgets live in their own feature folder (`features/<window>/`); the catalog only references them.
- Reusable widgets go in `shared/widgets/`; anything specific to a window goes inside its feature.
- New dependencies are justified in the commit (here: `equatable`, for value equality of tag, state and events).

---

## 3. Target design

```
lib/
├── core/
│   └── constants.dart             # unchanged (WindowsTagsIdentifiers, AppImages)
├── models/ui/
│   ├── window.dart                # WindowDefinition (tag, title, icon, dockColor, size, builder)
│   └── tag.dart                   # WindowTag: identity only (EquatableMixin)
├── bloc/windows/
│   ├── windows_event.dart         # Equatable, events with WindowTag
│   ├── windows_state.dart         # Equatable, only List<WindowTag> (+ derived currentTag)
│   └── windows_bloc.dart          # synchronous handlers, no flutter imports
└── features/desktop/
    ├── window_catalog.dart        # NEW: windowCatalog, dockOrder, desktopOrder, windowTitle()
    ├── window_extensions.dart     # NEW: context.openWindow(tag)
    ├── window_base.dart           # WindowBase(tag, onClose, onTap) resolves the catalog
    ├── desktop.dart               # DesktopBody reads the catalog
    ├── dock.dart                  # Dock reads the catalog
    └── top_bar.dart               # TopBar title via windowTitle()
```

**`WindowDefinition`** (immutable, does not live in the state):

```dart
class WindowDefinition {
  final WindowTag tag;
  final String title;
  final String icon;
  final Color dockColor;
  final Size defaultSize;           // 600x400 for all today
  final Offset? initialPosition;    // null for all today
  final WidgetBuilder builder;
}
```

**`WindowsState`** (data only):

```dart
class WindowsState extends Equatable {
  final List<WindowTag> windows;            // the order = z-index
  WindowTag get currentTag => windows.isEmpty ? WindowTag.finder : windows.last;
  WindowsState copyWith({List<WindowTag>? windows});
  @override
  List<Object?> get props => [windows];
}
```

**Events:** `sealed class WindowsEvent extends Equatable`; `WindowOpened(WindowTag)`, `WindowClosed(WindowTag)`, `WindowFocused(WindowTag)`.

**UI:**
- `DesktopBody`, `Dock` and `TopBar` read from the catalog (name, icon, color, title).
- `DesktopBody` does `for (final tag in state.windows) WindowBase(key: ValueKey(tag.identifier), tag: tag, ...)`.
- `WindowBase` looks up `windowCatalog[tag.identifier]` and builds `definition.builder(context)`.
- A single `context.openWindow(tag)` extension (`window_extensions.dart`) replaces the two duplicated `openWindow(...)` functions.

---

## 4. Phases

Each block leaves the tree compiling and the tests green.

### Phase 0 — Safety net
- [x] Run `fvm flutter test` and `fvm flutter analyze` and note the baseline: **analyze = 5 infos** (pre-existing: 2 `depend_on_referenced_packages` in `notifications_bloc.dart`, 1 `use_super_parameters` + 2 `sort_child_properties_last` in `separated_*`), **test = 56 passing**. (Earlier docs said 49; that was stale.)

### Phase 1 — Add `equatable` and the catalog (bloc untouched)
- [x] `fvm flutter pub add equatable` (modifies `pubspec.yaml` and `pubspec.lock`; do not revert the existing FVM changes in the lock).
- [x] `WindowDefinition` in `lib/models/ui/window.dart`, temporarily next to `WindowConfig`.
- [x] `lib/features/desktop/window_catalog.dart` with the 6 windows (title, icon via `AppImages`, dock color, builder: `AboutMe()` and `Text` placeholders), `dockOrder`, `desktopOrder` and `windowTitle(WindowTag)`.
- [x] Preserve titles (About Me, Skills, Projects, Curriculum Vitae, Contact Me, Github) and dock colors (aboutMe `0xff227dd5`, skills `0xff12338b`, projects `0xff2798e7`, contact `0xff0e59d8`, github `0xff313133`, cv `0xffff4731`).
- [x] Test `test/features/desktop/window_catalog_test.dart`: 6 identifiers with title, icon and builder; dock and desktop order; `windowTitle` (known, `finder`, unknown).

### Phase 2 — Pure state, events and UI migration (old phases 2 + 3, one block)
- [x] `WindowTag`: `with Equatable` (equatable 3.x has no `EquatableMixin`), no `title`.
- [x] `WindowsState extends Equatable` with `windows`, derived `currentTag`, `props`, `copyWith`.
- [x] Events `Equatable`; `WindowOpened(WindowTag)`.
- [x] `WindowsBloc`: synchronous handlers (M11); no `flutter*` imports, no `window.dart` import.
- [x] `WindowBase(tag, onClose, onTap)`: resolves the catalog (M1), `VoidCallback` instead of `Function()` (M10).
- [x] `DesktopBody`, `Dock`, `TopBar` read from the catalog; `context.openWindow(tag)` in `lib/features/desktop/window_extensions.dart`; remove both local `openWindow`.
- [x] Tests: rewrite `test/bloc/windows/windows_bloc_test.dart` (new API, compare whole `WindowsState`); new tests for state equality, derived `currentTag` (empty → `finder`), opening an already-open window does not emit; update `test/models/tag_test.dart` (remove the `title` and `finder.title` tests); adapt `test/features/desktop/dock_test.dart`, `top_bar_test.dart` (title from the catalog: about_me → 'About Me', skills → 'Skills'; none → 'Finder') and `test/shared/widgets/mac_window_test.dart` (drop `title:` from `WindowTag`).

### Phase 3 — Cleanup
- [x] Remove `WindowConfig` and the dead imports.
- [x] Fix `WindowTag.toString` (L8 of the general plan).
- [x] Update `AGENTS.md` (architecture tree, Window Management / current-state sections).
- [x] In `plan/2026-05-08_1844_general-improvement-plan.md` check off: H2, H5 (windows), H6 (windows), M1, M10 (window_base part), M11, and fix the test counter.
- [x] `fvm flutter analyze` with the same 5 infos and `fvm flutter test` green.

---

## 5. Risks and mitigations

| Risk | Mitigation |
|--------|------------|
| Losing the window position/size when reordering the z-index | `DesktopBody` keeps `ValueKey(tag.identifier)` on `WindowBase`; keep it. Verify by hand by dragging, focusing another window and coming back. |
| Window state (position) lives in `DraggableMacWindow` | It stays there; it is not business logic. If persistence is wanted later, add a `WindowInstance` with `position`/`size`, already free of widgets. |
| Current tests construct `WindowConfig` | They are updated in Phase 2 together with the API change; a mechanical change. |
| `AboutMe()` is now built in the builder, not on open | Equivalent behavior: today the widget is also instantiated on tap, but it is mounted when it appears in the `Stack`. |
| `import 'package:bloc/bloc.dart'` triggers `depend_on_referenced_packages` (`bloc` is not a direct dependency) | Silence it locally with `// ignore: depend_on_referenced_packages` to avoid a new analyzer info and a second new dependency; `flutter_bloc` cannot be imported because it pulls in Flutter. |
| Equal states are no longer emitted | Documented in the test of closing an inexistent window. |
| Tests that create a bloc in `setUp` (outside the test's fake-async zone) never see its states delivered by `pump` | Create the bloc inside the test body (`desktop_body_test.dart`). |

---

## 6. Acceptance criteria

- [x] `windows_bloc.dart`, `windows_state.dart` and `windows_event.dart` do not import `package:flutter/*` (`git grep -n "package:flutter" -- lib/bloc/windows` returns nothing).
- [x] `WindowsState` and the events are comparable by value (`expect(state, WindowsState(...))`).
- [x] Adding a new window requires editing **a single place** (the catalog, plus its identifier constant and order lists).
- [x] No duplicated app lists remain in `dock.dart` or `desktop.dart`.
- [x] Identical visible behavior: open, close, focus, title in the top bar, dock dots, dock order, desktop order and dock colors.
- [x] `git grep -n "WindowConfig" -- lib test` returns nothing.
- [x] `fvm flutter analyze` (same 5 infos, none new) and `fvm flutter test` green.

---

## 7. Suggested commit order

1. `chore: add equatable dependency` (value equality for tag, state and events)
2. `refactor: add window catalog as single source of truth`
3. `refactor: make WindowsState and events plain data and resolve window content from catalog` (old commits 3 and 4 merged: the tree does not compile in between)
4. `refactor: remove WindowConfig and title from WindowTag`
5. `docs: update AGENTS.md and general improvement plan`
