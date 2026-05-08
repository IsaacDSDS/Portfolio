# 📋 Improvement Plan — so_portfolio

> Tracked progress from critical fixes to nice-to-haves. Updated as work progresses.

---

## 🔴 Critical — Must Fix Before Launch

- [ ] **C1 — Add Tests**
  - Write tests for `ThemeBloc` (toggle event)
  - Write tests for `WindowsBloc` (open/close/focus events)
  - Write tests for `Tag` (equality/hashCode)
  - Write tests for `AppDateUtils` (formatting)
  - Write widget tests for `Dock`, `TopBar`, `DraggableMacWindow`

- [ ] **C2 — Implement Window Content**
  - Replace `AboutMe` placeholder with real UI
  - Implement `Skills` window
  - Implement `Projects` window
  - Implement `Contact` window
  - Implement `Github` window
  - Implement `CV` window
  - Populate `Info`, `Skill`, `Project`, `Contact` models with real data

- [ ] **C3 — Implement Mobile & Tablet Views**
  - Design mobile layout (single-column scrollable)
  - Design tablet layout
  - Replace placeholder `Text` widgets with real UI

- [ ] **C4 — Add LICENSE File**
  - Create `LICENSE` with MIT license text

---

## 🟠 High Priority — Significant Impact

- [ ] **H1 — Remove Dead Code**
  - Remove or integrate `DockItem` class (`dock.dart`)
  - Remove or integrate `StatefulWithTag` (`stateful_with_tag.dart`)
  - Remove or integrate `SeparatedColumn` (`separated_column.dart`)
  - Remove or integrate `Info`, `Skill`, `Project`, `Contact` models into UI

- [ ] **H2 — Eliminate Data Duplication**
  - Create single source of truth: `List<PortfolioSection>` constant
  - Refactor dock and desktop icons to consume shared data

- [ ] **H3 — Extract Magic Numbers**
  - `mac_window.dart`: border radius, header height, padding, traffic light size, shadow values
  - `dock.dart`: base size, item width, padding, tooltip offset, indicator dot size
  - `top_bar.dart`: shadow blur, padding, translate offset
  - `desktop.dart`: padding, spacing, runSpacing
  - `app.dart`: container width, icon size, border radius, font size, stroke width

- [ ] **H4 — Add Missing `const`**
  - All eligible widget constructors across all UI files
  - All immutable objects (`EdgeInsets`, `BorderRadius`, `BoxShadow`, `TextStyle`, `SizedBox`)

- [ ] **H5 — Add Equality to BLoC Events**
  - `theme_event.dart`: `ThemeEvent`, `ThemeToggled`
  - `windows_event.dart`: `WindowsEvent`, `WindowOpened`, `WindowClosed`, `WindowFocused`
  - Add `equatable` package dependency

- [ ] **H6 — Add Equality to BLoC States**
  - `windows_state.dart`: `WindowsState`
  - `theme_state.dart`: `ThemeState`

---

## 🟡 Medium Priority — Quality & Maintainability

- [ ] **M1 — Replace Switch with Registry Pattern**
  - `window_base.dart`: replace `switch` with `Map<String, WidgetBuilder>`

- [ ] **M2 — Fix Position Initialization**
  - `mac_window.dart`: move `_position` init from `build()` to `initState()`

- [ ] **M3 — Extract Clock Widget**
  - `top_bar.dart`: isolate clock into separate `StatefulWidget` to avoid full rebuild

- [ ] **M4 — Cache MediaQuery**
  - Cache `MediaQuery.sizeOf(context)` at top of `build()` in `mac_window.dart`, `top_bar.dart`

- [ ] **M5 — Limit ThemeBloc Watch Scope**
  - `desktop.dart`: use `context.select` or extract wallpaper to separate widget

- [ ] **M6 — Theme-Aware Dock Background**
  - Add `dockBackgroundColor` to `ThemeColorExtension`

- [ ] **M7 — Enable Additional Lint Rules**
  - `prefer_const_constructors`, `prefer_const_declarations`, `require_trailing_commas`, `sort_pub_dependencies`, `avoid_redundant_argument_values`

- [ ] **M8 — Update pubspec.yaml Description**
  - Replace "A new Flutter project." with project-specific description

- [ ] **M9 — Add Missing Dependencies**
  - `equatable` — for BLoC event/state equality
  - `url_launcher` — for opening external links

- [ ] **M10 — Fix Type Signatures**
  - `window_base.dart`: `Function()` → `VoidCallback`
  - `mac_window.dart`: `Function(Size)` → `Widget Function(Size)`

- [ ] **M11 — Remove Unnecessary Async**
  - `windows_bloc.dart`: make handlers synchronous (no `await` calls)

---

## 🟢 Low Priority — Nice to Have

- [ ] **L1 — Add Error Handling for Assets**
  - Add `errorBuilder` to all `Image.asset` calls

- [ ] **L2 — Add Accessibility (a11y)**
  - `Semantics` labels on icon-only buttons
  - Keyboard navigation support
  - Focus management

- [ ] **L3 — Keyboard Shortcuts**
  - Cmd+W to close, Cmd+M to minimize, etc.

- [ ] **L4 — CI/CD Pipeline**
  - GitHub Actions workflow: `flutter pub get` → `flutter analyze` → `flutter test`

- [ ] **L5 — CHANGELOG.md**
  - Follow [Keep a Changelog](https://keepachangelog.com/) format

- [ ] **L6 — Update .gitignore**
  - Add `*.log`, `**/coverage/`

- [ ] **L7 — Resolve TODO: i18n**
  - Implement `flutter_localizations` or remove TODO

- [ ] **L8 — Fix Tag.toString()**
  - Change "name" → "identifier", remove hashCode, add title

- [ ] **L9 — Integrate or Remove GLSL Shader**
  - Either use `liquid_glass_lens.frag` in UI or remove from pubspec

- [ ] **L10 — Remove Dead Code Path**
  - `screens.dart`: unreachable `return SizedBox()`

---

## 📊 Progress

| Phase | Status | Items |
|-------|--------|-------|
| Phase 1 — Foundations | ⬜ Not Started | H5, H6, H7, M9, M11, M10, H4 |
| Phase 2 — Cleanup | ⬜ Not Started | H1, H2, H3, M7, M8, C4 |
| Phase 3 — Architecture | ⬜ Not Started | M1, M2, M3, M4, M5, M6 |
| Phase 4 — Content | ⬜ Not Started | C2, C3 |
| Phase 5 — Quality | ⬜ Not Started | C1, L1–L10 |

**Overall:** 0 / 31 items completed

---

## Execution Order

```
Phase 1 (Foundations)  →  Phase 2 (Cleanup)  →  Phase 3 (Architecture)
        ↓                        ↓                        ↓
   equatable, types,       dead code, magic        registry, initState,
   const, deps             numbers, lints          timer, mediaQuery
        ↓                        ↓                        ↓
Phase 4 (Content)  →  Phase 5 (Quality)
        ↓                        ↓
   window content,        tests, a11y, CI/CD,
   mobile/tablet          changelog, misc
```
