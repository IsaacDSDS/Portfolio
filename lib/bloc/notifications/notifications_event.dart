part of 'notifications_bloc.dart';

abstract class NotificationsEvent {}

class NotificationsAdd extends NotificationsEvent {
  final CustomNotification notification;

  NotificationsAdd({required this.notification});
}

class NotificationsRemove extends NotificationsEvent {
  final NotificationTag tag;

  NotificationsRemove({required this.tag});
}
