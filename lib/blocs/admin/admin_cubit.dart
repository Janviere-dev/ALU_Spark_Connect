import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repo;

  AdminCubit({required AdminRepository adminRepository})
      : _repo = adminRepository,
        super(AdminInitial());

  Future<void> loadAll() async {
    emit(AdminLoading());
    try {
      final results = await Future.wait([
        _repo.getStartupsByStatus('pending'),
        _repo.getStartupsByStatus('approved'),
        _repo.getStartupsByStatus('rejected'),
      ]);
      emit(AdminLoaded(
        pending: results[0],
        approved: results[1],
        rejected: results[2],
      ));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> approve(UserModel startup) async {
    try {
      await _repo.approveStartup(startup);
      emit(AdminActionSuccess('${startup.ventureName ?? 'Startup'} approved.'));
      await loadAll();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> reject(UserModel startup, String reason) async {
    try {
      await _repo.rejectStartup(startup, reason);
      emit(AdminActionSuccess('${startup.ventureName ?? 'Startup'} rejected.'));
      await loadAll();
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
