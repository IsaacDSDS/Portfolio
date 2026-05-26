import 'package:so_portfolio/models/ui/tag.dart';

class CustomNotification {
  final NotificationTag tag;
  final String title;
  final String message;
  final DateTime dateTime;
  final String icon;
  final Function()? onTap;

  const CustomNotification({
    required this.tag,
    required this.title,
    required this.message,
    required this.dateTime,
    this.icon = '',
    this.onTap,
  });
}
