import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/screens/desktop/widgets/mac_window.dart';

Widget _makeTestable(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(1200, 800)),
      child: Scaffold(body: Stack(children: [child])),
    ),
  );
}

void main() {
  group('DraggableMacWindow', () {
    final testTag = const WindowTag(identifier: 'test', title: 'Test');

    testWidgets('renders window with title', (tester) async {
      await tester.pumpWidget(
        _makeTestable(
          DraggableMacWindow(
            tag: testTag,
            title: 'My Window',
            builder: (_) => const Text('Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Window'), findsOneWidget);
    });

    testWidgets('renders builder content', (tester) async {
      await tester.pumpWidget(
        _makeTestable(
          DraggableMacWindow(
            tag: testTag,
            title: 'Test',
            builder: (_) => const Text('Hello World'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('calls onClose when close button is tapped', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        _makeTestable(
          DraggableMacWindow(
            tag: testTag,
            title: 'Test',
            builder: (_) => const SizedBox(),
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the center of the red traffic light button
      // It's the first Container with BoxShape.circle in the header Row
      final redButton = find.byType(Container).evaluate().firstWhere((e) {
        final widget = e.widget as Container;
        final decoration = widget.decoration as BoxDecoration?;
        return decoration?.shape == BoxShape.circle;
      }, orElse: () => throw Exception('Red button not found'));
      await tester.tap(find.byWidget(redButton.widget));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(closed, isTrue);
    });

    testWidgets('renders 3 traffic light buttons', (tester) async {
      await tester.pumpWidget(
        _makeTestable(
          DraggableMacWindow(
            tag: testTag,
            title: 'Test',
            builder: (_) => const SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final circles = tester.widgetList<Container>(
        find.descendant(of: find.byType(Row), matching: find.byType(Container)),
      );
      final trafficLights = circles.where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(trafficLights, hasLength(3));
    });

    testWidgets('starts with open animation', (tester) async {
      await tester.pumpWidget(
        _makeTestable(
          DraggableMacWindow(
            tag: testTag,
            title: 'Test',
            builder: (_) => const SizedBox(),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
