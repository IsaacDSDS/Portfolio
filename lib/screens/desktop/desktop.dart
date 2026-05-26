import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/notifications/notifications_bloc.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/notifications.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/models/ui/window.dart';
import 'package:so_portfolio/screens/desktop/widgets/app.dart';
import 'package:so_portfolio/screens/desktop/widgets/dock.dart';
import 'package:so_portfolio/screens/desktop/widgets/notifications.dart';
import 'package:so_portfolio/screens/desktop/widgets/top_bar.dart';
import 'package:so_portfolio/screens/desktop/windows/about_me.dart';
import 'package:so_portfolio/screens/desktop/windows/window_base.dart';
import 'package:so_portfolio/widgets/separated_column.dart';

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

  void openWindow({
    required BuildContext context,
    required String identifier,
    required String title,
    required Widget child,
  }) {
    context.read<WindowsBloc>().add(
      WindowOpened(
        WindowConfig(
          tag: WindowTag(identifier: identifier, title: title),
          child: child,
        ),
      ),
    );
  }

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
                      DesktopApp(
                        icon: AppImages.aboutMe,
                        name: 'About Me',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.aboutMe,
                          title: 'About Me',
                          child: AboutMe(),
                        ),
                      ),
                      DesktopApp(
                        icon: AppImages.skills,
                        name: 'Skills',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.skills,
                          title: 'Skills',
                          child: Text('Skills'),
                        ),
                      ),
                      DesktopApp(
                        icon: AppImages.projects,
                        name: 'Projects',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.projects,
                          title: 'Projects',
                          child: Text('Projects'),
                        ),
                      ),
                      DesktopApp(
                        icon: AppImages.cv,
                        name: 'Curriculum Vitae',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.cv,
                          title: 'Curriculum Vitae',
                          child: Text('CV'),
                        ),
                      ),
                      DesktopApp(
                        icon: AppImages.contact,
                        name: 'Contact Me',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.contact,
                          title: 'Contact Me',
                          child: Text('Contact'),
                        ),
                      ),
                      DesktopApp(
                        icon: AppImages.github,
                        name: 'Github',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.github,
                          title: 'Github',
                          child: Text('Github'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final window in state.windows)
                WindowBase(
                  key: ValueKey(window.tag.identifier),
                  window: window,
                  onClose: () => windowsBloc.add(WindowClosed(window.tag)),
                  onTap: () => windowsBloc.add(WindowFocused(window.tag)),
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
              "This entire macOS desktop — dock, windows, drag & resize — is built with Flutter. Open a window to start.",
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
