import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<List<UserModel>> getStartupsByStatus(String status) async {
    final snap = await _users
        .where('role', isEqualTo: 'startup')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return UserModel.fromMap(data);
    }).toList();
  }

  Future<void> approveStartup(UserModel startup) async {
    final notifId = _uuid.v4();
    final batch = _db.batch();

    batch.update(_users.doc(startup.id), {'status': 'approved'});

    batch.set(
      _db.collection('notifications').doc(notifId),
      NotificationModel(
        id: notifId,
        userId: startup.id,
        type: NotificationType.startupApproved,
        title: 'Your startup has been approved! 🎉',
        body:
            'ALU Career Development has verified ${startup.ventureName ?? 'your startup'}. Log in to set up your workspace.',
        isPriority: true,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    await batch.commit();
  }

  Future<void> rejectStartup(UserModel startup, String reason) async {
    final notifId = _uuid.v4();
    final batch = _db.batch();

    batch.update(_users.doc(startup.id), {'status': 'rejected'});

    batch.set(
      _db.collection('notifications').doc(notifId),
      NotificationModel(
        id: notifId,
        userId: startup.id,
        type: NotificationType.startupRejected,
        title: 'Startup verification update',
        body: reason.trim().isEmpty
            ? 'We could not verify your startup at this time. Please reply to our email for more information.'
            : reason.trim(),
        isPriority: true,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    await batch.commit();
  }
}
