import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/application_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/application_repository.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _repo;

  ApplicationCubit({required ApplicationRepository applicationRepository})
      : _repo = applicationRepository,
        super(ApplicationInitial());

  Future<void> loadForStudent(String studentId) async {
    emit(ApplicationLoading());
    try {
      final apps = await _repo.getForStudent(studentId);
      emit(ApplicationsLoaded(apps));
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> loadForOpportunity(String opportunityId) async {
    emit(ApplicationLoading());
    try {
      final apps = await _repo.getForOpportunity(opportunityId);
      emit(ApplicationsLoaded(apps));
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    try {
      await _repo.updateStatus(applicationId, status);
      final current = state;
      if (current is ApplicationsLoaded) {
        final updated = current.applications
            .map((a) => a.id == applicationId ? a.copyWith(status: status) : a)
            .toList();
        emit(ApplicationsLoaded(updated));
      }
    } catch (e) {
      emit(ApplicationError(e.toString()));
    }
  }

  Future<void> submit({
    required UserModel student,
    required String opportunityId,
    required String roleTitle,
    required String startupName,
    required String pitch,
    String? cvPath,
  }) async {
    emit(ApplicationLoading());
    try {
      final app = await _repo.submit(
        studentId: student.id,
        studentName: student.fullName,
        studentEmail: student.email,
        studentUniversity: student.education,
        opportunityId: opportunityId,
        roleTitle: roleTitle,
        startupName: startupName,
        pitch: pitch,
        cvUrl: cvPath,
        studentSkills: student.skills,
      );
      emit(ApplicationSubmitSuccess(app));
    } catch (e) {
      emit(ApplicationError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
