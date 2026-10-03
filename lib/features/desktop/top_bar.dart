import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/core/date_utils.dart';
import 'package:so_portfolio/theme/theme_getter.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = AppDateUtils.formatTime(_now);
    final dateStr = AppDateUtils.formatDate(_now);

    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<WindowsBloc, WindowsState>(
      builder: (context, state) {
        return Container(
          width: size.width,
          height: topBarHeight,
          decoration: BoxDecoration(
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 70,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.apple, color: context.theme.appColors.topBarTextColor),
              SizedBox(width: 10),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.currentTag?.title != null &&
                                state.currentTag!.title.isNotEmpty
                            ? state.currentTag!.title
                            : "Finder",
                        style: TextStyle(
                          color: context.theme.appColors.topBarTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "$dateStr  •  $timeStr",
                        style: TextStyle(
                          color: context.theme.appColors.topBarTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
