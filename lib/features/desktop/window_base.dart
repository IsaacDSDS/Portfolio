import 'package:flutter/material.dart';
import 'package:so_portfolio/features/desktop/window_catalog.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/shared/widgets/mac_window.dart';

class WindowBase extends StatelessWidget {
  final WindowTag tag;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const WindowBase({
    super.key,
    required this.tag,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final definition = windowCatalog[tag.identifier];
    assert(definition != null, 'No window in the catalog for $tag');
    if (definition == null) return const SizedBox.shrink();

    return DraggableMacWindow(
      tag: tag,
      title: definition.title,
      builder: (_) => definition.builder(context),
      onClose: onClose,
      onTap: onTap,
      width: definition.defaultSize.width,
      height: definition.defaultSize.height,
      initialPosition: definition.initialPosition,
    );
  }
}
