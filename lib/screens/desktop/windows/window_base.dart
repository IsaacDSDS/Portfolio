import 'package:flutter/material.dart';
import 'package:so_portfolio/models/ui/window.dart';
import 'package:so_portfolio/screens/desktop/widgets/mac_window.dart';

class WindowBase extends StatelessWidget {
  final WindowConfig window;
  final Function() onClose;
  final Function() onTap;

  const WindowBase({
    super.key,
    required this.window,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableMacWindow(
      tag: window.tag,
      title: window.tag.title,
      builder: _buildContent,
      onClose: onClose,
      onTap: onTap,
      width: window.width,
      height: window.height,
      initialPosition: window.initialPosition,
    );
  }

  Widget _buildContent(Size size) {
    return window.child;
  }
}
