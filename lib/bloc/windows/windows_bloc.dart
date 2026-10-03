// `bloc` is a transitive dependency of `flutter_bloc`. It is imported directly
// (instead of `flutter_bloc`) so the windows BLoC does not depend on Flutter.
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:so_portfolio/models/ui/tag.dart';

part 'windows_event.dart';
part 'windows_state.dart';

class WindowsBloc extends Bloc<WindowsEvent, WindowsState> {
  WindowsBloc() : super(const WindowsState()) {
    on<WindowOpened>(_onWindowOpened);
    on<WindowClosed>(_onWindowClosed);
    on<WindowFocused>(_onWindowFocused);
  }

  void _onWindowOpened(WindowOpened event, Emitter<WindowsState> emit) {
    if (state.windows.contains(event.tag)) return;
    emit(state.copyWith(windows: [...state.windows, event.tag]));
  }

  void _onWindowClosed(WindowClosed event, Emitter<WindowsState> emit) {
    final windows = state.windows.where((tag) => tag != event.tag).toList();
    emit(state.copyWith(windows: windows));
  }

  void _onWindowFocused(WindowFocused event, Emitter<WindowsState> emit) {
    final i = state.windows.indexOf(event.tag);
    if (i < 0 || i == state.windows.length - 1) return;
    final windows = [...state.windows]
      ..removeAt(i)
      ..add(event.tag);
    emit(state.copyWith(windows: windows));
  }
}
