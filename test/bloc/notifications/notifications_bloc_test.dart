import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:so_portfolio/bloc/notifications/notifications_bloc.dart';
import 'package:so_portfolio/models/ui/notifications.dart';
import 'package:so_portfolio/models/ui/tag.dart';

void main() {
  group("Notifications Bloc", () {
    late NotificationsBloc bloc;

    setUp(() {
      bloc = NotificationsBloc();
    });

    tearDown(() {
      bloc.close();
    });

    group(" Add Notifications ", () {
      final notification1 = CustomNotification(
        tag: NotificationTag(identifier: "test1"),
        title: "Test1",
        message: "Test1",
        dateTime: DateTime.now(),
        icon: "test1",
      );

      final notification2 = CustomNotification(
        tag: NotificationTag(identifier: "test2"),
        title: "Test2",
        message: "Test2",
        dateTime: DateTime.now(),
        icon: "test2",
      );

      blocTest(
        "Add 1 notification",
        build: () => bloc,
        act: (b) => b.add(NotificationsAdd(notification: notification1)),
        expect: () => [
          isA<NotificationsState>().having(
            (s) => s.notifications.map((e) => e.tag).toList(),
            "Notifications tags list",
            [notification1.tag],
          ),
        ],
      );

      blocTest(
        "Add 2 notification",
        build: () => bloc,
        act: (b) {
          b.add(NotificationsAdd(notification: notification1));
          b.add(NotificationsAdd(notification: notification2));
        },
        expect: () => [
          isA<NotificationsState>().having(
            (s) => s.notifications.map((e) => e.tag).toList(),
            "Notifications tags list",
            [notification1.tag],
          ),
          isA<NotificationsState>().having(
            (s) => s.notifications.map((e) => e.tag).toList(),
            "Notifications tags list",
            [notification1.tag, notification2.tag],
          ),
        ],
      );

      blocTest(
        "Add 1 duplicate notification",
        build: () => bloc,
        act: (b) {
          b.add(NotificationsAdd(notification: notification1));
          b.add(NotificationsAdd(notification: notification1));
        },
        expect: () => [
          isA<NotificationsState>().having(
            (s) => s.notifications.map((e) => e.tag).toList(),
            "Notifications tags list",
            [notification1.tag],
          ),
        ],
      );

      blocTest(
        "Does not emit when opening an already open notification",
        build: () => bloc,
        seed: () => NotificationsState(notifications: [notification1]),
        act: (b) {
          b.add(NotificationsAdd(notification: notification1));
        },
        expect: () => [],
      );
    });
  });
}
