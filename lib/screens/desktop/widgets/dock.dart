import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/widgets/separated_row.dart';

const double _kBaseSize = bottomBarHeight - 25;
const double _kMaxSize = 70;
const double _kSpread = 80.0;

class Dock extends StatefulWidget {
  const Dock({super.key});

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  double? _mouseX;

  void openWindow({
    required BuildContext context,
    required String identifier,
    required String title,
  }) {
    context.read<WindowsBloc>().add(
      WindowOpened(Tag(identifier: identifier, title: title)),
    );
  }

  double sizeForIndex(int index, int total) {
    if (_mouseX == null) return _kBaseSize;
    final itemWidth = _kBaseSize + 5; // base + separator
    final dockWidth = total * itemWidth - 5;
    final centerX = (index + 0.5) * itemWidth - dockWidth / 2;
    final dist = (_mouseX! - centerX).abs();
    final t = (1 - (dist / _kSpread)).clamp(0.0, 1.0);
    return _kBaseSize + (_kMaxSize - _kBaseSize) * t;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return MouseRegion(
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(event.position);
        setState(() => _mouseX = local.dx - box.size.width / 2);
      },
      onExit: (_) => setState(() => _mouseX = null),
      child: IntrinsicWidth(
        child: SizedBox(
          height: bottomBarHeight,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SeparatedRow(
                    separatorBuilder: (context, index) => SizedBox(width: 5),
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      return AnimatedDockItem(
                        size: sizeForIndex(i, items.length),
                        data: item,
                        isOpen: item.isOpen,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DockItemData> _buildItems(BuildContext context) {
    final openWindows = context.select<WindowsBloc, List<Tag>>(
      (bloc) => bloc.state.tags,
    );

    return [
      DockItemData(
        icon: 'assets/icons/about_me.png',
        name: 'About Me',
        color: const Color(0xff227dd5),
        isOpen: openWindows.any(
          (tag) => tag.identifier == WindowsTagsIdentifiers.aboutMe,
        ),
        onTap: () => openWindow(
          context: context,
          identifier: WindowsTagsIdentifiers.aboutMe,
          title: 'About Me',
        ),
      ),
      DockItemData(
        icon: 'assets/icons/skills.png',
        name: 'Skills',
        color: const Color(0xff12338b),
        isOpen: openWindows.any(
          (tag) => tag.identifier == WindowsTagsIdentifiers.skills,
        ),
        onTap: () => openWindow(
          context: context,
          identifier: WindowsTagsIdentifiers.skills,
          title: 'Skills',
        ),
      ),
      DockItemData(
        icon: 'assets/icons/projects.png',
        name: 'Projects',
        color: const Color(0xff2798e7),
        isOpen: openWindows.any(
          (tag) => tag.identifier == WindowsTagsIdentifiers.projects,
        ),
        onTap: () => openWindow(
          context: context,
          identifier: WindowsTagsIdentifiers.projects,
          title: 'Projects',
        ),
      ),
      DockItemData(
        icon: 'assets/icons/contact.png',
        name: 'Contact Me',
        color: const Color(0xff0e59d8),
        isOpen: openWindows.any(
          (tag) => tag.identifier == WindowsTagsIdentifiers.contact,
        ),
        onTap: () => openWindow(
          context: context,
          identifier: WindowsTagsIdentifiers.contact,
          title: 'Contact Me',
        ),
      ),
      DockItemData(
        icon: 'assets/icons/github.png',
        name: 'Github',
        color: Color(0xff313133),
        isOpen: openWindows.any(
          (tag) => tag.identifier == WindowsTagsIdentifiers.github,
        ),
        onTap: () => openWindow(
          context: context,
          identifier: WindowsTagsIdentifiers.github,
          title: 'Github',
        ),
      ),
      DockItemData(
        icon: 'assets/icons/cv.png',
        name: 'Curriculum Vitae',
        color: const Color(0xffff4731),
        isOpen: openWindows.any(
          (tag) => tag.identifier == WindowsTagsIdentifiers.cv,
        ),
        onTap: () => openWindow(
          context: context,
          identifier: WindowsTagsIdentifiers.cv,
          title: 'Curriculum Vitae',
        ),
      ),
    ];
  }
}

class DockItemData {
  final String icon;
  final String name;
  final VoidCallback onTap;
  final Color? color;
  final bool isOpen;

  const DockItemData({
    required this.icon,
    required this.name,
    required this.onTap,
    required this.color,
    this.isOpen = false,
  });
}

class AnimatedDockItem extends StatelessWidget {
  final double size;
  final DockItemData data;
  final bool isOpen;

  const AnimatedDockItem({
    super.key,
    required this.size,
    required this.data,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: data.name,
      preferBelow: false,
      verticalOffset: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: GestureDetector(
        onTap: data.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              width: size,
              height: size,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(size * 0.25),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(data.icon),
            ),
            SizedBox(height: 3),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isOpen
                    ? Colors.white.withValues(alpha: .6)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  final String icon;
  final String name;
  final VoidCallback onTap;
  final Color? color;

  const DockItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: _kBaseSize,
        height: _kBaseSize,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(icon),
      ),
    );
  }
}
