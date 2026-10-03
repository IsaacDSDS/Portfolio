import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/models/ui/tag.dart';

extension WindowsContext on BuildContext {
  /// Opens (or keeps open) the window identified by [tag].
  void openWindow(WindowTag tag) => read<WindowsBloc>().add(WindowOpened(tag));
}
