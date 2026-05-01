import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/models/ui/tag.dart';

part 'windows_event.dart';
part 'windows_state.dart';

class WindowsBloc extends Bloc<WindowsEvent, WindowsState> {
  WindowsBloc() : super(const WindowsState(tags: [])) {
    on<WindowOpened>(openWindow);
    on<WindowClosed>(closeWindow);
    on<WindowFocused>(focusWindow);
  }

  Future<void> openWindow(
    WindowOpened event,
    Emitter<WindowsState> emit,
  ) async {
    if (state.tags.contains(event.tag)) return;
    emit(
      state.copyWith(currentTag: event.tag, tags: [...state.tags, event.tag]),
    );
  }

  Future<void> closeWindow(
    WindowClosed event,
    Emitter<WindowsState> emit,
  ) async {
    final tags = state.tags.where((t) => t != event.tag).toList();
    final currentTag = tags.isEmpty ? Tag.finder : tags.last;
    emit(state.copyWith(tags: tags, currentTag: currentTag));
  }

  Future<void> focusWindow(
    WindowFocused event,
    Emitter<WindowsState> emit,
  ) async {
    final i = state.tags.indexOf(event.tag);
    if (i < 0 || i == state.tags.length - 1) return;
    final tags = [...state.tags]
      ..remove(event.tag)
      ..add(event.tag);
    emit(state.copyWith(tags: tags, currentTag: event.tag));
  }
}
