import 'package:uuid/uuid.dart';
import '../mock/mock_data.dart';
import '../models/application_model.dart';
import '../models/invitation_model.dart';

// Firebase implementation: replace MockDB calls with Firestore
class InvitationRepository {
  final MockDB _db = MockDB();
  final _uuid = const Uuid();

  Future<InvitationModel> send({
    required String startupId,
    required String startupName,
    required String studentId,
    required String studentName,
    required String opportunityId,
    required String roleTitle,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final inv = InvitationModel(
      id: _uuid.v4(),
      startupId: startupId,
      startupName: startupName,
      studentId: studentId,
      studentName: studentName,
      opportunityId: opportunityId,
      roleTitle: roleTitle,
      message: message,
      createdAt: DateTime.now(),
    );
    _db.addInvitation(inv);
    return inv;
  }

  Future<List<InvitationModel>> getForStudent(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.getInvitationsForStudent(studentId);
  }

  Future<List<InvitationModel>> getForStartup(String startupId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.getInvitationsForStartup(startupId);
  }

  Future<InvitationModel> accept(String invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final inv = _db.findInvitation(invitationId);
    if (inv == null) throw Exception('Invitation not found');
    final updated = inv.copyWith(
      status: InvitationStatus.accepted,
      respondedAt: DateTime.now(),
    );
    _db.updateInvitation(updated);
    // Auto-create an application
    _db.addApplication(ApplicationModel(
      id: _uuid.v4(),
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
    ));
    return updated;
  }

  Future<InvitationModel> decline(String invitationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final inv = _db.findInvitation(invitationId);
    if (inv == null) throw Exception('Invitation not found');
    final updated = inv.copyWith(
      status: InvitationStatus.declined,
      respondedAt: DateTime.now(),
    );
    _db.updateInvitation(updated);
    return updated;
  }
}
