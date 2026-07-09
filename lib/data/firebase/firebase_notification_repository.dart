import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class FirebaseNotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

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

  Future<void> add(NotificationModel notif) async {
    final id = notif.id.isEmpty ? _uuid.v4() : notif.id;
    await _notifs.doc(id).set({...notif.toMap(), 'id': id});
  }
}
