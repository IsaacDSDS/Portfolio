import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/models/ui/window.dart';

part 'windows_event.dart';
part 'windows_state.dart';

class WindowsBloc extends Bloc<WindowsEvent, WindowsState> {
  WindowsBloc() : super(const WindowsState(windows: [])) {
    on<WindowOpened>(openWindow);
    on<WindowClosed>(closeWindow);
    on<WindowFocused>(focusWindow);
  }

  Future<void> openWindow(
    WindowOpened event,
    Emitter<WindowsState> emit,
  ) async {
    if (state.windows.any((w) => w.tag == event.window.tag)) return;
    emit(
      state.copyWith(
        currentTag: event.window.tag,
        windows: [...state.windows, event.window],
      ),
    );
  }

  Future<void> closeWindow(
    WindowClosed event,
    Emitter<WindowsState> emit,
  ) async {
    final windows = state.windows.where((w) => w.tag != event.tag).toList();
    final currentTag = windows.isEmpty ? WindowTag.finder : windows.last.tag;
    emit(state.copyWith(windows: windows, currentTag: currentTag));
  }

  Future<void> focusWindow(
    WindowFocused event,
    Emitter<WindowsState> emit,
  ) async {
    final i = state.windows.indexWhere((w) => w.tag == event.tag);
    if (i < 0 || i == state.windows.length - 1) return;
    final windows = [...state.windows]
      ..removeAt(i)
      ..add(state.windows[i]);
    emit(state.copyWith(windows: windows, currentTag: event.tag));
  }
}
