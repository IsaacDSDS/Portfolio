import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/notifications/notifications_bloc.dart'
    show NotificationsBloc;
import 'package:so_portfolio/screens/screens.dart';
import 'package:so_portfolio/theme/theme_app.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';

void main() {
  runApp(const SoPortfolioApp());
}

class SoPortfolioApp extends StatelessWidget {
  const SoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Portfolio',
            themeMode: themeState.mode,
            theme: ThemeModeColors.light,
            darkTheme: ThemeModeColors.dark,
            debugShowCheckedModeBanner: false,
            home: MultiBlocProvider(
              providers: [BlocProvider(create: (_) => NotificationsBloc())],
              child: const BaseScreen(),
            ),
          );
        },
      ),
    );
  }
}
