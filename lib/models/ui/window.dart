import 'package:flutter/material.dart';
import 'package:so_portfolio/models/ui/tag.dart';

/// Static description of a window type: how it looks in the dock, on the
/// desktop and in the top bar, and which widget it shows.
///
/// It is UI chrome and never lives in the BLoC state; the state only keeps the
/// [WindowTag]s of the open windows.
class WindowDefinition {
  final WindowTag tag;
  final String title;
  final String icon;
  final Color dockColor;
  final Size defaultSize;
  final Offset? initialPosition;
  final WidgetBuilder builder;

  const WindowDefinition({
    required this.tag,
    required this.title,
    required this.icon,
    required this.dockColor,
    required this.builder,
    this.defaultSize = const Size(600, 400),
    this.initialPosition,
  });
}
