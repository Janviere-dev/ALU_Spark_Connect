import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class BookmarkRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<Map<String, List<String>>> load(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return {'opportunities': [], 'students': []};
    final data = doc.data()!;
    return {
      'opportunities':
          List<String>.from(data['savedOpportunityIds'] as List? ?? []),
      'students': List<String>.from(data['savedStudentIds'] as List? ?? []),
    };
  }

  Future<void> toggleOpportunity(String userId, String opportunityId,
      {required bool isSaved}) async {
    await _users.doc(userId).update({
      'savedOpportunityIds': isSaved
          ? FieldValue.arrayRemove([opportunityId])
          : FieldValue.arrayUnion([opportunityId]),
    });
  }

  Future<void> toggleStudent(String userId, String studentId,
      {required bool isSaved}) async {
    await _users.doc(userId).update({
      'savedStudentIds': isSaved
          ? FieldValue.arrayRemove([studentId])
          : FieldValue.arrayUnion([studentId]),
    });
  }

  Future<List<OpportunityModel>> getSavedOpportunities(
      List<String> ids) async {
    if (ids.isEmpty) return [];
    final result = <OpportunityModel>[];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, (i + 10).clamp(0, ids.length));
      final snap = await _db
          .collection('opportunities')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        result.add(OpportunityModel.fromMap(data));
      }
    }
    return result;
  }
}
