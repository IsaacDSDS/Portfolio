part of 'windows_bloc.dart';

/// Open windows, in z-order (the last one is on top). Data only: what each
/// window looks like and shows is resolved by the UI from the window catalog.
class WindowsState extends Equatable {
  final List<WindowTag> windows;

  const WindowsState({this.windows = const []});

  /// The focused window: the top of the stack, or Finder when none is open.
  WindowTag get currentTag => windows.isEmpty ? WindowTag.finder : windows.last;

  WindowsState copyWith({List<WindowTag>? windows}) =>
      WindowsState(windows: windows ?? this.windows);

  @override
  List<Object?> get props => [windows];
}
