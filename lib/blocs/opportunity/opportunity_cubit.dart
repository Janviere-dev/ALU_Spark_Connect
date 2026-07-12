import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/application_repository.dart';
import '../../data/repositories/opportunity_repository.dart';
import 'opportunity_state.dart';

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository _repo;
  final ApplicationRepository _appRepo;

  OpportunityCubit({
    required OpportunityRepository opportunityRepository,
    required ApplicationRepository applicationRepository,
  })  : _repo = opportunityRepository,
        _appRepo = applicationRepository,
        super(OpportunityInitial());

  Future<void> loadAll({List<String> userSkills = const []}) async {
    emit(OpportunityLoading());
    try {
      final all = await _repo.getAll();
      final featured = await _repo.getFeatured();
      final recommended = await _repo.getRecommended(userSkills);
      emit(OpportunityLoaded(
        opportunities: all,
        featured: featured,
        recommended: recommended,
      ));
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }

  Future<void> search(String query, {String category = 'All Opportunities'}) async {
    emit(OpportunityLoading());
    try {
      final results = await _repo.getAll(query: query, category: category);
      emit(OpportunityLoaded(
        opportunities: results,
        searchQuery: query,
        selectedCategory: category,
      ));
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }

  Future<void> loadMatching({
    required List<String> skills,
    required List<String> focusAreas,
  }) async {
    emit(OpportunityLoading());
    try {
      final opps = await _repo.getMatching(
          skills: skills, focusAreas: focusAreas);
      emit(OpportunityLoaded(opportunities: opps));
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }

  Future<void> loadForStartup(String startupId) async {
    emit(OpportunityLoading());
    try {
      final opps = await _repo.getForStartup(startupId);
      emit(OpportunityLoaded(opportunities: opps));
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }

  Future<void> loadDetail(String id, String studentId) async {
    emit(OpportunityLoading());
    try {
      final opp = await _repo.getById(id);
      if (opp == null) {
        emit(const OpportunityError('Opportunity not found.'));
        return;
      }
      final hasApplied = await _appRepo.hasApplied(studentId, id);
      emit(OpportunityDetailLoaded(opportunity: opp, hasApplied: hasApplied));
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }
}
