part of 'windows_bloc.dart';

class WindowsState {
  final List<WindowConfig> windows;
  final WindowTag? currentTag;
  const WindowsState({this.currentTag, this.windows = const []});
  WindowsState copyWith({
    WindowTag? currentTag,
    List<WindowConfig>? windows,
  }) => WindowsState(
    currentTag: currentTag ?? this.currentTag,
    windows: windows ?? this.windows,
  );
}
