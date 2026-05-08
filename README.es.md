# so_portfolio

> Un portfolio inspirado en macOS construido con Flutter — tu escritorio, tu experiencia.

<div align="center">
  <p>
    <strong>Un portfolio con UI inspirada en macOS</strong> — una réplica visual con ventanas arrastrables, dock con magnificación y temas claro/oscuro.
  </p>
</div>

## ✨ Características

- **Experiencia de Escritorio macOS** — Emulación completa de la UI de macOS en el navegador
- **Ventanas Arrastrables y Redimensionables** — Botones semáforo (cerrar, minimizar, maximizar) con animaciones fluidas
- **Dock con Magnificación** — Efecto de escala al pasar el cursor, igual que macOS
- **Temas Claro / Oscuro** — Cambio entre temas con transición animada del fondo de pantalla
- **Barra de Menú en Vivo** — Logo de Apple, título de ventana activa y reloj en tiempo real
- **Layout Responsivo** — Breakpoints para escritorio, tablet y móvil

## 🖥️ Capturas de Pantalla

| Tema Claro | Tema Oscuro |
|-------------|------------|
| *Agrega tu captura del tema claro* | *Agrega tu captura del tema oscuro* |

## 🚀 Primeros Pasos

### Requisitos Previos

- Flutter SDK `^3.8.0`
- Dart SDK `^3.8.0`

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/<your-username>/so_portfolio.git
cd so_portfolio

# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome

# Ejecutar en macOS (nativo)
flutter run -d macos

# Build para web
flutter build web
```

## 🏗️ Arquitectura

```
lib/
├── main.dart                 # Punto de entrada
├── bloc/                     # Gestión de estado (patrón BLoC)
│   ├── theme/                # ThemeBloc — toggle claro/oscuro
│   └── windows/              # WindowsBloc — abrir/cerrar/foco/z-ordering
├── core/                     # Constantes, utilidades, widgets base
├── models/                   # Modelos de datos del portfolio (Info, Skill, Project, Contact)
├── screens/
│   ├── desktop/              # Emulación de escritorio macOS (implementado)
│   │   ├── widgets/          # TopBar, Dock, MacWindow, DesktopIcons
│   │   └── windows/          # Routers de contenido de ventanas
│   ├── mobile/               # Layout móvil (placeholder)
│   └── tablet/               # Layout tablet (placeholder)
├── theme/                    # ThemeExtension personalizada con paletas de colores macOS
└── widgets/                  # Componentes de layout reutilizables
```

## 🛠️ Stack Tecnológico

| Tecnología | Propósito |
|---|---|
| [Flutter](https://flutter.dev/) | Framework de UI multiplataforma |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Gestión de estado predecible |
| [cupertino_icons](https://pub.dev/packages/cupertino_icons) | Fuente de iconos estilo Apple |

## 📐 Detalles de Diseño

### Sistema de Ventanas
- **Z-ordering** gestionado vía lista de tags de `WindowsBloc` — último en la lista = más arriba
- **Animaciones de Abrir/Cerrar** con `Curves.easeOutBack` (250ms)
- **Sistema de redimensionado de 8 puntos** (4 bordes + 4 esquinas) con cursores de plataforma
- **Arrastre** limitado dentro de los límites de la pantalla

### Dock
- **Magnificación basada en distancia** con rango `_kSpread = 80.0`
- **Animación easeOut de 120ms** al pasar el cursor
- **Indicador de abierto** con puntos debajo de las apps en ejecución
- **Fondo semi-transparente** estilo cristal esmerilado

### Tema
- `ThemeColorExtension` personalizada para colores específicos de macOS
- **Transición de fondo de pantalla de 600ms** al cambiar de tema
- Claro: blancos cálidos (`0xfffffdfa`) | Oscuro: grises oscuros (`0xff25262d`)

## 📋 Hoja de Ruta

- [ ] Poblar datos del portfolio (habilidades, proyectos, info de contacto)
- [ ] Implementar contenido de ventanas para todas las secciones
- [ ] Integrar shader GLSL de cristal líquido en la UI
- [ ] Construir vistas para móvil y tablet
- [ ] Añadir tests unitarios y de widgets
- [ ] Persistencia del tema (shared_preferences)
- [ ] Animación de minimizar al dock

## 📄 Licencia

MIT

---

<p align="center">Construido con Flutter & ❤️</p>
