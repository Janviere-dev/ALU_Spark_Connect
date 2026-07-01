import 'package:uuid/uuid.dart';
import '../mock/mock_data.dart';
import '../models/application_model.dart';

// Firebase implementation: replace MockDB calls with Firestore
class ApplicationRepository {
  final MockDB _db = MockDB();
  final _uuid = const Uuid();

  Future<List<ApplicationModel>> getForStudent(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _db.getApplicationsForStudent(studentId);
  }

  Future<List<ApplicationModel>> getForOpportunity(String opportunityId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _db.getApplicationsForOpportunity(opportunityId);
  }

  Future<bool> hasApplied(String studentId, String opportunityId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.applications.any(
      (a) => a.studentId == studentId && a.opportunityId == opportunityId,
    );
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
    await Future.delayed(const Duration(milliseconds: 1000));

    final alreadyApplied = await hasApplied(studentId, opportunityId);
    if (alreadyApplied) throw Exception('You have already applied for this role.');

    final app = ApplicationModel(
      id: _uuid.v4(),
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

    _db.addApplication(app);
    return app;
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final app = _db.applications.firstWhere((a) => a.id == applicationId);
    _db.updateApplication(app.copyWith(status: status));
  }

  Future<List<ApplicationModel>> getOpenStudentApplications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final openStudents = _db.getOpenStudents().map((u) => u.id).toSet();
    return _db.applications.where((a) => openStudents.contains(a.studentId)).toList();
  }
}
