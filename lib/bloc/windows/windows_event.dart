part of 'windows_bloc.dart';

sealed class WindowsEvent {}

class WindowOpened extends WindowsEvent {
  final String tag;
  WindowOpened(this.tag);
}

class WindowClosed extends WindowsEvent {
  final String tag;
  WindowClosed(this.tag);
}

class WindowFocused extends WindowsEvent {
  final String tag;
  WindowFocused(this.tag);
}
