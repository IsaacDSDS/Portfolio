import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/models/ui/window.dart';

void main() {
  group('WindowsBloc', () {
    late WindowsBloc bloc;

    setUp(() {
      bloc = WindowsBloc();
    });

    tearDown(() {
      bloc.close();
    });

    group('openWindow', () {
      const aboutMeTag = WindowTag(identifier: 'about_me', title: 'About Me');
      const skillsTag = WindowTag(identifier: 'skills', title: 'Skills');
      final aboutMeWindow = WindowConfig(
        tag: aboutMeTag,
        child: const SizedBox(),
      );
      final skillsWindow = WindowConfig(
        tag: skillsTag,
        child: const SizedBox(),
      );

      blocTest<WindowsBloc, WindowsState>(
        'emits state with one window when opening first window',
        build: () => bloc,
        act: (b) => b.add(WindowOpened(aboutMeWindow)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [aboutMeTag])
              .having((s) => s.currentTag, 'currentTag', aboutMeTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'emits state with two windows when opening second window',
        build: () => bloc,
        act: (b) {
          b.add(WindowOpened(aboutMeWindow));
          b.add(WindowOpened(skillsWindow));
        },
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [aboutMeTag])
              .having((s) => s.currentTag, 'currentTag', aboutMeTag),
          isA<WindowsState>()
              .having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [aboutMeTag, skillsTag])
              .having((s) => s.currentTag, 'currentTag', skillsTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when opening an already open window',
        build: () => bloc,
        seed: () => WindowsState(windows: [aboutMeWindow], currentTag: aboutMeTag),
        act: (b) => b.add(WindowOpened(aboutMeWindow)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'updates currentTag to the newly opened window',
        build: () => bloc,
        seed: () => WindowsState(windows: [aboutMeWindow], currentTag: aboutMeTag),
        act: (b) => b.add(WindowOpened(skillsWindow)),
        expect: () => [
          isA<WindowsState>().having(
            (s) => s.currentTag,
            'currentTag',
            skillsTag,
          ),
        ],
      );
    });

    group('closeWindow', () {
      const aboutMeTag = WindowTag(identifier: 'about_me', title: 'About Me');
      const skillsTag = WindowTag(identifier: 'skills', title: 'Skills');
      const projectsTag = WindowTag(identifier: 'projects', title: 'Projects');
      final aboutMeWindow = WindowConfig(
        tag: aboutMeTag,
        child: const SizedBox(),
      );
      final skillsWindow = WindowConfig(
        tag: skillsTag,
        child: const SizedBox(),
      );
      final projectsWindow = WindowConfig(
        tag: projectsTag,
        child: const SizedBox(),
      );

      blocTest<WindowsBloc, WindowsState>(
        'resets to Finder when closing the only open window',
        build: () => bloc,
        seed: () => WindowsState(windows: [aboutMeWindow], currentTag: aboutMeTag),
        act: (b) => b.add(WindowClosed(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.windows, 'windows', [])
              .having((s) => s.currentTag, 'currentTag', WindowTag.finder),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'Close window and focues the last window',
        build: () => bloc,
        seed: () =>
            WindowsState(windows: [aboutMeWindow, skillsWindow], currentTag: aboutMeTag),
        act: (b) => b.add(WindowClosed(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [skillsTag])
              .having((s) => s.currentTag, 'currentTag', skillsTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'Close an inexistent window',
        build: () => bloc,
        seed: () =>
            WindowsState(windows: [aboutMeWindow, skillsWindow], currentTag: aboutMeTag),
        act: (b) => b.add(WindowClosed(projectsTag)),
        expect: () => [
          isA<WindowsState>().having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [
            aboutMeTag,
            skillsTag,
          ]),
        ],
      );

      blocTest(
        'Close the last focused window',
        build: () => bloc,
        seed: () => WindowsState(
          windows: [aboutMeWindow, skillsWindow, projectsWindow],
          currentTag: aboutMeTag,
        ),
        act: (b) {
          b.add(WindowClosed(aboutMeTag));
        },
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [skillsTag, projectsTag])
              .having((s) => s.currentTag, 'currentTag', projectsTag),
        ],
      );
    });

    group('focusWindow', () {
      const aboutMeTag = WindowTag(identifier: 'about_me', title: 'About Me');
      const skillsTag = WindowTag(identifier: 'skills', title: 'Skills');
      const projectsTag = WindowTag(identifier: 'projects', title: 'Projects');
      final aboutMeWindow = WindowConfig(
        tag: aboutMeTag,
        child: const SizedBox(),
      );
      final skillsWindow = WindowConfig(
        tag: skillsTag,
        child: const SizedBox(),
      );
      final projectsWindow = WindowConfig(
        tag: projectsTag,
        child: const SizedBox(),
      );

      blocTest<WindowsBloc, WindowsState>(
        'moves window to top of z-order when focusing a non-top window',
        build: () => bloc,
        seed: () => WindowsState(
          windows: [aboutMeWindow, skillsWindow, projectsWindow],
          currentTag: projectsTag,
        ),
        act: (b) => b.add(WindowFocused(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.windows.map((w) => w.tag).toList(), 'tags', [
                skillsTag,
                projectsTag,
                aboutMeTag,
              ])
              .having((s) => s.currentTag, 'currentTag', aboutMeTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing the already top window',
        build: () => bloc,
        seed: () => WindowsState(
          windows: [aboutMeWindow, skillsWindow, projectsWindow],
          currentTag: projectsTag,
        ),
        act: (b) => b.add(WindowFocused(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing a window that does not exist',
        build: () => bloc,
        seed: () =>
            WindowsState(windows: [aboutMeWindow, skillsWindow], currentTag: skillsTag),
        act: (b) => b.add(WindowFocused(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing with empty windows list',
        build: () => bloc,
        seed: () => const WindowsState(windows: []),
        act: (b) => b.add(WindowFocused(aboutMeTag)),
        expect: () => <WindowsState>[],
      );
    });
  });
}
