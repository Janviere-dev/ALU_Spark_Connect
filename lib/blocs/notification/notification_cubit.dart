import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;

  NotificationCubit({required NotificationRepository notificationRepository})
      : _repo = notificationRepository,
        super(NotificationInitial());

  Future<void> load(String userId) async {
    emit(NotificationLoading());
    try {
      final notifications = await _repo.getForUser(userId);
      final unread = notifications.where((n) => !n.isRead).length;
      emit(NotificationsLoaded(notifications: notifications, unreadCount: unread));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAllRead(String userId) async {
    await _repo.markAllRead(userId);
    await load(userId);
  }
}
