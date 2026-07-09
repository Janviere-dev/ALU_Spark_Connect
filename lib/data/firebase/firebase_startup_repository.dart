import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';
import '../models/user_model.dart';

class FirebaseStartupRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _opps =>
      _db.collection('opportunities');

  Future<List<UserModel>> getOpenStudents({
    String? skillFilter,
    String? focusFilter,
  }) async {
    Query<Map<String, dynamic>> q = _users
        .where('role', isEqualTo: 'student')
        .where('isOpenToOpportunities', isEqualTo: true);

    if (skillFilter != null && skillFilter.isNotEmpty) {
      q = q.where('skills', arrayContains: skillFilter);
    }
    if (focusFilter != null && focusFilter != 'All') {
      q = q.where('focusAreas', arrayContains: focusFilter);
    }

    final snap = await q.get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return UserModel.fromMap(data);
    }).toList();
  }

  Future<Map<String, dynamic>> getDashboardStats(String startupId) async {
    final snap = await _opps
        .where('startupId', isEqualTo: startupId)
        .get();

    final postings = snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return OpportunityModel.fromMap(data);
    }).toList();

    final activeRoles =
        postings.where((p) => p.status == OpportunityStatus.active).length;
    final totalApplications =
        postings.fold<int>(0, (acc, p) => acc + p.applicantCount);

    return {
      'activeRoles': activeRoles,
      'totalApplications': totalApplications,
      'avgTimeToHire': 14,
      'newApplicationsToday': 0,
      'postings': postings,
    };
  }
}
