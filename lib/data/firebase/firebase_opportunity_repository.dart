import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/opportunity_model.dart';

class FirebaseOpportunityRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _opps =>
      _db.collection('opportunities');

  Future<List<OpportunityModel>> getAll({
    String? query,
    String? category,
  }) async {
    Query<Map<String, dynamic>> q = _opps
        .where('status', isNotEqualTo: 'closed')
        .orderBy('status')
        .orderBy('postedAt', descending: true);

    if (category != null && category != 'All Opportunities') {
      q = _opps
          .where('status', isNotEqualTo: 'closed')
          .where('category', isEqualTo: category)
          .orderBy('status')
          .orderBy('postedAt', descending: true);
    }

    final snap = await q.get();
    var results = snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return OpportunityModel.fromMap(data);
    }).toList();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where((o) =>
              o.roleTitle.toLowerCase().contains(q) ||
              o.startupName.toLowerCase().contains(q) ||
              o.skills.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }

    return results;
  }

  Future<OpportunityModel?> getById(String id) async {
    final doc = await _opps.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return OpportunityModel.fromMap(data);
  }

  Future<List<OpportunityModel>> getFeatured() async {
    final snap = await _opps
        .where('isFeatured', isEqualTo: true)
        .where('status', isEqualTo: 'active')
        .orderBy('postedAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return OpportunityModel.fromMap(data);
    }).toList();
  }

  Future<List<OpportunityModel>> getRecommended(List<String> skills) async {
    if (skills.isEmpty) return [];
    final snap = await _opps
        .where('status', isEqualTo: 'active')
        .where('skills', arrayContainsAny: skills.take(10).toList())
        .orderBy('postedAt', descending: true)
        .limit(5)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return OpportunityModel.fromMap(data);
    }).toList();
  }

  Future<List<OpportunityModel>> getForStartup(String startupId) async {
    final snap = await _opps
        .where('startupId', isEqualTo: startupId)
        .orderBy('postedAt', descending: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return OpportunityModel.fromMap(data);
    }).toList();
  }

  Future<OpportunityModel> post(OpportunityModel opportunity) async {
    final id = _uuid.v4();
    final withId = OpportunityModel(
      id: id,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      roleTitle: opportunity.roleTitle,
      category: opportunity.category,
      description: opportunity.description,
      whyJoinUs: opportunity.whyJoinUs,
      skills: opportunity.skills,
      commitment: opportunity.commitment,
      location: opportunity.location,
      duration: opportunity.duration,
      isRemoteFriendly: opportunity.isRemoteFriendly,
      equityOffered: opportunity.equityOffered,
      compensation: opportunity.compensation,
      status: OpportunityStatus.active,
      isFeatured: false,
      postedAt: DateTime.now(),
    );
    await _opps.doc(id).set(withId.toMap());
    return withId;
  }

  Future<void> updateStatus(String id, OpportunityStatus status) async {
    await _opps.doc(id).update({'status': status.name});
  }

  Future<void> incrementApplicantCount(String id) async {
    await _opps.doc(id).update({
      'applicantCount': FieldValue.increment(1),
    });
  }
}
