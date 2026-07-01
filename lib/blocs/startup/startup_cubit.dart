import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/repositories/opportunity_repository.dart';
import '../../data/repositories/startup_repository.dart';
import 'startup_state.dart';

class StartupCubit extends Cubit<StartupState> {
  final StartupRepository _startupRepo;
  final OpportunityRepository _oppRepo;

  StartupCubit({
    required StartupRepository startupRepository,
    required OpportunityRepository opportunityRepository,
  })  : _startupRepo = startupRepository,
        _oppRepo = opportunityRepository,
        super(StartupInitial());

  Future<void> loadDashboard(String startupId) async {
    emit(StartupLoading());
    try {
      final stats = await _startupRepo.getDashboardStats(startupId);
      final postings = await _oppRepo.getForStartup(startupId);
      final activity = await _startupRepo.getRecentActivity(startupId);
      emit(StartupDashboardLoaded(
        activeRoles: stats['activeRoles'] as int,
        totalApplications: stats['totalApplications'] as int,
        avgTimeToHire: stats['avgTimeToHire'] as int,
        newApplicationsToday: stats['newApplicationsToday'] as int,
        postings: postings,
        recentActivity: activity,
      ));
    } catch (e) {
      emit(StartupError(e.toString()));
    }
  }

  Future<void> loadTalent({String? skillFilter, String? focusFilter}) async {
    emit(StartupLoading());
    try {
      final students = await _startupRepo.getOpenStudents(
        skillFilter: skillFilter,
        focusFilter: focusFilter,
      );
      emit(TalentLoaded(
        students: students,
        skillFilter: skillFilter,
        focusFilter: focusFilter,
      ));
    } catch (e) {
      emit(StartupError(e.toString()));
    }
  }

  Future<void> postOpportunity(OpportunityModel opportunity) async {
    emit(StartupLoading());
    try {
      final posted = await _oppRepo.post(opportunity);
      emit(OpportunityPostSuccess(posted));
    } catch (e) {
      emit(StartupError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> togglePostingStatus(String oppId, OpportunityStatus current) async {
    final newStatus = current == OpportunityStatus.active
        ? OpportunityStatus.paused
        : OpportunityStatus.active;
    await _oppRepo.updateStatus(oppId, newStatus);
  }
}
