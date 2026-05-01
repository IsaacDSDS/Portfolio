import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/theme/theme_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/models/ui/tag.dart';
import 'package:so_portfolio/screens/desktop/widgets/app.dart';
import 'package:so_portfolio/screens/desktop/windows/window_base.dart';
import 'package:so_portfolio/screens/desktop/widgets/dock.dart';
import 'package:so_portfolio/screens/desktop/widgets/top_bar.dart';

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
  }) {
    context.read<WindowsBloc>().add(
      WindowOpened(Tag(identifier: identifier, name: title)),
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
                        icon: 'assets/icons/about_me.png',
                        name: 'About Me',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.aboutMe,
                          title: 'About Me',
                        ),
                      ),
                      DesktopApp(
                        icon: 'assets/icons/skills.png',
                        name: 'Skills',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.skills,
                          title: 'Skills',
                        ),
                      ),

                      DesktopApp(
                        icon: 'assets/icons/projects.png',
                        name: 'Projects',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.projects,
                          title: 'Projects',
                        ),
                      ),
                      DesktopApp(
                        icon: 'assets/icons/cv.png',
                        name: 'Curriculum Vitae',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.cv,
                          title: 'Curriculum Vitae',
                        ),
                      ),

                      DesktopApp(
                        icon: 'assets/icons/contact.png',
                        name: 'Contact Me',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.contact,
                          title: 'Contact Me',
                        ),
                      ),
                      DesktopApp(
                        icon: 'assets/icons/github.png',
                        name: 'Github',
                        onTap: () => openWindow(
                          context: context,
                          identifier: WindowsTagsIdentifiers.github,
                          title: 'Github',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final tag in state.tags)
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
