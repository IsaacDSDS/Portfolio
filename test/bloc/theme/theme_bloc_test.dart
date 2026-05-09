import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';

void main() {
  group('ThemeBloc', () {
    late ThemeBloc bloc;

    setUp(() {
      bloc = ThemeBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('has initial state of light mode', () {
      expect(bloc.state.mode, ThemeMode.light);
      expect(bloc.state.isDark, isFalse);
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits dark mode when toggled from light',
      build: () => bloc,
      act: (b) => b.add(ThemeToggled()),
      expect: () => [const ThemeState(ThemeMode.dark)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits light mode when toggled from dark',
      build: () => bloc,
      seed: () => const ThemeState(ThemeMode.dark),
      act: (b) => b.add(ThemeToggled()),
      expect: () => [const ThemeState(ThemeMode.light)],
    );

    blocTest<ThemeBloc, ThemeState>(
      'toggles back and forth correctly',
      build: () => bloc,
      act: (b) {
        b.add(ThemeToggled());
        b.add(ThemeToggled());
        b.add(ThemeToggled());
        b.add(ThemeToggled());
      },
      expect: () => const [
        ThemeState(ThemeMode.dark),
        ThemeState(ThemeMode.light),
        ThemeState(ThemeMode.dark),
        ThemeState(ThemeMode.light),
      ],
    );
  });
}
