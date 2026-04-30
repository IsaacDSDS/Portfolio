import 'package:flutter/material.dart';

class DraggableMacWindow extends StatefulWidget {
  final String title;
  final double width;
  final double height;
  final Offset initialPosition;
  final ValueChanged<String>? onClose;
  final String tag;
  final Function(Size) builder;

  const DraggableMacWindow({
    super.key,
    required this.tag,
    required this.title,
    this.width = 400,
    this.height = 300,
    this.initialPosition = const Offset(100, 100),
    this.onClose,
    required this.builder,
  });

  @override
  State<DraggableMacWindow> createState() => _DraggableMacWindowState();
}

class _DraggableMacWindowState extends State<DraggableMacWindow>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  bool _isMaximized = false;
  bool _isDragging = false;
  Offset? _savedPosition;
  late AnimationController _openController;
  late Animation<double> _openAnimation;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
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
      widget.onClose?.call(widget.tag);
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isMaximized) return;

    setState(() {
      _position = _position + details.delta;
    });
  }

  void _onHeaderDoubleTap() {
    if (_isMaximized) {
      _minimize();
    } else {
      _maximize();
    }
  }

  void _minimize() {
    setState(() {
      _isMaximized = false;
      _position = _savedPosition ?? widget.initialPosition;
    });
  }

  void _maximize() {
    setState(() {
      _isMaximized = true;
      _savedPosition = _position;
      _position = const Offset(5, 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final windowWidth = (_isMaximized ? screenSize.width : widget.width) - 10;
    final windowHeight =
        (_isMaximized ? screenSize.height : widget.height) - 10;

    return AnimatedPositioned(
      duration: _isDragging
          ? const Duration(milliseconds: 0)
          : const Duration(milliseconds: 250),
      left: _position.dx,
      top: _position.dy,
      child: ScaleTransition(
        scale: _openAnimation,
        child: AnimatedContainer(
          width: windowWidth,
          duration: const Duration(milliseconds: 250),
          height: windowHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onDoubleTap: _onHeaderDoubleTap,
                onPanUpdate: _onDragUpdate,
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                onPanStart: (details) {
                  setState(() {
                    _isDragging = true;
                  });
                },

                child: Container(
                  height: 40,
                  color: const Color(0xFFE8E8E8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _TrafficLight(
                        color: const Color(0xFFFF5F57),
                        onTap: _close,
                      ),
                      const SizedBox(width: 8),
                      _TrafficLight(
                        color: const Color(0xFFFFBD2E),
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _TrafficLight(
                        color: const Color(0xFF28C840),
                        onTap: () => _isMaximized ? _minimize() : _maximize(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
              ),
              // --- CONTENIDO animado ---
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
    );
  }
}

class _TrafficLight extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const _TrafficLight({required this.color, required this.onTap});

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
            color: _hovered ? widget.color : widget.color.withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
