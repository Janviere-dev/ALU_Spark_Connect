import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../models/opportunity_model.dart';

class OpportunityRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _opps =>
      _db.collection('opportunities');

  Future<List<OpportunityModel>> getAll({
    String? query,
    String? category,
  }) async {
    Query<Map<String, dynamic>> q = _opps
        .where('status', isEqualTo: 'active')
        .orderBy('postedAt', descending: true);

    if (category != null && category != 'All Opportunities') {
      q = _opps
          .where('status', isEqualTo: 'active')
          .where('category', isEqualTo: category)
          .orderBy('postedAt', descending: true);
    }

    final snap = await q.get();
    var results = snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return OpportunityModel.fromMap(data);
    }).where((o) => !o.isExpired).toList();

    if (query != null && query.isNotEmpty) {
      final ql = query.toLowerCase();
      results = results
          .where((o) =>
              o.roleTitle.toLowerCase().contains(ql) ||
              o.startupName.toLowerCase().contains(ql) ||
              o.skills.any((s) => s.toLowerCase().contains(ql)))
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

  Future<List<OpportunityModel>> getMatching({
    required List<String> skills,
    required List<String> focusAreas,
  }) async {
    final results = <String, OpportunityModel>{};

    if (skills.isNotEmpty) {
      final snap = await _opps
          .where('status', isEqualTo: 'active')
          .where('skills', arrayContainsAny: skills.take(10).toList())
          .orderBy('postedAt', descending: true)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        results[doc.id] = OpportunityModel.fromMap(data);
      }
    }

    for (final area in focusAreas.take(5)) {
      final snap = await _opps
          .where('status', isEqualTo: 'active')
          .where('category', isEqualTo: area)
          .orderBy('postedAt', descending: true)
          .limit(10)
          .get();
      for (final doc in snap.docs) {
        if (!results.containsKey(doc.id)) {
          final data = doc.data();
          data['id'] = doc.id;
          results[doc.id] = OpportunityModel.fromMap(data);
        }
      }
    }

    final list = results.values.where((o) => !o.isExpired).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return list;
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
    final now = DateTime.now();
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
      postedAt: now,
      deadline: opportunity.deadline,
    );

    final batch = _db.batch();
    batch.set(_opps.doc(id), withId.toMap());

    // Notify open students whose skills overlap with this opportunity
    if (opportunity.skills.isNotEmpty) {
      final studentsSnap = await _db
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('isOpenToOpportunities', isEqualTo: true)
          .get();

      for (final doc in studentsSnap.docs) {
        final studentSkills =
            List<String>.from(doc.data()['skills'] as List? ?? []);
        final hasMatch =
            opportunity.skills.any((s) => studentSkills.contains(s));
        if (!hasMatch) continue;
        final notifId = _uuid.v4();
        batch.set(
          _db.collection('notifications').doc(notifId),
          NotificationModel(
            id: notifId,
            userId: doc.id,
            type: NotificationType.newOpportunity,
            title: 'New role: ${opportunity.roleTitle}',
            body:
                '${opportunity.startupName} just posted a role that matches your skills.',
            isPriority: false,
            actionId: id,
            createdAt: now,
          ).toMap(),
        );
      }
    }

    await batch.commit();
    return withId;
  }

  Future<void> update(OpportunityModel opportunity) async {
    await _opps.doc(opportunity.id).update({
      'roleTitle': opportunity.roleTitle,
      'description': opportunity.description,
      'category': opportunity.category,
      'commitment': opportunity.commitment,
      'location': opportunity.location,
      'isRemoteFriendly': opportunity.isRemoteFriendly,
      'compensation': opportunity.compensation,
      'skills': opportunity.skills,
      'deadline': opportunity.deadline?.millisecondsSinceEpoch,
    });
  }

  Future<void> updateStatus(String id, OpportunityStatus status) async {
    await _opps.doc(id).update({'status': status.name});
  }
}
