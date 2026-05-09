import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/models/ui/tag.dart';

void main() {
  group('Tag', () {
    test('equals when identifier is the same', () {
      const tag1 = Tag(identifier: 'about_me', title: 'About Me');
      const tag2 = Tag(identifier: 'about_me', title: 'Different Title');
      expect(tag1, equals(tag2));
    });

    test('not equals when identifier is different', () {
      const tag1 = Tag(identifier: 'about_me');
      const tag2 = Tag(identifier: 'skills');
      expect(tag1, isNot(equals(tag2)));
    });

    test('hashCode is same for equal tags', () {
      const tag1 = Tag(identifier: 'projects');
      const tag2 = Tag(identifier: 'projects');
      expect(tag1.hashCode, equals(tag2.hashCode));
    });

    test('hashCode differs for different identifiers', () {
      const tag1 = Tag(identifier: 'about_me');
      const tag2 = Tag(identifier: 'contact');
      expect(tag1.hashCode, isNot(equals(tag2.hashCode)));
    });

    test('identical instance equals itself', () {
      const tag = Tag(identifier: 'cv');
      expect(tag, equals(tag));
    });

    test('toString returns expected format', () {
      const tag = Tag(identifier: 'github', title: 'Github');
      expect(tag.toString(), contains('github'));
    });

    test('finder returns Tag with Finder identifier', () {
      final finder = Tag.finder;
      expect(finder.identifier, equals('Finder'));
      expect(finder.title, isEmpty);
    });

    test('title defaults to empty string', () {
      const tag = Tag(identifier: 'test');
      expect(tag.title, isEmpty);
    });
  });
}
