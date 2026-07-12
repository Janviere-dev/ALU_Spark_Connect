import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifs =>
      _db.collection('notifications');

  Future<List<NotificationModel>> getForUser(String userId) async {
    final snap = await _notifs
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return NotificationModel.fromMap(data);
    }).toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final snap = await _notifs
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> markRead(String notificationId) async {
    await _notifs.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _notifs
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
