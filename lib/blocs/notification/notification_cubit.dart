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

  Future<void> markRead(String userId, String notificationId) async {
    final current = state;
    if (current is NotificationsLoaded) {
      final updated = current.notifications
          .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
          .toList();
      final unread = updated.where((n) => !n.isRead).length;
      emit(NotificationsLoaded(notifications: updated, unreadCount: unread));
    }
    _repo.markRead(notificationId).ignore();
  }

  Future<void> markAllRead(String userId) async {
    await _repo.markAllRead(userId);
    await load(userId);
  }
}
