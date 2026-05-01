import 'package:flutter/material.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/theme/theme_getter.dart';

const double _kMinWidth = 300;
const double _kMinHeight = 200;
const double _kHandleSize = 8;

enum _ResizeEdge {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

extension _ResizeEdgeCursor on _ResizeEdge {
  MouseCursor get cursor => switch (this) {
    _ResizeEdge.topLeft ||
    _ResizeEdge.bottomRight => SystemMouseCursors.resizeUpLeftDownRight,
    _ResizeEdge.topRight ||
    _ResizeEdge.bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
    _ResizeEdge.top || _ResizeEdge.bottom => SystemMouseCursors.resizeUpDown,
    _ResizeEdge.left || _ResizeEdge.right => SystemMouseCursors.resizeLeftRight,
  };
}

class DraggableMacWindow extends StatefulWidget {
  final String title;
  final double width;
  final double height;
  final Offset? initialPosition;
  final VoidCallback? onClose, onTap;
  final String tag;
  final Function(Size) builder;

  const DraggableMacWindow({
    super.key,
    required this.tag,
    required this.title,
    required this.builder,
    this.width = 600,
    this.height = 400,
    this.initialPosition,
    this.onClose,
    this.onTap,
  });

  @override
  State<DraggableMacWindow> createState() => _DraggableMacWindowState();
}

class _DraggableMacWindowState extends State<DraggableMacWindow>
    with SingleTickerProviderStateMixin {
  Offset? _position;
  late double _width;
  late double _height;
  bool _isMaximized = false;
  bool _isDragging = false;
  bool _isResizing = false;
  Offset? _savedPosition;
  Size? _savedSize;
  late AnimationController _openController;
  late Animation<double> _openAnimation;

  @override
  void initState() {
    super.initState();
    _width = widget.width;
    _height = widget.height;
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _openAnimation = CurvedAnimation(
      parent: _openController,
      curve: Curves.easeOutBack,
    );
    _openController.forward();
  }

  @override
  void dispose() {
    _openController.dispose();
    super.dispose();
  }

  void _close() {
    _openController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isMaximized) return;
    widget.onTap?.call();
    final screen = MediaQuery.of(context).size;
    final current = _position ?? Offset.zero;
    final next = current + details.delta;
    setState(() {
      _position = Offset(
        next.dx.clamp(0, screen.width - _width),
        next.dy.clamp(0, screen.height - _height),
      );
    });
  }

  void _onHeaderDoubleTap() => _isMaximized ? _minimize() : _maximize();

  void _minimize() {
    widget.onTap?.call();
    setState(() {
      _isMaximized = false;
      _position = _savedPosition ?? _position;
      if (_savedSize != null) {
        _width = _savedSize!.width;
        _height = _savedSize!.height;
      }
    });
  }

  void _maximize() {
    widget.onTap?.call();
    final screen = MediaQuery.of(context).size;
    setState(() {
      _isMaximized = true;
      _savedPosition = _position;
      _savedSize = Size(_width, _height);
      _width = screen.width - 10;
      _height = screen.height - 10 - topBarHeight;
      _position = const Offset(5, 5);
    });
  }

  void _onResizeStart() => setState(() => _isResizing = true);
  void _onResizeEnd() => setState(() => _isResizing = false);

  void _onResize(_ResizeEdge edge, DragUpdateDetails details) {
    if (_isMaximized) return;
    widget.onTap?.call();
    final screen = MediaQuery.of(context).size;
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    final pos = _position ?? Offset.zero;

    setState(() {
      switch (edge) {
        case _ResizeEdge.right:
          _width = (_width + dx).clamp(_kMinWidth, screen.width - pos.dx);
        case _ResizeEdge.bottom:
          _height = (_height + dy).clamp(_kMinHeight, screen.height - pos.dy);
        case _ResizeEdge.left:
          final newWidth = (_width - dx).clamp(_kMinWidth, pos.dx + _width);
          _position = Offset(
            (pos.dx + (_width - newWidth)).clamp(0, screen.width - _kMinWidth),
            pos.dy,
          );
          _width = newWidth;
        case _ResizeEdge.top:
          final newHeight = (_height - dy).clamp(_kMinHeight, pos.dy + _height);
          _position = Offset(
            pos.dx,
            (pos.dy + (_height - newHeight)).clamp(
              0,
              screen.height - _kMinHeight,
            ),
          );
          _height = newHeight;
        case _ResizeEdge.bottomRight:
          _width = (_width + dx).clamp(_kMinWidth, screen.width - pos.dx);
          _height = (_height + dy).clamp(_kMinHeight, screen.height - pos.dy);
        case _ResizeEdge.bottomLeft:
          final newWidth = (_width - dx).clamp(_kMinWidth, pos.dx + _width);
          _position = Offset(
            (pos.dx + (_width - newWidth)).clamp(0, screen.width - _kMinWidth),
            pos.dy,
          );
          _width = newWidth;
          _height = (_height + dy).clamp(_kMinHeight, screen.height - pos.dy);
        case _ResizeEdge.topRight:
          _width = (_width + dx).clamp(_kMinWidth, screen.width - pos.dx);
          final newHeight = (_height - dy).clamp(_kMinHeight, pos.dy + _height);
          _position = Offset(
            pos.dx,
            (pos.dy + (_height - newHeight)).clamp(
              0,
              screen.height - _kMinHeight,
            ),
          );
          _height = newHeight;
        case _ResizeEdge.topLeft:
          final newWidth = (_width - dx).clamp(_kMinWidth, pos.dx + _width);
          final newHeight = (_height - dy).clamp(_kMinHeight, pos.dy + _height);
          _position = Offset(
            (pos.dx + (_width - newWidth)).clamp(0, screen.width - _kMinWidth),
            (pos.dy + (_height - newHeight)).clamp(
              0,
              screen.height - _kMinHeight,
            ),
          );
          _width = newWidth;
          _height = newHeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    _position ??=
        widget.initialPosition ??
        Offset(
          (screenSize.width - widget.width) / 2,
          (screenSize.height - widget.height) / 2,
        );

    return AnimatedPositioned(
      left: _position!.dx,
      top: _position!.dy,
      duration: (_isDragging || _isResizing)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      child: ScaleTransition(
        scale: _openAnimation,
        child: AnimatedContainer(
          width: _width,
          height: _height,
          duration: (_isDragging || _isResizing)
              ? Duration.zero
              : const Duration(milliseconds: 250),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Window body
              Center(
                child: GestureDetector(
                  onTapDown: (_) => widget.onTap?.call(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: context.theme.appColors.windowBodyColor,
                      boxShadow: [
                        BoxShadow(
                          color: context.theme.appColors.shadowColor,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        GestureDetector(
                          onDoubleTap: _onHeaderDoubleTap,
                          onPanUpdate: _onDragUpdate,
                          onPanStart: (_) => setState(() => _isDragging = true),
                          onPanEnd: (_) => setState(() => _isDragging = false),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.theme.appColors.windowHeaderColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: context.theme.appColors.borderColor,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                _TrafficLight(
                                  color: const Color(0xFFFF5F57),
                                  onTap: _close,
                                  icon: Icons.close,
                                ),
                                const SizedBox(width: 8),
                                _TrafficLight(
                                  color: const Color(0xFFFFBD2E),
                                  icon: Icons.remove,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 8),
                                _TrafficLight(
                                  color: const Color(0xFF28C840),
                                  icon: _isMaximized
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  onTap: () =>
                                      _isMaximized ? _minimize() : _maximize(),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: context
                                            .theme
                                            .appColors
                                            .headerTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 60),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: widget.builder(
                                  Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Resize handles
              if (!_isMaximized) ...[
                // Edges
                _ResizeHandle(
                  edge: _ResizeEdge.top,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                _ResizeHandle(
                  edge: _ResizeEdge.bottom,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                _ResizeHandle(
                  edge: _ResizeEdge.left,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                _ResizeHandle(
                  edge: _ResizeEdge.right,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                // Corners
                _ResizeHandle(
                  edge: _ResizeEdge.topLeft,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                _ResizeHandle(
                  edge: _ResizeEdge.topRight,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                _ResizeHandle(
                  edge: _ResizeEdge.bottomLeft,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
                _ResizeHandle(
                  edge: _ResizeEdge.bottomRight,
                  width: _width,
                  height: _height,
                  onResize: _onResize,
                  onResizeStart: _onResizeStart,
                  onResizeEnd: _onResizeEnd,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final _ResizeEdge edge;
  final double width;
  final double height;
  final void Function(_ResizeEdge, DragUpdateDetails) onResize;
  final VoidCallback onResizeStart;
  final VoidCallback onResizeEnd;

  const _ResizeHandle({
    required this.edge,
    required this.width,
    required this.height,
    required this.onResize,
    required this.onResizeStart,
    required this.onResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isCorner =
        edge == _ResizeEdge.topLeft ||
        edge == _ResizeEdge.topRight ||
        edge == _ResizeEdge.bottomLeft ||
        edge == _ResizeEdge.bottomRight;
    final size = isCorner ? _kHandleSize * 2 : _kHandleSize;

    double? left, top, right, bottom;
    double? w, h;

    switch (edge) {
      case _ResizeEdge.top:
        left = size;
        top = 0;
        w = width - size * 2;
        h = _kHandleSize;
      case _ResizeEdge.bottom:
        left = size;
        bottom = 0;
        w = width - size * 2;
        h = _kHandleSize;
      case _ResizeEdge.left:
        left = 0;
        top = size;
        w = _kHandleSize;
        h = height - size * 2;
      case _ResizeEdge.right:
        right = 0;
        top = size;
        w = _kHandleSize;
        h = height - size * 2;
      case _ResizeEdge.topLeft:
        left = 0;
        top = 0;
        w = size;
        h = size;
      case _ResizeEdge.topRight:
        right = 0;
        top = 0;
        w = size;
        h = size;
      case _ResizeEdge.bottomLeft:
        left = 0;
        bottom = 0;
        w = size;
        h = size;
      case _ResizeEdge.bottomRight:
        right = 0;
        bottom = 0;
        w = size;
        h = size;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: MouseRegion(
        cursor: edge.cursor,
        child: GestureDetector(
          onPanStart: (d) {
            onResizeStart();
          },
          onPanUpdate: (d) {
            onResize(edge, d);
          },
          onPanEnd: (_) {
            onResizeEnd();
          },
          child: Container(width: w, height: h, color: Colors.transparent),
        ),
      ),
    );
  }
}

class _TrafficLight extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  final IconData icon;

  const _TrafficLight({
    required this.color,
    required this.onTap,
    required this.icon,
  });

  @override
  State<_TrafficLight> createState() => _TrafficLightState();
}

class _TrafficLightState extends State<_TrafficLight> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => widget.onTap(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _hovered ? 1 : .7),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: .3),
              width: 0.5,
            ),
          ),
          child: _hovered
              ? Icon(widget.icon, size: 9, color: Colors.black54)
              : null,
        ),
      ),
    );
  }
}
