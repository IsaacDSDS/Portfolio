import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/models/ui/tag.dart';

void main() {
  group('Tag', () {
    test('equals when identifier is the same', () {
      const tag1 = WindowTag(identifier: 'about_me', title: 'About Me');
      const tag2 = WindowTag(identifier: 'about_me', title: 'Different Title');
      expect(tag1, equals(tag2));
    });

    test('not equals when identifier is different', () {
      const tag1 = WindowTag(identifier: 'about_me');
      const tag2 = WindowTag(identifier: 'skills');
      expect(tag1, isNot(equals(tag2)));
    });

    test('hashCode is same for equal tags', () {
      const tag1 = WindowTag(identifier: 'projects');
      const tag2 = WindowTag(identifier: 'projects');
      expect(tag1.hashCode, equals(tag2.hashCode));
    });

    test('hashCode differs for different identifiers', () {
      const tag1 = WindowTag(identifier: 'about_me');
      const tag2 = WindowTag(identifier: 'contact');
      expect(tag1.hashCode, isNot(equals(tag2.hashCode)));
    });

    test('identical instance equals itself', () {
      const tag = WindowTag(identifier: 'cv');
      expect(tag, equals(tag));
    });

    test('toString returns expected format', () {
      const tag = WindowTag(identifier: 'github', title: 'Github');
      expect(tag.toString(), contains('github'));
    });

    test('finder returns Tag with Finder identifier', () {
      final finder = WindowTag.finder;
      expect(finder.identifier, equals('Finder'));
      expect(finder.title, isEmpty);
    });

    test('title defaults to empty string', () {
      const tag = WindowTag(identifier: 'test');
      expect(tag.title, isEmpty);
    });
  });
}
