import 'package:flutter/material.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/features/about_me/about_me.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/models/ui/window.dart';

const String _finderTitle = 'Finder';

/// Single source of truth for window chrome (title, icon, dock color) and
/// content. Adding a window means adding an entry here (and its identifier).
final Map<String, WindowDefinition> windowCatalog = {
  for (final definition in _definitions) definition.tag.identifier: definition,
};

/// Window identifiers in the order the dock lists them.
const List<String> dockOrder = [
  WindowsTagsIdentifiers.aboutMe,
  WindowsTagsIdentifiers.skills,
  WindowsTagsIdentifiers.projects,
  WindowsTagsIdentifiers.contact,
  WindowsTagsIdentifiers.github,
  WindowsTagsIdentifiers.cv,
];

/// Window identifiers in the order the desktop icons list them.
const List<String> desktopOrder = [
  WindowsTagsIdentifiers.aboutMe,
  WindowsTagsIdentifiers.skills,
  WindowsTagsIdentifiers.projects,
  WindowsTagsIdentifiers.cv,
  WindowsTagsIdentifiers.contact,
  WindowsTagsIdentifiers.github,
];

/// Title shown in the top bar for [tag]. `Finder` (and any identifier that is
/// not in the catalog) falls back to `'Finder'`.
String windowTitle(WindowTag tag) =>
    windowCatalog[tag.identifier]?.title ?? _finderTitle;

final List<WindowDefinition> _definitions = [
  WindowDefinition(
    tag: const WindowTag(identifier: WindowsTagsIdentifiers.aboutMe),
    title: 'About Me',
    icon: AppImages.aboutMe,
    dockColor: const Color(0xff227dd5),
    builder: (_) => const AboutMe(),
  ),
  WindowDefinition(
    tag: const WindowTag(identifier: WindowsTagsIdentifiers.skills),
    title: 'Skills',
    icon: AppImages.skills,
    dockColor: const Color(0xff12338b),
    builder: (_) => const Text('Skills'),
  ),
  WindowDefinition(
    tag: const WindowTag(identifier: WindowsTagsIdentifiers.projects),
    title: 'Projects',
    icon: AppImages.projects,
    dockColor: const Color(0xff2798e7),
    builder: (_) => const Text('Projects'),
  ),
  WindowDefinition(
    tag: const WindowTag(identifier: WindowsTagsIdentifiers.cv),
    title: 'Curriculum Vitae',
    icon: AppImages.cv,
    dockColor: const Color(0xffff4731),
    builder: (_) => const Text('CV'),
  ),
  WindowDefinition(
    tag: const WindowTag(identifier: WindowsTagsIdentifiers.contact),
    title: 'Contact Me',
    icon: AppImages.contact,
    dockColor: const Color(0xff0e59d8),
    builder: (_) => const Text('Contact'),
  ),
  WindowDefinition(
    tag: const WindowTag(identifier: WindowsTagsIdentifiers.github),
    title: 'Github',
    icon: AppImages.github,
    dockColor: const Color(0xff313133),
    builder: (_) => const Text('Github'),
  ),
];
