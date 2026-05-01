import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:so_portfolio/bloc/windows/windows_bloc.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/theme/theme_getter.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour24 = now.hour;
    final minute = now.minute;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 < 12 ? 'AM' : 'PM';
    final hourStr = hour12 < 10 ? '0$hour12' : hour12.toString();
    final minuteStr = minute < 10 ? '0$minute' : minute.toString();

    final timeStr = '$hourStr:$minuteStr $period';
    final day = now.day;
    final month = now.month;
    final year = now.year;
    final months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    final days = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    String dateStr =
        "${days[now.weekday].substring(0, 3)} $day ${months[month].substring(0, 3)} $year";

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
                        state.currentTag?.name ?? "",
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
