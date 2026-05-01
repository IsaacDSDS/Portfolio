import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/screens/desktop/desktop.dart';
import 'package:so_portfolio/screens/mobile/mobile.dart';
import 'package:so_portfolio/screens/tablet/tablet.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    if (size.width > 1025) {
      return BlocProvider(create: (_) => WindowsBloc(), child: DesktopScreen());
    }
    if (size.width > 787 && size.width <= 1024) {
      return const TabletScreen();
    }
    if (size.width <= 787) {
      return const MobileScreen();
    }
    return SizedBox();
  }
}
