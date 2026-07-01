import 'package:uuid/uuid.dart';
import '../mock/mock_data.dart';
import '../models/opportunity_model.dart';

// Firebase implementation: replace MockDB calls with Firestore collection queries
class OpportunityRepository {
  final MockDB _db = MockDB();
  final _uuid = const Uuid();

  Future<List<OpportunityModel>> getAll({String? query, String? category}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var results = _db.opportunities.where((o) => o.status != OpportunityStatus.closed).toList();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where((o) =>
              o.roleTitle.toLowerCase().contains(q) ||
              o.startupName.toLowerCase().contains(q) ||
              o.skills.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }

    if (category != null && category != 'All Opportunities') {
      results = results.where((o) => o.category == category).toList();
    }

    results.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return results;
  }

  Future<OpportunityModel?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _db.opportunities.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<OpportunityModel>> getFeatured() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.opportunities.where((o) => o.isFeatured).toList();
  }

  Future<List<OpportunityModel>> getRecommended(List<String> skills) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.opportunities.where((o) {
      return o.status == OpportunityStatus.active &&
          o.skills.any((s) => skills.contains(s));
    }).take(5).toList();
  }

  Future<List<OpportunityModel>> getForStartup(String startupId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.getOpportunitiesForStartup(startupId);
  }

  Future<OpportunityModel> post(OpportunityModel opportunity) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final withId = OpportunityModel(
      id: _uuid.v4(),
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
    _db.addOpportunity(withId);
    return withId;
  }

  Future<void> updateStatus(String id, OpportunityStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final opp = _db.opportunities.firstWhere((o) => o.id == id);
    _db.updateOpportunity(opp.copyWith(status: status));
  }
}
