import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/features/desktop/desktop.dart';
import 'package:so_portfolio/features/desktop/window_catalog.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/models/ui/window.dart';

/// Counts how many window contents are rebuilt per action.
///
/// `DraggableMacWindow` calls `WindowDefinition.builder` on every build of the
/// window, so a counter in that builder equals "times this window was rebuilt".
/// Stress windows are registered in [windowCatalog] only for the test.
/// This measures rebuilds, not time: use `test/integration/` for timings.
const _screenSize = Size(1200, 800);

Widget _makeTestable(WindowsBloc bloc, {Size size = _screenSize}) {
  return MaterialApp(
    home: BlocProvider<WindowsBloc>.value(
      value: bloc,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: const Scaffold(body: Column(children: [DesktopBody()])),
      ),
    ),
  );
}

/// The test font is wider than the real one, so desktop labels overflow. That
/// is a font artifact; overflow reports are ignored.
void _ignoreOverflowErrors() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    original?.call(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

List<WindowTag> _registerStressWindows(int count, Map<String, int> builds) {
  final tags = <WindowTag>[];
  for (var i = 0; i < count; i++) {
    final id = 'stress_$i';
    final tag = WindowTag(identifier: id);
    windowCatalog[id] = WindowDefinition(
      tag: tag,
      title: 'Stress $i',
      icon: AppImages.aboutMe,
      dockColor: Colors.blue,
      builder: (_) {
        builds[id] = (builds[id] ?? 0) + 1;
        return const SizedBox(height: 100);
      },
    );
    tags.add(tag);
  }
  addTearDown(() {
    for (final tag in tags) {
      windowCatalog.remove(tag.identifier);
    }
  });
  return tags;
}

int _total(Map<String, int> builds) => builds.values.fold(0, (a, b) => a + b);

void main() {
  for (final n in [6, 30, 60]) {
    testWidgets('window rebuilds per action with $n windows open', (
      tester,
    ) async {
      _ignoreOverflowErrors();
      final builds = <String, int>{};
      // One extra, registered but not opened, to measure "open".
      final tags = _registerStressWindows(n + 1, builds);
      final open = tags.take(n).toList();
      final bloc = WindowsBloc();
      addTearDown(bloc.close);
      for (final tag in open) {
        bloc.add(WindowOpened(tag));
      }
      await tester.pumpWidget(_makeTestable(bloc));
      await tester.pumpAndSettle();

      final report = StringBuffer('[perf] n=$n');

      // Opening only builds the new window.
      builds.clear();
      bloc.add(WindowOpened(tags.last));
      await tester.pumpAndSettle();
      report.write(' | open: ${builds.length} windows rebuilt');
      expect(bloc.state.windows.length, n + 1);
      expect(builds.keys.toSet(), {tags.last.identifier});

      // Focusing reorders the windows without rebuilding any of them.
      builds.clear();
      bloc.add(WindowFocused(tags.first));
      await tester.pumpAndSettle();
      report.write(' | focus: ${builds.length} windows rebuilt');
      expect(bloc.state.windows.last, tags.first);
      expect(builds, isEmpty);

      // Closing does not rebuild the windows that stay open.
      builds.clear();
      bloc.add(WindowClosed(tags.last));
      await tester.pumpAndSettle();
      report.write(' | close: ${builds.length} windows rebuilt');
      expect(bloc.state.windows.length, n);
      expect(builds, isEmpty);

      // Drag the topmost window (`first` was just focused, so it is on top).
      builds.clear();
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Stress 0')),
      );
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      report.write(
        ' | drag: ${builds.length} windows rebuilt, '
        '${_total(builds)} builds in total',
      );
      // Moving a window must only rebuild that window.
      expect(builds.keys.toSet(), {'stress_0'});

      debugPrint(report.toString());
    });
  }

  testWidgets('open windows still rebuild when the screen size changes', (
    tester,
  ) async {
    _ignoreOverflowErrors();
    final builds = <String, int>{};
    final tags = _registerStressWindows(3, builds);
    final bloc = WindowsBloc();
    addTearDown(bloc.close);
    for (final tag in tags) {
      bloc.add(WindowOpened(tag));
    }
    await tester.pumpWidget(_makeTestable(bloc));
    await tester.pumpAndSettle();

    // Windows are cached by identity, so this guards against them going stale.
    builds.clear();
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_makeTestable(bloc, size: const Size(1400, 900)));
    await tester.pumpAndSettle();

    expect(builds.keys.toSet(), tags.map((t) => t.identifier).toSet());
  });
}
