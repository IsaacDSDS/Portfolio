import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/features/desktop/window_base.dart';
import 'package:so_portfolio/models/ui/tag.dart';

/// Stacks the open windows in z-order (last is on top).
///
/// Flutter skips rebuilding a child when it receives the very same widget
/// instance. Each open window keeps its [WindowBase] instance for as long as
/// it stays open, so opening, closing or focusing one window does not rebuild
/// the others; only the new, removed or moved children change. The windows
/// still rebuild on their own when the theme or screen size changes, because
/// they depend on those through their own context.
class WindowLayer extends StatefulWidget {
  const WindowLayer({super.key});

  @override
  State<WindowLayer> createState() => _WindowLayerState();
}

class _WindowLayerState extends State<WindowLayer> {
  final Map<WindowTag, WindowBase> _windows = {};

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WindowsBloc>();
    final tags = context.select<WindowsBloc, List<WindowTag>>(
      (bloc) => bloc.state.windows,
    );

    final open = tags.toSet();
    _windows.removeWhere((tag, _) => !open.contains(tag));

    return Stack(
      fit: StackFit.expand,
      children: [
        for (final tag in tags)
          _windows.putIfAbsent(
            tag,
            () => WindowBase(
              key: ValueKey(tag.identifier),
              tag: tag,
              onClose: () => bloc.add(WindowClosed(tag)),
              onTap: () => bloc.add(WindowFocused(tag)),
            ),
          ),
      ],
    );
  }
}
