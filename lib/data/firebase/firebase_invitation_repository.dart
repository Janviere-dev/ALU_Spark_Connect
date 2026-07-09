import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/application_model.dart';
import '../models/invitation_model.dart';
import '../models/notification_model.dart';

class FirebaseInvitationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _db.collection('invitations');

  Future<InvitationModel> send({
    required String startupId,
    required String startupName,
    required String studentId,
    required String studentName,
    required String opportunityId,
    required String roleTitle,
    required String message,
  }) async {
    final id = _uuid.v4();
    final inv = InvitationModel(
      id: id,
      startupId: startupId,
      startupName: startupName,
      studentId: studentId,
      studentName: studentName,
      opportunityId: opportunityId,
      roleTitle: roleTitle,
      message: message,
      createdAt: DateTime.now(),
    );

    final notifId = _uuid.v4();
    final notif = NotificationModel(
      id: notifId,
      userId: studentId,
      type: NotificationType.interviewInvitation,
      title: 'Invitation from $startupName',
      body: 'You\'ve been invited to apply for $roleTitle.',
      isPriority: true,
      actionId: id,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(_invitations.doc(id), inv.toMap());
    batch.set(_db.collection('notifications').doc(notifId), notif.toMap());
    await batch.commit();
    return inv;
  }

  Future<List<InvitationModel>> getForStudent(String studentId) async {
    final snap = await _invitations
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();
    return _fromSnap(snap);
  }

  Future<List<InvitationModel>> getForStartup(String startupId) async {
    final snap = await _invitations
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .get();
    return _fromSnap(snap);
  }

  Future<InvitationModel> accept(String invitationId) async {
    final doc = await _invitations.doc(invitationId).get();
    if (!doc.exists) throw Exception('Invitation not found.');
    final data = doc.data()!..['id'] = invitationId;
    final inv = InvitationModel.fromMap(data);

    final updated = inv.copyWith(
      status: InvitationStatus.accepted,
      respondedAt: DateTime.now(),
    );

    final appId = _uuid.v4();
    final app = ApplicationModel(
      id: appId,
      studentId: inv.studentId,
      studentName: inv.studentName,
      studentEmail: '',
      opportunityId: inv.opportunityId,
      roleTitle: inv.roleTitle,
      startupName: inv.startupName,
      pitch: 'Accepted via invitation.',
      status: ApplicationStatus.interviewScheduled,
      matchScore: 95,
      appliedAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.update(_invitations.doc(invitationId), {
      'status': 'accepted',
      'respondedAt': updated.respondedAt!.millisecondsSinceEpoch,
    });
    batch.set(_db.collection('applications').doc(appId), app.toMap());
    batch.update(
      _db.collection('opportunities').doc(inv.opportunityId),
      {'applicantCount': FieldValue.increment(1)},
    );
    await batch.commit();
    return updated;
  }

  Future<InvitationModel> decline(String invitationId) async {
    final respondedAt = DateTime.now();
    await _invitations.doc(invitationId).update({
      'status': 'declined',
      'respondedAt': respondedAt.millisecondsSinceEpoch,
    });
    final doc = await _invitations.doc(invitationId).get();
    final data = doc.data()!..['id'] = invitationId;
    return InvitationModel.fromMap(data);
  }

  List<InvitationModel> _fromSnap(
      QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return InvitationModel.fromMap(data);
    }).toList();
  }
}
