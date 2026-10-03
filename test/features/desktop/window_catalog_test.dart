import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/features/desktop/window_catalog.dart';
import 'package:so_portfolio/models/ui/tag.dart';

const _allIdentifiers = [
  WindowsTagsIdentifiers.aboutMe,
  WindowsTagsIdentifiers.skills,
  WindowsTagsIdentifiers.projects,
  WindowsTagsIdentifiers.contact,
  WindowsTagsIdentifiers.github,
  WindowsTagsIdentifiers.cv,
];

void main() {
  group('windowCatalog', () {
    test('contains the 6 window identifiers and nothing else', () {
      expect(windowCatalog.keys, unorderedEquals(_allIdentifiers));
    });

    test('finder is not a catalog entry', () {
      expect(windowCatalog.containsKey(WindowTag.finder.identifier), isFalse);
    });

    test('every definition has title, icon and builder', () {
      for (final entry in windowCatalog.entries) {
        final definition = entry.value;
        expect(definition.tag.identifier, entry.key);
        expect(definition.title, isNotEmpty, reason: entry.key);
        expect(definition.icon, isNotEmpty, reason: entry.key);
        expect(definition.builder, isNotNull, reason: entry.key);
      }
    });

    test('titles are preserved', () {
      expect(
        {for (final e in windowCatalog.entries) e.key: e.value.title},
        {
          WindowsTagsIdentifiers.aboutMe: 'About Me',
          WindowsTagsIdentifiers.skills: 'Skills',
          WindowsTagsIdentifiers.projects: 'Projects',
          WindowsTagsIdentifiers.cv: 'Curriculum Vitae',
          WindowsTagsIdentifiers.contact: 'Contact Me',
          WindowsTagsIdentifiers.github: 'Github',
        },
      );
    });

    test('dock colors are preserved', () {
      expect(
        {for (final e in windowCatalog.entries) e.key: e.value.dockColor},
        {
          WindowsTagsIdentifiers.aboutMe: const Color(0xff227dd5),
          WindowsTagsIdentifiers.skills: const Color(0xff12338b),
          WindowsTagsIdentifiers.projects: const Color(0xff2798e7),
          WindowsTagsIdentifiers.contact: const Color(0xff0e59d8),
          WindowsTagsIdentifiers.github: const Color(0xff313133),
          WindowsTagsIdentifiers.cv: const Color(0xffff4731),
        },
      );
    });

    test('default size is 600x400 with no initial position', () {
      for (final definition in windowCatalog.values) {
        expect(definition.defaultSize, const Size(600, 400));
        expect(definition.initialPosition, isNull);
      }
    });
  });

  group('order lists', () {
    test('dock order', () {
      expect(dockOrder, [
        WindowsTagsIdentifiers.aboutMe,
        WindowsTagsIdentifiers.skills,
        WindowsTagsIdentifiers.projects,
        WindowsTagsIdentifiers.contact,
        WindowsTagsIdentifiers.github,
        WindowsTagsIdentifiers.cv,
      ]);
    });

    test('desktop order', () {
      expect(desktopOrder, [
        WindowsTagsIdentifiers.aboutMe,
        WindowsTagsIdentifiers.skills,
        WindowsTagsIdentifiers.projects,
        WindowsTagsIdentifiers.cv,
        WindowsTagsIdentifiers.contact,
        WindowsTagsIdentifiers.github,
      ]);
    });

    test('both lists reference only catalog entries, each exactly once', () {
      for (final order in [dockOrder, desktopOrder]) {
        expect(order, unorderedEquals(windowCatalog.keys));
        expect(order.toSet().length, order.length);
      }
    });
  });

  group('windowTitle', () {
    test('returns the catalog title for known tags', () {
      expect(
        windowTitle(const WindowTag(identifier: WindowsTagsIdentifiers.cv)),
        'Curriculum Vitae',
      );
    });

    test('returns Finder for the finder tag', () {
      expect(windowTitle(WindowTag.finder), 'Finder');
    });

    test('returns Finder for unknown identifiers', () {
      expect(windowTitle(const WindowTag(identifier: 'nope')), 'Finder');
    });
  });
}
