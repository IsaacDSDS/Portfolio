import 'package:flutter/material.dart';
import 'package:so_portfolio/models/ui/tag.dart';

class WindowConfig {
  final WindowTag tag;
  final Widget child;
  final double width;
  final double height;
  final Offset? initialPosition;

  const WindowConfig({
    required this.tag,
    required this.child,
    this.width = 600,
    this.height = 400,
    this.initialPosition,
  });
}
