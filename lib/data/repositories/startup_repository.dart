import '../mock/mock_data.dart';
import '../models/user_model.dart';

// Firebase implementation: replace MockDB calls with Firestore
class StartupRepository {
  final MockDB _db = MockDB();

  Future<List<UserModel>> getOpenStudents({String? skillFilter, String? focusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var students = _db.getOpenStudents();

    if (skillFilter != null && skillFilter.isNotEmpty) {
      students = students
          .where((s) => s.skills.any((sk) => sk.toLowerCase().contains(skillFilter.toLowerCase())))
          .toList();
    }

    if (focusFilter != null && focusFilter != 'All') {
      students = students.where((s) => s.focusAreas.contains(focusFilter)).toList();
    }

    return students;
  }

  Future<Map<String, dynamic>> getDashboardStats(String startupId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final postings = _db.getOpportunitiesForStartup(startupId);
    final activeRoles = postings.where((p) => p.status.name == 'active').length;
    final totalApplications = postings.fold<int>(0, (sum, p) => sum + p.applicantCount);

    return {
      'activeRoles': activeRoles,
      'totalApplications': totalApplications,
      'avgTimeToHire': 14,
      'newApplicationsToday': 12,
    };
  }

  Future<List<Map<String, String>>> getRecentActivity(String startupId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {'name': 'Michael Adebayo', 'action': 'applied for Software Engineering', 'time': '2 hours ago'},
      {'name': 'Sarah Lim', 'action': 'scheduled an interview for UI/UX Design', 'time': '4 hours ago'},
      {'name': 'Kwame Asante', 'action': 'applied for Product Design Lead', 'time': '1 day ago'},
    ];
  }
}
