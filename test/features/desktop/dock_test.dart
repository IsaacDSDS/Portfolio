import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/features/desktop/dock.dart';

Widget _makeTestable(Widget child, {WindowsBloc? bloc}) {
  return MaterialApp(
    home: BlocProvider<WindowsBloc>(
      create: (_) => bloc ?? WindowsBloc(),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Dock', () {
    testWidgets('renders 6 dock items', (tester) async {
      await tester.pumpWidget(_makeTestable(const Dock()));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedDockItem), findsNWidgets(6));
    });

    testWidgets('shows open indicator only for open windows', (tester) async {
      final bloc = WindowsBloc()
        ..add(
          const WindowOpened(
            WindowTag(identifier: WindowsTagsIdentifiers.aboutMe),
          ),
        );

      await tester.pumpWidget(_makeTestable(const Dock(), bloc: bloc));
      await tester.pumpAndSettle();

      final items = tester.widgetList<AnimatedDockItem>(
        find.byType(AnimatedDockItem),
      );
      final openItems = items.where((item) => item.isOpen).length;
      expect(openItems, 1);
    });

    testWidgets('opens window when tapping a dock item', (tester) async {
      final bloc = WindowsBloc();
      await tester.pumpWidget(_makeTestable(const Dock(), bloc: bloc));
      await tester.pumpAndSettle();

      expect(bloc.state.windows, isEmpty);

      await tester.tap(find.byType(AnimatedDockItem).first);
      await tester.pumpAndSettle();

      expect(bloc.state.windows, isNotEmpty);
      expect(
        bloc.state.windows.first.identifier,
        WindowsTagsIdentifiers.aboutMe,
      );
    });

    testWidgets('lists items in dock order with their colors', (tester) async {
      await tester.pumpWidget(_makeTestable(const Dock()));
      await tester.pumpAndSettle();

      final data = tester
          .widgetList<AnimatedDockItem>(find.byType(AnimatedDockItem))
          .map((item) => item.data)
          .toList();
      expect(data.map((d) => d.name).toList(), [
        'About Me',
        'Skills',
        'Projects',
        'Contact Me',
        'Github',
        'Curriculum Vitae',
      ]);
      expect(data.map((d) => d.color).toList(), [
        const Color(0xff227dd5),
        const Color(0xff12338b),
        const Color(0xff2798e7),
        const Color(0xff0e59d8),
        const Color(0xff313133),
        const Color(0xffff4731),
      ]);
    });

    testWidgets('shows tooltip messages on dock items', (tester) async {
      await tester.pumpWidget(_makeTestable(const Dock()));
      await tester.pumpAndSettle();

      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
      final messages = tooltips.map((t) => t.message).toList();
      expect(messages, contains('About Me'));
      expect(messages, contains('Skills'));
      expect(messages, contains('Projects'));
    });
  });
}
