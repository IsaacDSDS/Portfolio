part of 'windows_bloc.dart';

class WindowsState {
  final List<Tag> tags;
  final Tag? currentTag;
  const WindowsState({this.currentTag, this.tags = const []});
  WindowsState copyWith({Tag? currentTag, List<Tag>? tags}) => WindowsState(
    currentTag: currentTag ?? this.currentTag,
    tags: tags ?? this.tags,
  );
}
