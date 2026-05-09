import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/date_utils.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/screens/desktop/widgets/top_bar.dart';

Widget _makeTestable(Widget child, {WindowsBloc? bloc}) {
  return MaterialApp(
    home: BlocProvider<WindowsBloc>(
      create: (_) => bloc ?? WindowsBloc(),
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 800)),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('TopBar', () {
    testWidgets('renders apple icon', (tester) async {
      await tester.pumpWidget(_makeTestable(const TopBar()));
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('shows Finder when no windows are open', (tester) async {
      await tester.pumpWidget(_makeTestable(const TopBar()));
      expect(find.text('Finder'), findsOneWidget);
    });

    testWidgets('shows window title when a window is open', (tester) async {
      final bloc = WindowsBloc()
        ..add(
          WindowOpened(const Tag(identifier: 'about_me', title: 'About Me')),
        );

      await tester.pumpWidget(_makeTestable(const TopBar(), bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('About Me'), findsOneWidget);
      expect(find.text('Finder'), findsNothing);
    });

    testWidgets('shows formatted date and time', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(_makeTestable(const TopBar()));

      expect(find.textContaining(AppDateUtils.formatTime(now)), findsOneWidget);
    });

    testWidgets('shows most recently opened window title', (tester) async {
      final bloc = WindowsBloc()
        ..add(
          WindowOpened(const Tag(identifier: 'about_me', title: 'About Me')),
        )
        ..add(
          WindowOpened(const Tag(identifier: 'skills', title: 'Skills')),
        );

      await tester.pumpWidget(_makeTestable(const TopBar(), bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('Skills'), findsOneWidget);
    });
  });
}
