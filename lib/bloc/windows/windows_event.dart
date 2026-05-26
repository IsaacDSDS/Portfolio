part of 'windows_bloc.dart';

sealed class WindowsEvent {}

class WindowOpened extends WindowsEvent {
  final WindowConfig window;
  WindowOpened(this.window);
}

class WindowClosed extends WindowsEvent {
  final WindowTag tag;
  WindowClosed(this.tag);
}

class WindowFocused extends WindowsEvent {
  final WindowTag tag;
  WindowFocused(this.tag);
}
