import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final UserRole selectedRole;
  final List<String> selectedFocusAreas;
  final List<String> selectedSkills;
  final String? availability;
  final String? startDate;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final String? githubUrl;
  final bool isLoading;
  final String? error;
  final bool isComplete;

  const OnboardingState({
    this.currentStep = 1,
    this.selectedRole = UserRole.student,
    this.selectedFocusAreas = const [],
    this.selectedSkills = const [],
    this.availability,
    this.startDate,
    this.linkedinUrl,
    this.portfolioUrl,
    this.githubUrl,
    this.isLoading = false,
    this.error,
    this.isComplete = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    UserRole? selectedRole,
    List<String>? selectedFocusAreas,
    List<String>? selectedSkills,
    String? availability,
    String? startDate,
    String? linkedinUrl,
    String? portfolioUrl,
    String? githubUrl,
    bool? isLoading,
    String? error,
    bool? isComplete,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedFocusAreas: selectedFocusAreas ?? this.selectedFocusAreas,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      availability: availability ?? this.availability,
      startDate: startDate ?? this.startDate,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        selectedRole,
        selectedFocusAreas,
        selectedSkills,
        availability,
        startDate,
        linkedinUrl,
        portfolioUrl,
        githubUrl,
        isLoading,
        error,
        isComplete,
      ];
}
