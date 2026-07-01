import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final AuthRepository _authRepository;

  OnboardingCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const OnboardingState());

  void toggleFocusArea(String area) {
    final current = List<String>.from(state.selectedFocusAreas);
    if (current.contains(area)) {
      current.remove(area);
    } else {
      current.add(area);
    }
    emit(state.copyWith(selectedFocusAreas: current));
  }

  void toggleSkill(String skill) {
    final current = List<String>.from(state.selectedSkills);
    if (current.contains(skill)) {
      current.remove(skill);
    } else {
      current.add(skill);
    }
    emit(state.copyWith(selectedSkills: current));
  }

  void setAvailability(String availability) =>
      emit(state.copyWith(availability: availability));

  void setStartDate(String startDate) =>
      emit(state.copyWith(startDate: startDate));

  void setLinkedinUrl(String url) => emit(state.copyWith(linkedinUrl: url));
  void setPortfolioUrl(String url) => emit(state.copyWith(portfolioUrl: url));
  void setGithubUrl(String url) => emit(state.copyWith(githubUrl: url));

  void goToStep(int step) => emit(state.copyWith(currentStep: step));

  Future<void> completeOnboarding(UserModel user) async {
    if (state.selectedFocusAreas.isEmpty) {
      emit(state.copyWith(error: 'Please select at least one focus area.'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final updated = user.copyWith(
        focusAreas: state.selectedFocusAreas,
        skills: state.selectedSkills,
        availability: state.availability,
        startDate: state.startDate,
        linkedinUrl: state.linkedinUrl,
        portfolioUrl: state.portfolioUrl,
        githubUrl: state.githubUrl,
        onboardingComplete: true,
      );
      await _authRepository.updateProfile(updated);
      emit(state.copyWith(isLoading: false, isComplete: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> skipOnboarding(UserModel user) async {
    emit(state.copyWith(isLoading: true));
    try {
      final updated = user.copyWith(onboardingComplete: true);
      await _authRepository.updateProfile(updated);
      emit(state.copyWith(isLoading: false, isComplete: true));
    } catch (_) {
      emit(state.copyWith(isLoading: false, isComplete: true));
    }
  }
}
