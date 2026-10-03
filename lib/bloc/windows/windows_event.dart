part of 'windows_bloc.dart';

sealed class WindowsEvent extends Equatable {
  final WindowTag tag;

  const WindowsEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

class WindowOpened extends WindowsEvent {
  const WindowOpened(super.tag);
}

class WindowClosed extends WindowsEvent {
  const WindowClosed(super.tag);
}

class WindowFocused extends WindowsEvent {
  const WindowFocused(super.tag);
}
