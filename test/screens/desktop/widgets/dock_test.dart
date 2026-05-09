import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/screens/desktop/widgets/dock.dart';

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
          WindowOpened(
            const Tag(identifier: WindowsTagsIdentifiers.aboutMe, title: 'About Me'),
          ),
        );

      await tester.pumpWidget(_makeTestable(const Dock(), bloc: bloc));
      await tester.pumpAndSettle();

      final items = tester.widgetList<AnimatedDockItem>(find.byType(AnimatedDockItem));
      final openItems = items.where((item) => item.isOpen).length;
      expect(openItems, 1);
    });

    testWidgets('opens window when tapping a dock item', (tester) async {
      final bloc = WindowsBloc();
      await tester.pumpWidget(_makeTestable(const Dock(), bloc: bloc));
      await tester.pumpAndSettle();

      expect(bloc.state.tags, isEmpty);

      await tester.tap(find.byType(AnimatedDockItem).first);
      await tester.pumpAndSettle();

      expect(bloc.state.tags, isNotEmpty);
      expect(bloc.state.tags.first.identifier, WindowsTagsIdentifiers.aboutMe);
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
