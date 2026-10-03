import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/models/ui/tag.dart';

const aboutMeTag = WindowTag(identifier: 'about_me');
const skillsTag = WindowTag(identifier: 'skills');
const projectsTag = WindowTag(identifier: 'projects');

void main() {
  group('WindowsState', () {
    test('is equal by value', () {
      expect(
        const WindowsState(windows: [aboutMeTag, skillsTag]),
        const WindowsState(windows: [aboutMeTag, skillsTag]),
      );
      expect(
        const WindowsState(windows: [aboutMeTag, skillsTag]).hashCode,
        const WindowsState(windows: [aboutMeTag, skillsTag]).hashCode,
      );
    });

    test('is not equal when windows differ or are in a different order', () {
      expect(
        const WindowsState(windows: [aboutMeTag]),
        isNot(const WindowsState(windows: [skillsTag])),
      );
      expect(
        const WindowsState(windows: [aboutMeTag, skillsTag]),
        isNot(const WindowsState(windows: [skillsTag, aboutMeTag])),
      );
    });

    test('currentTag is finder when there are no windows', () {
      expect(const WindowsState().currentTag, WindowTag.finder);
    });

    test('currentTag is the last window of the list', () {
      expect(
        const WindowsState(windows: [aboutMeTag, skillsTag]).currentTag,
        skillsTag,
      );
    });

    test('copyWith replaces windows and keeps them when omitted', () {
      const state = WindowsState(windows: [aboutMeTag]);
      expect(
        state.copyWith(windows: const [skillsTag]),
        const WindowsState(windows: [skillsTag]),
      );
      expect(state.copyWith(), state);
    });
  });

  group('WindowsEvent', () {
    test('events are equal by value and tag', () {
      expect(const WindowOpened(aboutMeTag), const WindowOpened(aboutMeTag));
      expect(const WindowClosed(aboutMeTag), const WindowClosed(aboutMeTag));
      expect(const WindowFocused(aboutMeTag), const WindowFocused(aboutMeTag));
      expect(
        const WindowOpened(aboutMeTag),
        isNot(const WindowOpened(skillsTag)),
      );
    });

    test('different event types with the same tag are not equal', () {
      expect(
        const WindowOpened(aboutMeTag),
        isNot(const WindowClosed(aboutMeTag)),
      );
    });
  });

  group('WindowsBloc', () {
    test('initial state has no windows', () {
      final bloc = WindowsBloc();
      addTearDown(bloc.close);
      expect(bloc.state, const WindowsState());
    });

    group('openWindow', () {
      blocTest<WindowsBloc, WindowsState>(
        'emits state with one window when opening first window',
        build: WindowsBloc.new,
        act: (b) => b.add(const WindowOpened(aboutMeTag)),
        expect: () => [
          const WindowsState(windows: [aboutMeTag]),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'emits state with two windows when opening second window',
        build: WindowsBloc.new,
        act: (b) {
          b.add(const WindowOpened(aboutMeTag));
          b.add(const WindowOpened(skillsTag));
        },
        expect: () => [
          const WindowsState(windows: [aboutMeTag]),
          const WindowsState(windows: [aboutMeTag, skillsTag]),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when opening an already open window',
        build: WindowsBloc.new,
        seed: () => const WindowsState(windows: [aboutMeTag]),
        act: (b) => b.add(const WindowOpened(aboutMeTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'the newly opened window becomes the current one',
        build: WindowsBloc.new,
        seed: () => const WindowsState(windows: [aboutMeTag]),
        act: (b) => b.add(const WindowOpened(skillsTag)),
        expect: () => [
          const WindowsState(windows: [aboutMeTag, skillsTag]),
        ],
        verify: (b) => expect(b.state.currentTag, skillsTag),
      );
    });

    group('closeWindow', () {
      blocTest<WindowsBloc, WindowsState>(
        'resets to Finder when closing the only open window',
        build: WindowsBloc.new,
        seed: () => const WindowsState(windows: [aboutMeTag]),
        act: (b) => b.add(const WindowClosed(aboutMeTag)),
        expect: () => [const WindowsState()],
        verify: (b) => expect(b.state.currentTag, WindowTag.finder),
      );

      blocTest<WindowsBloc, WindowsState>(
        'closes a window and focuses the last remaining one',
        build: WindowsBloc.new,
        seed: () => const WindowsState(windows: [aboutMeTag, skillsTag]),
        act: (b) => b.add(const WindowClosed(aboutMeTag)),
        expect: () => [
          const WindowsState(windows: [skillsTag]),
        ],
        verify: (b) => expect(b.state.currentTag, skillsTag),
      );

      // Bloc skips `emit` when the new state is equal to the current one, so
      // closing a window that is not open produces no emission at all.
      blocTest<WindowsBloc, WindowsState>(
        'does not emit when closing a window that is not open',
        build: WindowsBloc.new,
        seed: () => const WindowsState(windows: [aboutMeTag, skillsTag]),
        act: (b) => b.add(const WindowClosed(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'closing a window below the top keeps the top window focused',
        build: WindowsBloc.new,
        seed: () =>
            const WindowsState(windows: [aboutMeTag, skillsTag, projectsTag]),
        act: (b) => b.add(const WindowClosed(aboutMeTag)),
        expect: () => [
          const WindowsState(windows: [skillsTag, projectsTag]),
        ],
        verify: (b) => expect(b.state.currentTag, projectsTag),
      );
    });

    group('focusWindow', () {
      blocTest<WindowsBloc, WindowsState>(
        'moves window to top of z-order when focusing a non-top window',
        build: WindowsBloc.new,
        seed: () =>
            const WindowsState(windows: [aboutMeTag, skillsTag, projectsTag]),
        act: (b) => b.add(const WindowFocused(aboutMeTag)),
        expect: () => [
          const WindowsState(windows: [skillsTag, projectsTag, aboutMeTag]),
        ],
        verify: (b) => expect(b.state.currentTag, aboutMeTag),
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing the already top window',
        build: WindowsBloc.new,
        seed: () =>
            const WindowsState(windows: [aboutMeTag, skillsTag, projectsTag]),
        act: (b) => b.add(const WindowFocused(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing a window that does not exist',
        build: WindowsBloc.new,
        seed: () => const WindowsState(windows: [aboutMeTag, skillsTag]),
        act: (b) => b.add(const WindowFocused(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing with empty windows list',
        build: WindowsBloc.new,
        act: (b) => b.add(const WindowFocused(aboutMeTag)),
        expect: () => <WindowsState>[],
      );
    });
  });
}
