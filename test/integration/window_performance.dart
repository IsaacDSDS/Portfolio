import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/features/desktop/desktop.dart';
import 'package:so_portfolio/features/desktop/window_catalog.dart';
import 'package:so_portfolio/main.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/models/ui/window.dart';

/// Frame timings for window interactions with a growing number of windows.
///
/// Not picked up by `flutter test` on purpose (the file name does not end in
/// `_test.dart`): it needs a real browser and runs only through `flutter drive`.
/// Run it in profile mode (debug timings are meaningless), with chromedriver
/// matching the installed Chrome running on port 4444:
///
///   fvm flutter drive --driver=test/integration/driver.dart \
///     --target=test/integration/window_performance.dart \
///     --profile -d web-server --browser-name=chrome --no-headless \
///     --browser-dimension=1440,900
///
/// The browser width must be above 1025 px, or the app shows the tablet or
/// mobile placeholder. Write a report in `reports/` after every run.
///
/// Results go to `build/integration_response_data.json`, one entry per
/// `<action>_<scenario>` key. The `warmup` scenario absorbs first-run shader
/// compilation and should be ignored.
///
/// Windows beyond the six real ones are stress windows registered in
/// [windowCatalog] only while the test runs.
const _extraWindows = 5;
const _realIdentifiers = [
  WindowsTagsIdentifiers.aboutMe,
  WindowsTagsIdentifiers.skills,
  WindowsTagsIdentifiers.projects,
  WindowsTagsIdentifiers.cv,
  WindowsTagsIdentifiers.contact,
  WindowsTagsIdentifiers.github,
];

/// Window size is the default of the window the app runs in.
const _frame = Duration(milliseconds: 16);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  const scenarios = [('warmup', 6), ('n06', 6), ('n30', 30), ('n60', 60)];
  for (final (name, baseCount) in scenarios) {
    testWidgets('window interactions with $baseCount windows ($name)', (
      tester,
    ) async {
      final stressTags = _registerStressWindows(
        baseCount - _realIdentifiers.length + _extraWindows,
      );
      addTearDown(() {
        for (final tag in stressTags) {
          windowCatalog.remove(tag.identifier);
        }
      });

      await tester.pumpWidget(const SoPortfolioApp());
      await _pumpFor(tester, const Duration(seconds: 2));

      final bloc = tester.element(find.byType(DesktopBody)).read<WindowsBloc>();
      final tags = [
        for (final id in _realIdentifiers) WindowTag(identifier: id),
        ...stressTags,
      ];
      final base = tags.take(baseCount).toList();
      final extra = tags.skip(baseCount).toList();

      // Setup, not measured.
      for (final tag in base) {
        bloc.add(WindowOpened(tag));
      }
      await _pumpFor(tester, const Duration(milliseconds: 800));

      Offset topLeftOf(WindowTag tag) =>
          tester.getTopLeft(find.byKey(ValueKey(tag.identifier)));

      // Drag the topmost window by its header for one second.
      await binding.watchPerformance(() async {
        final top = bloc.state.windows.last;
        await tester.timedDragFrom(
          topLeftOf(top) + const Offset(300, 20),
          const Offset(300, 120),
          const Duration(seconds: 1),
        );
        await _pumpFor(tester, const Duration(milliseconds: 300));
      }, reportKey: 'drag_$name');

      // Focus the window at the bottom of the z-order, 20 times.
      await binding.watchPerformance(() async {
        for (var i = 0; i < 20; i++) {
          bloc.add(WindowFocused(bloc.state.windows.first));
          await tester.pump(_frame);
          await tester.pump(_frame);
          await _pumpFor(tester, const Duration(milliseconds: 100));
        }
      }, reportKey: 'focus_$name');

      // Open a few more windows.
      await binding.watchPerformance(() async {
        for (final tag in extra) {
          bloc.add(WindowOpened(tag));
          await tester.pump(_frame);
          await _pumpFor(tester, const Duration(milliseconds: 400));
        }
      }, reportKey: 'open_$name');

      // Close them again with the red traffic light, as a user would.
      await binding.watchPerformance(() async {
        for (var i = 0; i < extra.length; i++) {
          final before = bloc.state.windows.length;
          final top = bloc.state.windows.last;
          await tester.tapAt(topLeftOf(top) + const Offset(19, 20));
          // The window animates out for 250 ms before the bloc removes it.
          final deadline = DateTime.now().add(const Duration(seconds: 3));
          while (bloc.state.windows.length == before &&
              DateTime.now().isBefore(deadline)) {
            await tester.pump(_frame);
          }
          expect(
            bloc.state.windows.length,
            before - 1,
            reason: 'closing ${top.identifier} did not remove it within 3 s',
          );
          await _pumpFor(tester, const Duration(milliseconds: 150));
        }
      }, reportKey: 'close_$name');

      expect(bloc.state.windows.length, baseCount);
    });
  }
}

List<WindowTag> _registerStressWindows(int count) {
  final tags = <WindowTag>[];
  for (var i = 0; i < count; i++) {
    final id = 'stress_$i';
    final tag = WindowTag(identifier: id);
    windowCatalog[id] = WindowDefinition(
      tag: tag,
      title: 'Stress $i',
      icon: AppImages.aboutMe,
      dockColor: Colors.blue,
      builder: (_) => const SizedBox(height: 100),
    );
    tags.add(tag);
  }
  return tags;
}

/// Pumps frames for [duration] of real time (the binding is fully live).
Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(_frame);
  }
}
