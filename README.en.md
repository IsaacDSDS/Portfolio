# so_portfolio

> A macOS-inspired portfolio built with Flutter — your desktop, your experience.

<div align="center">
  <p>
    <strong>Interactive macOS UI emulation</strong> with draggable windows, magnifying dock, and dark/light themes.
  </p>
</div>

## ✨ Features

- **macOS Desktop Experience** — Full emulation of the macOS UI in the browser
- **Draggable & Resizable Windows** — Traffic light buttons (close, minimize, maximize) with smooth animations
- **Magnifying Dock** — Hover-to-scale effect just like macOS
- **Dark / Light Themes** — Toggle between themes with animated wallpaper crossfade
- **Live Menu Bar** — Apple logo, active window title, and real-time clock
- **Responsive Layout** — Desktop, tablet, and mobile breakpoints
- **Custom GLSL Shader** — Liquid glass lens effect (WIP)

## 🖥️ Screenshots

| Light Theme | Dark Theme |
|-------------|------------|
| *Add your light theme screenshot* | *Add your dark theme screenshot* |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.8.0`
- Dart SDK `^3.8.0`

### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/so_portfolio.git
cd so_portfolio

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on macOS (native)
flutter run -d macos

# Build for web
flutter build web
```

## 🏗️ Architecture

```
lib/
├── main.dart                 # Entry point
├── bloc/                     # State management (BLoC pattern)
│   ├── theme/                # ThemeBloc — dark/light toggle
│   └── windows/              # WindowsBloc — open/close/focus/z-ordering
├── core/                     # Constants, utilities, base widgets
├── models/                   # Portfolio data models (Info, Skill, Project, Contact)
├── screens/
│   ├── desktop/              # macOS desktop emulation (fully implemented)
│   │   ├── widgets/          # TopBar, Dock, MacWindow, DesktopIcons
│   │   └── windows/          # Window content routers
│   ├── mobile/               # Mobile layout (placeholder)
│   └── tablet/               # Tablet layout (placeholder)
├── theme/                    # Custom ThemeExtension with macOS color palettes
└── widgets/                  # Reusable layout components
```

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) | Cross-platform UI framework |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Predictable state management |
| [cupertino_icons](https://pub.dev/packages/cupertino_icons) | Apple-style icon font |
| GLSL Shaders | Liquid glass magnification effect |

## 📐 Design Details

### Window System
- **Z-ordering** managed via `WindowsBloc` tag list — last in list = topmost
- **Open/Close animations** with `Curves.easeOutBack` (250ms)
- **8-point resize** system (4 edges + 4 corners) with platform cursors
- **Drag** constrained within screen bounds

### Dock
- **Distance-based magnification** with `_kSpread = 80.0` range
- **120ms easeOut** animation on hover
- **Open indicator** dots beneath running apps
- **Frosted glass** semi-transparent background

### Theme
- Custom `ThemeColorExtension` for macOS-specific colors
- Smooth **600ms wallpaper crossfade** on theme toggle
- Light: warm whites (`0xfffffdfa`) | Dark: dark grays (`0xff25262d`)

## 📋 Roadmap

- [ ] Populate portfolio data (skills, projects, contact info)
- [ ] Implement window content for all sections
- [ ] Integrate GLSL liquid glass shader into UI
- [ ] Build mobile & tablet views
- [ ] Add unit & widget tests
- [ ] Theme persistence (shared_preferences)
- [ ] Minimize animation to dock

## 📄 License

MIT

---

<p align="center">Built with Flutter & ❤️</p>
