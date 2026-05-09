import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/models/ui/tag.dart';

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
      const aboutMeTag = Tag(identifier: 'about_me', title: 'About Me');
      const skillsTag = Tag(identifier: 'skills', title: 'Skills');
      blocTest<WindowsBloc, WindowsState>(
        'emits state with one window when opening first window',
        build: () => bloc,
        act: (b) => b.add(WindowOpened(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [aboutMeTag])
              .having((s) => s.currentTag, 'currentTag', aboutMeTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'emits state with two windows when opening second window',
        build: () => bloc,
        act: (b) {
          b.add(WindowOpened(aboutMeTag));
          b.add(WindowOpened(skillsTag));
        },
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [aboutMeTag])
              .having((s) => s.currentTag, 'currentTag', aboutMeTag),
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [aboutMeTag, skillsTag])
              .having((s) => s.currentTag, 'currentTag', skillsTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when opening an already open window',
        build: () => bloc,
        seed: () => WindowsState(tags: [aboutMeTag], currentTag: aboutMeTag),
        act: (b) => b.add(WindowOpened(aboutMeTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'updates currentTag to the newly opened window',
        build: () => bloc,
        seed: () => WindowsState(tags: [aboutMeTag], currentTag: aboutMeTag),
        act: (b) => b.add(WindowOpened(skillsTag)),
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
      const aboutMeTag = Tag(identifier: 'about_me', title: 'About Me');
      const skillsTag = Tag(identifier: 'skills', title: 'Skills');
      const projectsTag = Tag(identifier: 'projects', title: 'Projects');

      blocTest<WindowsBloc, WindowsState>(
        'resets to Finder when closing the only open window',
        build: () => bloc,
        seed: () => WindowsState(tags: [aboutMeTag], currentTag: aboutMeTag),
        act: (b) => b.add(WindowClosed(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [])
              .having((s) => s.currentTag, 'currentTag', Tag.finder),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'Close window and focues the last window',
        build: () => bloc,
        seed: () =>
            WindowsState(tags: [aboutMeTag, skillsTag], currentTag: aboutMeTag),
        act: (b) => b.add(WindowClosed(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [skillsTag])
              .having((s) => s.currentTag, 'currentTag', skillsTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'Close an inexistent window',
        build: () => bloc,
        seed: () =>
            WindowsState(tags: [aboutMeTag, skillsTag], currentTag: aboutMeTag),
        act: (b) => b.add(WindowClosed(projectsTag)),
        expect: () => [
          isA<WindowsState>().having((s) => s.tags, 'tags', [
            aboutMeTag,
            skillsTag,
          ]),
        ],
      );

      blocTest(
        'Close the last focused window',
        build: () => bloc,
        seed: () => WindowsState(
          tags: [aboutMeTag, skillsTag, projectsTag],
          currentTag: aboutMeTag,
        ),
        act: (b) {
          b.add(WindowClosed(aboutMeTag));
        },
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [skillsTag, projectsTag])
              .having((s) => s.currentTag, 'currentTag', projectsTag),
        ],
      );
    });

    group('focusWindow', () {
      const aboutMeTag = Tag(identifier: 'about_me', title: 'About Me');
      const skillsTag = Tag(identifier: 'skills', title: 'Skills');
      const projectsTag = Tag(identifier: 'projects', title: 'Projects');

      blocTest<WindowsBloc, WindowsState>(
        'moves window to top of z-order when focusing a non-top window',
        build: () => bloc,
        seed: () => WindowsState(
          tags: [aboutMeTag, skillsTag, projectsTag],
          currentTag: projectsTag,
        ),
        act: (b) => b.add(WindowFocused(aboutMeTag)),
        expect: () => [
          isA<WindowsState>()
              .having((s) => s.tags, 'tags', [skillsTag, projectsTag, aboutMeTag])
              .having((s) => s.currentTag, 'currentTag', aboutMeTag),
        ],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing the already top window',
        build: () => bloc,
        seed: () => WindowsState(
          tags: [aboutMeTag, skillsTag, projectsTag],
          currentTag: projectsTag,
        ),
        act: (b) => b.add(WindowFocused(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing a window that does not exist',
        build: () => bloc,
        seed: () => WindowsState(
          tags: [aboutMeTag, skillsTag],
          currentTag: skillsTag,
        ),
        act: (b) => b.add(WindowFocused(projectsTag)),
        expect: () => <WindowsState>[],
      );

      blocTest<WindowsBloc, WindowsState>(
        'does not emit when focusing with empty tags list',
        build: () => bloc,
        seed: () => const WindowsState(tags: []),
        act: (b) => b.add(WindowFocused(aboutMeTag)),
        expect: () => <WindowsState>[],
      );
    });
  });
}
