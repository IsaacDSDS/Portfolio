import 'package:intl/intl.dart';

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
