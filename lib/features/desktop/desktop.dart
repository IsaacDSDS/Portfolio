import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/notifications/notifications_bloc.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/notifications.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/features/desktop/app.dart';
import 'package:so_portfolio/features/desktop/dock.dart';
import 'package:so_portfolio/features/desktop/notifications.dart';
import 'package:so_portfolio/features/desktop/top_bar.dart';
import 'package:so_portfolio/features/desktop/window_base.dart';
import 'package:so_portfolio/features/desktop/window_catalog.dart';
import 'package:so_portfolio/features/desktop/window_extensions.dart';
import 'package:so_portfolio/shared/widgets/separated_column.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.watch<ThemeBloc>();
    final isDark = themeBloc.state.isDark;

    return Scaffold(
      body: BlocBuilder<WindowsBloc, WindowsState>(
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/backgrounds/light_desktop.jpg',
                      fit: BoxFit.cover,
                    ),
                    AnimatedOpacity(
                      opacity: isDark ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Image.asset(
                        'assets/backgrounds/dark_desktop.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Column(
                  children: [
                    TopBar(),
                    DesktopBody(),
                    Dock(),
                    SizedBox(height: 10),
                  ],
                ),
              ),

              NotificationContainer(),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return FloatingActionButton(
            onPressed: () => themeBloc.add(ThemeToggled()),
            child: Icon(themeState.isDark ? Icons.light_mode : Icons.dark_mode),
          );
        },
      ),
    );
  }
}

class DesktopBody extends StatelessWidget {
  const DesktopBody({super.key});

  @override
  Widget build(BuildContext context) {
    final WindowsBloc windowsBloc = context.watch<WindowsBloc>();
    final state = windowsBloc.state;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    textDirection: TextDirection.rtl,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final identifier in desktopOrder)
                        DesktopApp(
                          icon: windowCatalog[identifier]!.icon,
                          name: windowCatalog[identifier]!.title,
                          onTap: () =>
                              context.openWindow(windowCatalog[identifier]!.tag),
                        ),
                    ],
                  ),
                ),
              ),
              for (final tag in state.windows)
                WindowBase(
                  key: ValueKey(tag.identifier),
                  tag: tag,
                  onClose: () => windowsBloc.add(WindowClosed(tag)),
                  onTap: () => windowsBloc.add(WindowFocused(tag)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class NotificationContainer extends StatefulWidget {
  const NotificationContainer({super.key});

  @override
  State<NotificationContainer> createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInitNotification();
    });
  }

  void _showInitNotification() {
    if (!mounted) return;
    context.read<NotificationsBloc>().add(
      NotificationsAdd(
        notification: CustomNotification(
          tag: NotificationTag(identifier: NotificationIdentifiers.init),
          title: "You're looking at a Flutter app",
          message:
              "This entire macOS desktop â€” dock, windows, drag & resize â€” is built with Flutter. Open a window to start.",
          dateTime: DateTime.now(),
          icon: AppImages.aboutMe,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context
        .select<NotificationsBloc, List<CustomNotification>>(
          (value) => value.state.notifications,
        );

    return Positioned(
      top: 10,
      right: 10,
      child: SeparatedColumn(
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        },
        children: notifications
            .map(
              (e) => DesktopNotification(
                key: ValueKey(e.tag.identifier),
                notification: e,
              ),
            )
            .toList(),
      ),
    );
  }
}
