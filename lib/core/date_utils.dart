import 'package:intl/intl.dart';

class AppDateUtils {
  static const _months = [
    "",
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  static const _days = [
    "",
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",
  ];

  static String formatTime(DateTime now) {
    final hour24 = now.hour;
    final minute = now.minute;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 < 12 ? 'AM' : 'PM';
    final hourStr = hour12 < 10 ? '0$hour12' : hour12.toString();
    final minuteStr = minute < 10 ? '0$minute' : minute.toString();
    return '$hourStr:$minuteStr $period';
  }

  static String formatDate(DateTime now) {
    final day = now.day;
    final month = now.month;
    final year = now.year;
    final dayName = _days[now.weekday].substring(0, 3);
    final monthName = _months[month].substring(0, 3);
    return '$dayName $day $monthName $year';
  }
}

class DateTimeUtils {
  static bool isSameLocalDay(DateTime date1, DateTime date2) {
    final DateTime dt1 = date1.toLocal();
    final DateTime dt2 = date2.toLocal();

    return dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day;
  }

  static String formatDate(DateTime date) {
    return DateFormat('MM/dd/yy').format(date);
  }

  static int differenceInSeconds(DateTime date1, DateTime date2) {
    return date1.difference(date2).inSeconds;
  }

  static int differenceInMinutes(DateTime date1, DateTime date2) {
    return date1.difference(date2).inMinutes;
  }

  static int differenceInHours(DateTime date1, DateTime date2) {
    return date1.difference(date2).inHours;
  }
}
