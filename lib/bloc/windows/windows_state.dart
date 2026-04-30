part of 'windows_bloc.dart';

class WindowsState {
  final List<String> tags;
  const WindowsState(this.tags);
  WindowsState copyWith(List<String> tags) => WindowsState(tags);
}
