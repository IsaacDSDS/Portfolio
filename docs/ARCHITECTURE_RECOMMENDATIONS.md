# Recomendaciones de arquitectura — so_portfolio

> Estado: **propuesta**. Todavía no se ha movido ni modificado código.
> Punto de partida: `main` @ `faa3d7b`.

## 1. Decisión

Se compara la arquitectura actual del repo (BLoC, organización por tipo) con la de
otro proyecto (Giooby: Clean Architecture feature-first con Riverpod, GoRouter, Dio y Freezed).

**Recomendación:** mantener BLoC, pasar a organización **feature-first** y añadir una
**única fuente de datos** (`data/portfolio_data.dart`). No adoptar Clean Architecture completa.

### Por qué no adoptar la arquitectura de Giooby tal cual

| Giooby | Este portfolio |
|---|---|
| Backend .NET, API externa, JWT | Contenido estático, sin red |
| Auth, tokens, interceptors, `Result` | No aplica |
| Repositorios con contrato en `domain/` + implementación en `data/` | Un solo origen de datos |
| Muchas features con pantallas y rutas | Una pantalla de escritorio con ventanas |

Con 3 capas por feature, `Skills` o `Contact` necesitarían entidad, contrato, repositorio
y notifier solo para leer una lista constante: ceremonia sin beneficio.

### Cambios de stack descartados

- **Riverpod, GoRouter, Dio, Freezed:** BLoC ya funciona y tiene tests (8 archivos).
  Migrar cuesta tiempo y reescribir tests sin ganancia. GoRouter solo tendría sentido
  si se quisieran URLs profundas por ventana.
- **`flutter_secure_storage`, `flutter_dotenv`:** no hay secretos.

## 2. Qué se adopta de esa arquitectura

1. **Feature-first** en lugar de organizar por tipo.
2. **Separar `core/` de `shared/`**: `core/` para constantes, tema y utilidades;
   `shared/widgets/` para widgets reutilizables.
3. **Pantalla = UI, lógica fuera.** Crear un BLoC por ventana solo si hay estado real
   (p. ej. filtros en Projects). Las listas estáticas no lo necesitan.
4. **Una única fuente de datos**, equivalente ligero de su capa `data/`.
5. **Reglas documentadas**: sin datos hardcodeados en widgets y un solo punto de acceso a datos.

## 3. Estructura objetivo

```
lib/
├── main.dart
├── core/              # constants, theme, utils (date_utils unificado)
├── data/              # portfolio_data.dart (único origen de datos)
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

## 4. Problemas detectados en el estado actual

- `AGENTS.md` está desactualizado: dice que `test/` está vacío y no menciona
  `NotificationsBloc`, `core/extensions.dart`, `models/ui/window.dart` ni `utils/`.
- `date_utils.dart` está duplicado en `lib/core/` y `lib/utils/`.
- Solo existe `AboutMe`, y es un placeholder (`Container` rojo con texto).
- Los modelos de `models/info.dart` no tienen datos.
- `ThemeBloc` no persiste el tema entre recargas.
- `pubspec.yaml` solo declara `flutter_bloc` e `intl`; faltarán dependencias
  (p. ej. `url_launcher`) para enlaces y descarga del CV.

## 5. Plan de implementación (un commit por paso)

1. **Unificar utilidades y crear `shared/` y `data/`**
   - Dejar un único `date_utils.dart` y ajustar su test.
   - Mover `separated_*` a `shared/widgets/`.
   - Crear `data/portfolio_data.dart` vacío con la estructura de `Info`.
2. **Pasar a feature-first**
   - Mover `screens/desktop/*` y `windows/*` a `features/...`.
   - Actualizar imports (`package:so_portfolio/...`).
3. **Actualizar `AGENTS.md`** con la nueva estructura y las reglas del punto 2.
4. **Rellenar `portfolio_data.dart`** con los datos del perfil (a partir del PDF).
5. **Implementar ventanas**: Skills, Projects, Contact, CV, GitHub y AboutMe real.
6. **Después**: tablet/mobile, persistencia del tema, shader.

Verificación en cada paso: `flutter analyze` y `flutter test`.

## 6. Reglas de oro (a copiar en `AGENTS.md`)

- Ningún dato del portfolio hardcodeado en widgets: todo sale de `data/portfolio_data.dart`.
- Un BLoC por ventana solo si la ventana tiene estado propio.
- Los widgets reutilizables van en `shared/widgets/`; lo propio de una ventana, dentro de su feature.
- Nuevas dependencias: justificarlas en el commit.
