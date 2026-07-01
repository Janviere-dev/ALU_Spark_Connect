import '../mock/mock_data.dart';
import '../models/notification_model.dart';

// Firebase implementation: replace MockDB calls with Firestore subcollection
class NotificationRepository {
  final MockDB _db = MockDB();

  Future<List<NotificationModel>> getForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final list = _db.getNotificationsForUser(userId);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<int> getUnreadCount(String userId) async {
    final list = await getForUser(userId);
    return list.where((n) => !n.isRead).length;
  }

  Future<void> markAllRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.markAllNotificationsRead(userId);
  }
}
