import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/application_model.dart';
import '../models/notification_model.dart';

class ApplicationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _apps =>
      _db.collection('applications');

  Future<List<ApplicationModel>> getForStudent(String studentId) async {
    final snap = await _apps
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .get();
    return _fromSnap(snap);
  }

  Future<List<ApplicationModel>> getForOpportunity(String opportunityId) async {
    final snap = await _apps
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .get();
    return _fromSnap(snap);
  }

  Future<List<ApplicationModel>> getForStartup(String startupId) async {
    final oppSnap = await _db
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .get();
    if (oppSnap.docs.isEmpty) return [];

    final oppIds = oppSnap.docs.map((d) => d.id).toList();
    final result = <ApplicationModel>[];

    for (var i = 0; i < oppIds.length; i += 10) {
      final chunk = oppIds.sublist(i, i + 10 < oppIds.length ? i + 10 : oppIds.length);
      final appSnap = await _apps.where('opportunityId', whereIn: chunk).get();
      result.addAll(_fromSnap(appSnap));
    }

    result.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return result;
  }

  Future<bool> hasApplied(String studentId, String opportunityId) async {
    final snap = await _apps
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<ApplicationModel> submit({
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentUniversity,
    required String opportunityId,
    required String roleTitle,
    required String startupName,
    required String pitch,
    String? cvUrl,
    List<String> studentSkills = const [],
    List<String> opportunitySkills = const [],
  }) async {
    final alreadyApplied = await hasApplied(studentId, opportunityId);
    if (alreadyApplied) {
      throw Exception('You have already applied for this role.');
    }

    final oppDoc = await _db.collection('opportunities').doc(opportunityId).get();
    final oppData = oppDoc.data() ?? {};
    final startupId = oppData['startupId'] as String?;
    final opportunityDuration = oppData['duration'] as String?;

    final matchScore = opportunitySkills.isEmpty
        ? 0
        : (studentSkills.where(opportunitySkills.contains).length * 100 ~/
            opportunitySkills.length);

    final id = _uuid.v4();
    final now = DateTime.now();
    final app = ApplicationModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentUniversity: studentUniversity,
      opportunityId: opportunityId,
      roleTitle: roleTitle,
      startupName: startupName,
      pitch: pitch,
      cvUrl: cvUrl,
      duration: opportunityDuration,
      status: ApplicationStatus.submitted,
      matchScore: matchScore,
      studentSkills: studentSkills,
      appliedAt: now,
    );

    final batch = _db.batch();
    batch.set(_apps.doc(id), app.toMap());
    batch.update(
      _db.collection('opportunities').doc(opportunityId),
      {'applicantCount': FieldValue.increment(1)},
    );

    if (startupId != null) {
      final notifId = _uuid.v4();
      batch.set(
        _db.collection('notifications').doc(notifId),
        NotificationModel(
          id: notifId,
          userId: startupId,
          type: NotificationType.newApplication,
          title: 'New application: $roleTitle',
          body: '$studentName has applied for your $roleTitle role.',
          isPriority: true,
          actionId: opportunityId,
          createdAt: now,
        ).toMap(),
      );
    }

    await batch.commit();
    return app;
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    await _apps.doc(applicationId).update({'status': status.name});
  }

  Future<void> updateStatusWithNote({
    required String applicationId,
    required ApplicationStatus status,
    required String studentId,
    required String note,
    required String roleTitle,
  }) async {
    final now = DateTime.now();
    final notifId = _uuid.v4();

    final title = switch (status) {
      ApplicationStatus.shortlisted => 'You\'ve been shortlisted for $roleTitle!',
      ApplicationStatus.interviewScheduled => 'Interview scheduled: $roleTitle',
      ApplicationStatus.rejected => 'Application update: $roleTitle',
      ApplicationStatus.accepted => 'Offer received: $roleTitle!',
      _ => 'Application update: $roleTitle',
    };

    final batch = _db.batch();
    batch.update(_apps.doc(applicationId), {'status': status.name});
    batch.set(
      _db.collection('notifications').doc(notifId),
      NotificationModel(
        id: notifId,
        userId: studentId,
        type: NotificationType.applicationStatusChange,
        title: title,
        body: note,
        isPriority: status == ApplicationStatus.interviewScheduled ||
            status == ApplicationStatus.shortlisted,
        actionId: applicationId,
        createdAt: now,
      ).toMap(),
    );
    await batch.commit();
  }

  List<ApplicationModel> _fromSnap(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return ApplicationModel.fromMap(data);
    }).toList();
  }
}
