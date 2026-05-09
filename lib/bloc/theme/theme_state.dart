part of 'theme_bloc.dart';

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);

  bool get isDark => mode == ThemeMode.dark;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState && runtimeType == other.runtimeType && mode == other.mode;

  @override
  int get hashCode => mode.hashCode;
}
