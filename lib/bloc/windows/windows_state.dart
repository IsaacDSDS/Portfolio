part of 'windows_bloc.dart';

class WindowsState {
  final List<String> tags;
  final String currentTag;
  const WindowsState({this.currentTag = "", this.tags = const []});
  WindowsState copyWith({String? currentTag, List<String>? tags}) =>
      WindowsState(
        currentTag: currentTag ?? this.currentTag,
        tags: tags ?? this.tags,
      );
}
