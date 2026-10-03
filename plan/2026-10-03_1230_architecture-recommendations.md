# Architecture recommendations — so_portfolio

> Status: **in progress**. Steps 1-3 of section 5 are implemented (not committed). Steps 4-6 are pending: they need the profile PDF (not in the repo) and the window content.
> Starting point: `main` @ `faa3d7b`.

## 1. Decision

The current architecture of this repo (BLoC, organized by type) is compared with that of
another project (Giooby: feature-first Clean Architecture with Riverpod, GoRouter, Dio and Freezed).

**Recommendation:** keep BLoC, move to a **feature-first** organization and add a
**single source of data** (`data/portfolio_data.dart`). Do not adopt full Clean Architecture.

### Why not adopt Giooby's architecture as is

| Giooby | This portfolio |
|---|---|
| .NET backend, external API, JWT | Static content, no network |
| Auth, tokens, interceptors, `Result` | Not applicable |
| Repositories with a contract in `domain/` + implementation in `data/` | A single data source |
| Many features with screens and routes | One desktop screen with windows |

With 3 layers per feature, `Skills` or `Contact` would need an entity, a contract, a repository
and a notifier just to read a constant list: ceremony with no benefit.

### Stack changes ruled out

- **Riverpod, GoRouter, Dio, Freezed:** BLoC already works and has tests (8 files).
  Migrating costs time and means rewriting tests for no gain. GoRouter would only make sense
  if deep links per window were wanted.
- **`flutter_secure_storage`, `flutter_dotenv`:** there are no secrets.

## 2. What is adopted from that architecture

1. **Feature-first** instead of organizing by type.
2. **Separate `core/` from `shared/`**: `core/` for constants, theme and utilities;
   `shared/widgets/` for reusable widgets.
3. **Screen = UI, logic outside.** Create one BLoC per window only if there is real state
   (e.g. filters in Projects). Static lists do not need one.
4. **A single source of data**, a lightweight equivalent of its `data/` layer.
5. **Documented rules**: no hardcoded data in widgets and a single access point to data.

## 3. Target structure

```
lib/
├── main.dart
├── core/              # constants, theme, utils (unified date_utils)
├── data/              # portfolio_data.dart (single data source)
├── models/            # Info, Skill, Project, Contact, WindowConfig, WindowTag
├── bloc/              # theme, windows, notifications
├── shared/
│   └── widgets/       # separated_column, separated_row, mac_window
└── features/
    ├── desktop/       # shell: top_bar, dock, desktop_body, notifications
    ├── about_me/
    ├── skills/
    ├── projects/
    ├── contact/
    ├── cv/
    ├── github/
    ├── tablet/
    └── mobile/
```

## 4. Problems detected in the current state

- `AGENTS.md` is outdated: it says `test/` is empty and does not mention
  `NotificationsBloc`, `core/extensions.dart`, `models/ui/window.dart` or `utils/`.
- `date_utils.dart` is duplicated in `lib/core/` and `lib/utils/`.
- Only `AboutMe` exists, and it is a placeholder (red `Container` with text).
- The models in `models/info.dart` have no data.
- `ThemeBloc` does not persist the theme across reloads.
- `pubspec.yaml` only declares `flutter_bloc` and `intl`; more dependencies will be needed
  (e.g. `url_launcher`) for links and CV download.

## 5. Implementation plan (one commit per step)

1. **Unify utilities and create `shared/` and `data/`**
   - Keep a single `date_utils.dart` and adjust its test.
   - Move `separated_*` to `shared/widgets/`.
   - Create an empty `data/portfolio_data.dart` with the structure of `Info`.
2. **Move to feature-first**
   - Move `screens/desktop/*` and `windows/*` to `features/...`.
   - Update imports (`package:so_portfolio/...`).
3. **Update `AGENTS.md`** with the new structure and the rules from section 2.
4. **Fill in `portfolio_data.dart`** with the profile data (from the PDF).
5. **Implement windows**: Skills, Projects, Contact, CV, GitHub and the real AboutMe.
6. **Afterwards**: tablet/mobile, theme persistence, shader.

Verification at each step: `flutter analyze` and `flutter test`.

## 6. Golden rules (to copy into `AGENTS.md`)

- No portfolio data hardcoded in widgets: everything comes from `data/portfolio_data.dart`.
- One BLoC per window only if the window has its own state.
- Reusable widgets go in `shared/widgets/`; anything specific to a window goes inside its feature.
- New dependencies: justify them in the commit.
