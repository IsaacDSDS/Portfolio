import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:so_portfolio/models/ui/notifications.dart';
import 'package:so_portfolio/models/ui/tag.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsState()) {
    on<NotificationsAdd>(_onAdd);
    on<NotificationsRemove>(_onRemove);
  }

  void _onAdd(NotificationsAdd event, Emitter<NotificationsState> emit) {
    if (state.notifications.any(
      (notification) => notification.tag == event.notification.tag,
    )) {
      return;
    }

    emit(
      state.copyWith(
        notifications: [...state.notifications, event.notification],
      ),
    );
  }

  void _onRemove(NotificationsRemove event, Emitter<NotificationsState> emit) {
    emit(
      state.copyWith(
        notifications: state.notifications
            .where((notification) => notification.tag != event.tag)
            .toList(),
      ),
    );
  }
}
