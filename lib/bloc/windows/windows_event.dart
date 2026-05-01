part of 'windows_bloc.dart';

sealed class WindowsEvent {}

class WindowOpened extends WindowsEvent {
  final Tag tag;
  WindowOpened(this.tag);
}

class WindowClosed extends WindowsEvent {
  final Tag tag;
  WindowClosed(this.tag);
}

class WindowFocused extends WindowsEvent {
  final Tag tag;
  WindowFocused(this.tag);
}
