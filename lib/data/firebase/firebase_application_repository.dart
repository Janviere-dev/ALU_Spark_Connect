import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/application_model.dart';

class FirebaseApplicationRepository {
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

  Future<List<ApplicationModel>> getForOpportunity(
      String opportunityId) async {
    final snap = await _apps
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .get();
    return _fromSnap(snap);
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
  }) async {
    final alreadyApplied = await hasApplied(studentId, opportunityId);
    if (alreadyApplied) {
      throw Exception('You have already applied for this role.');
    }

    final id = _uuid.v4();
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
      status: ApplicationStatus.submitted,
      matchScore: 70 + (studentSkills.length * 5).clamp(0, 25),
      studentSkills: studentSkills,
      appliedAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(_apps.doc(id), app.toMap());
    batch.update(
      _db.collection('opportunities').doc(opportunityId),
      {'applicantCount': FieldValue.increment(1)},
    );
    await batch.commit();
    return app;
  }

  Future<void> updateStatus(
      String applicationId, ApplicationStatus status) async {
    await _apps.doc(applicationId).update({'status': status.name});
  }

  List<ApplicationModel> _fromSnap(
      QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return ApplicationModel.fromMap(data);
    }).toList();
  }
}
