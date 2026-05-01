import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/screens/desktop/widgets/top_bar.dart';
import 'package:so_portfolio/widgets/mac_window.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final windowsBloc = context.read<WindowsBloc>();
    final themeBloc = context.watch<ThemeBloc>();
    final isDark = themeBloc.state.isDark;

    return Scaffold(
      body: BlocBuilder<WindowsBloc, WindowsState>(
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/backgrounds/light_desktop.jpg',
                      fit: BoxFit.cover,
                    ),
                    AnimatedOpacity(
                      opacity: isDark ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Image.asset(
                        'assets/backgrounds/dark_desktop.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    TopBar(),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () => windowsBloc.add(
                                      WindowOpened(
                                        'prueba_${DateTime.now().millisecondsSinceEpoch}',
                                      ),
                                    ),
                                    child: const Text('Open Prueba'),
                                  ),
                                ),
                              ),
                              for (final tag in state.tags)
                                DraggableMacWindow(
                                  key: ValueKey(tag),
                                  tag: tag,
                                  title: tag,
                                  builder: (size) => Text(
                                    'hola $tag ${size.width} x ${size.height}',
                                  ),
                                  onClose: () =>
                                      windowsBloc.add(WindowClosed(tag)),
                                  onTap: () =>
                                      windowsBloc.add(WindowFocused(tag)),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return FloatingActionButton(
            onPressed: () => themeBloc.add(ThemeToggled()),
            child: Icon(themeState.isDark ? Icons.light_mode : Icons.dark_mode),
          );
        },
      ),
    );
  }
}
