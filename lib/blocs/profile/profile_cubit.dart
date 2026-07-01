import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(ProfileInitial());

  void load(UserModel user) {
    emit(ProfileLoaded(user: user, editSkills: List.from(user.skills)));
  }

  void addSkill(String skill) {
    final current = state as ProfileLoaded;
    if (!current.editSkills.contains(skill)) {
      emit(ProfileLoaded(
        user: current.user,
        editSkills: [...current.editSkills, skill],
      ));
    }
  }

  void removeSkill(String skill) {
    final current = state as ProfileLoaded;
    emit(ProfileLoaded(
      user: current.user,
      editSkills: current.editSkills.where((s) => s != skill).toList(),
    ));
  }

  void toggleOpenToOpportunities(bool value) {
    final current = state as ProfileLoaded;
    emit(ProfileLoaded(
      user: current.user.copyWith(isOpenToOpportunities: value),
      editSkills: current.editSkills,
    ));
  }

  Future<void> save({
    required String fullName,
    required String education,
    required String shortPitch,
    required String portfolioUrl,
    required String linkedinUrl,
  }) async {
    final current = state as ProfileLoaded;
    emit(ProfileLoading());
    try {
      final updated = current.user.copyWith(
        fullName: fullName.trim(),
        education: education.trim(),
        shortPitch: shortPitch.trim(),
        portfolioUrl: portfolioUrl.trim(),
        linkedinUrl: linkedinUrl.trim(),
        skills: current.editSkills,
      );
      await _authRepository.updateProfile(updated);
      emit(ProfileSaveSuccess(updated));
    } catch (e) {
      emit(ProfileError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
