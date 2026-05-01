import 'package:flutter/material.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/screens/desktop/widgets/mac_window.dart';
import 'package:so_portfolio/screens/desktop/windows/about_me.dart';

class WindowBase extends StatelessWidget {
  final Tag tag;
  final Function() onClose;
  final Function() onTap;

  const WindowBase({
    super.key,
    required this.tag,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableMacWindow(
      tag: tag,
      title: title,
      builder: _buildContent,
      onClose: onClose,
      onTap: onTap,
    );
  }

  String get title {
    switch (tag.identifier) {
      case WindowsTagsIdentifiers.aboutMe:
        return "About Me";
      case WindowsTagsIdentifiers.skills:
        return "Skills";
      case WindowsTagsIdentifiers.projects:
        return "Projects";
      case WindowsTagsIdentifiers.contact:
        return "Contact";
      default:
        return "Window";
    }
  }

  Widget _buildContent(Size size) {
    switch (tag.identifier) {
      case WindowsTagsIdentifiers.aboutMe:
        return AboutMe();
      case WindowsTagsIdentifiers.skills:
        return Text('Skills');
      case WindowsTagsIdentifiers.projects:
        return Text('Projects');
      case WindowsTagsIdentifiers.contact:
        return Text('Contact');
      default:
        return Container();
    }
  }
}
