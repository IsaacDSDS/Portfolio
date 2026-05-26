part of 'notifications_bloc.dart';

@immutable
class NotificationsState {
  final List<CustomNotification> notifications;

  const NotificationsState({this.notifications = const []});

  NotificationsState copyWith({List<CustomNotification>? notifications}) =>
      NotificationsState(notifications: notifications ?? this.notifications);
}
