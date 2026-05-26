import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/notifications/notifications_bloc.dart';
import 'package:so_portfolio/models/ui/notifications.dart';
import 'package:so_portfolio/theme/theme_getter.dart';
import 'package:so_portfolio/utils/date_utils.dart';
import 'package:so_portfolio/widgets/separated_column.dart';
import 'package:so_portfolio/widgets/separated_row.dart';

const double notificationWidth = 350;

class DesktopNotification extends StatefulWidget {
  const DesktopNotification({super.key, required this.notification});

  final CustomNotification notification;

  @override
  State<DesktopNotification> createState() => _DesktopNotificationState();
}

class _DesktopNotificationState extends State<DesktopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(_controller);

    _timer = Timer(Duration(seconds: 7), () {
      _closeNotification();
    });

    _controller.forward();
  }

  String dateString(DateTime date) {
    final DateTime today = DateTime.now();
    if (DateTimeUtils.isSameLocalDay(date, today)) {
      final int differenceInSeconds = DateTimeUtils.differenceInSeconds(
        date,
        today,
      );
      if (differenceInSeconds <= 60) return "Now";
      final int differenceInMinutes = DateTimeUtils.differenceInMinutes(
        date,
        today,
      );
      if (differenceInMinutes <= 60) return "${differenceInMinutes}m ago";
      final int differenceInHours = DateTimeUtils.differenceInHours(
        date,
        today,
      );
      if (differenceInHours <= 24) return "${differenceInHours}h ago";
      return "Today";
    } else {
      return DateTimeUtils.formatDate(date.toLocal());
    }
  }

  _closeNotification() async {
    await _controller.reverse();
    if (!mounted) return;
    context.read<NotificationsBloc>().add(
      NotificationsRemove(tag: widget.notification.tag),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: notificationWidth,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.theme.appColors.windowBodyColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  spreadRadius: 10,
                  blurRadius: 50,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SeparatedRow(
              separatorBuilder: (context, index) => SizedBox(width: 10),
              children: [
                Image.asset(widget.notification.icon, width: 40, height: 40),
                Flexible(
                  child: SeparatedColumn(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    separatorBuilder: (context, index) => SizedBox(height: 5),
                    children: [
                      Text(
                        widget.notification.title,
                        style: TextStyle(
                          color: context.theme.appColors.headerTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.notification.message,
                        style: TextStyle(
                          color: context.theme.appColors.headerTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: _closeNotification,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.theme.appColors.windowBodyColor,
                  border: Border.all(
                    color: context.theme.appColors.headerTextColor.withValues(
                      alpha: 0.3,
                    ),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: context.theme.appColors.headerTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
