import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/widgets/mac_window.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final windowsBloc = context.read<WindowsBloc>();
    final themeBloc = context.read<ThemeBloc>();

    return Scaffold(
      body: BlocBuilder<WindowsBloc, WindowsState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xff7aa9ff), Color(0xffe6ff6a)],
                    ),
                  ),
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
              ),
              for (final tag in state.tags)
                DraggableMacWindow(
                  key: ValueKey(tag),
                  tag: tag,
                  title: tag,
                  builder: (size) =>
                      Text('hola $tag ${size.width} x ${size.height}'),
                  onClose: () => windowsBloc.add(WindowClosed(tag)),
                  onTap: () => windowsBloc.add(WindowFocused(tag)),
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
