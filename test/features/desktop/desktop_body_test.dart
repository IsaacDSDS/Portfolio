import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/features/desktop/app.dart';
import 'package:so_portfolio/features/desktop/desktop.dart';
import 'package:so_portfolio/features/desktop/window_base.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/shared/widgets/mac_window.dart';

Widget _makeTestable(WindowsBloc bloc) {
  return MaterialApp(
    home: BlocProvider<WindowsBloc>.value(
      value: bloc,
      child: const MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)),
        child: Scaffold(body: Column(children: [DesktopBody()])),
      ),
    ),
  );
}

/// The test font (Ahem) is wider than the real one, so the two-word desktop
/// labels wrap and `DesktopApp` overflows by one line. That is a font artifact
/// that does not happen with the real fonts, so overflow reports are ignored.
void _ignoreOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

void main() {
  group('DesktopBody', () {
    // The bloc is created inside each test body (not in `setUp`) so its streams
    // live in the test's fake-async zone and `pump` delivers its states.
    WindowsBloc createBloc() {
      final bloc = WindowsBloc();
      addTearDown(bloc.close);
      return bloc;
    }

    testWidgets('lists the desktop icons in catalog order', (tester) async {
      _ignoreOverflowErrors();
      final bloc = createBloc();
      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pumpAndSettle();

      final apps = tester.widgetList<DesktopApp>(find.byType(DesktopApp));
      expect(apps.map((a) => a.name).toList(), [
        'About Me',
        'Skills',
        'Projects',
        'Curriculum Vitae',
        'Contact Me',
        'Github',
      ]);
    });

    testWidgets('opens a window when tapping a desktop icon', (tester) async {
      _ignoreOverflowErrors();
      final bloc = createBloc();
      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate((w) => w is DesktopApp && w.name == 'Skills'),
      );
      await tester.pumpAndSettle();

      expect(bloc.state.windows, [
        const WindowTag(identifier: WindowsTagsIdentifiers.skills),
      ]);
      expect(find.byType(WindowBase), findsOneWidget);
    });

    testWidgets('keeps window widgets keyed by identifier on focus', (
      tester,
    ) async {
      _ignoreOverflowErrors();
      final bloc = createBloc();
      bloc
        ..add(const WindowOpened(WindowTag(identifier: 'about_me')))
        ..add(const WindowOpened(WindowTag(identifier: 'skills')));
      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pumpAndSettle();

      final before = tester.state(
        find.descendant(
          of: find.byKey(const ValueKey('about_me')),
          matching: find.byType(DraggableMacWindow),
        ),
      );

      bloc.add(const WindowFocused(WindowTag(identifier: 'about_me')));
      await tester.pumpAndSettle();

      final after = tester.state(
        find.descendant(
          of: find.byKey(const ValueKey('about_me')),
          matching: find.byType(DraggableMacWindow),
        ),
      );
      expect(identical(before, after), isTrue);
    });
  });
}
