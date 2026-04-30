import 'package:flutter/material.dart';
import 'package:so_portfolio/theme/theme_getter.dart';

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
  bool _isMaximized = false;
  bool _isDragging = false;
  Offset? _savedPosition;
  late AnimationController _openController;
  late Animation<double> _openAnimation;

  @override
  void initState() {
    super.initState();
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
    setState(() => _position = (_position ?? Offset.zero) + details.delta);
  }

  void _onHeaderDoubleTap() => _isMaximized ? _minimize() : _maximize();

  void _minimize() {
    widget.onTap?.call();
    setState(() {
      _isMaximized = false;
      _position = _savedPosition ?? _position;
    });
  }

  void _maximize() {
    widget.onTap?.call();
    setState(() {
      _isMaximized = true;
      _savedPosition = _position;
      _position = const Offset(5, 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final windowWidth = _isMaximized ? screenSize.width - 10 : widget.width;
    final windowHeight = _isMaximized ? screenSize.height - 10 : widget.height;

    _position ??=
        widget.initialPosition ??
        Offset(
          (screenSize.width - widget.width) / 2,
          (screenSize.height - widget.height) / 2,
        );

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 250),
      left: _position!.dx,
      top: _position!.dy,
      child: GestureDetector(
        onTapDown: (_) => widget.onTap?.call(),
        child: ScaleTransition(
          scale: _openAnimation,
          child: AnimatedContainer(
            width: windowWidth,
            height: windowHeight,
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
                          onTap: () => _isMaximized ? _minimize() : _maximize(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.theme.appColors.headerTextColor,
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
                          Size(constraints.maxWidth, constraints.maxHeight),
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
            color: widget.color.withValues(alpha: .7),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: .3),
              width: 0.5,
            ),
          ),

          child: AnimatedOpacity(
            opacity: _hovered ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Icon(
              widget.icon,
              size: 12,
              color: _hovered
                  ? Colors.black.withValues(alpha: .65)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
