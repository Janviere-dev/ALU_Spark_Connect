import 'package:equatable/equatable.dart';

enum UserRole { student, startup }

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? ventureName;
  final String? education;
  final String? shortPitch;
  final List<String> skills;
  final List<String> focusAreas;
  final String? availability;
  final String? startDate;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? cvUrl;
  final bool isOpenToOpportunities;
  final bool onboardingComplete;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.ventureName,
    this.education,
    this.shortPitch,
    this.skills = const [],
    this.focusAreas = const [],
    this.availability,
    this.startDate,
    this.portfolioUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.cvUrl,
    this.isOpenToOpportunities = true,
    this.onboardingComplete = false,
    required this.createdAt,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? ventureName,
    String? education,
    String? shortPitch,
    List<String>? skills,
    List<String>? focusAreas,
    String? availability,
    String? startDate,
    String? portfolioUrl,
    String? linkedinUrl,
    String? githubUrl,
    String? cvUrl,
    bool? isOpenToOpportunities,
    bool? onboardingComplete,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ventureName: ventureName ?? this.ventureName,
      education: education ?? this.education,
      shortPitch: shortPitch ?? this.shortPitch,
      skills: skills ?? this.skills,
      focusAreas: focusAreas ?? this.focusAreas,
      availability: availability ?? this.availability,
      startDate: startDate ?? this.startDate,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      cvUrl: cvUrl ?? this.cvUrl,
      isOpenToOpportunities: isOpenToOpportunities ?? this.isOpenToOpportunities,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        role,
        avatarUrl,
        ventureName,
        education,
        shortPitch,
        skills,
        focusAreas,
        availability,
        startDate,
        portfolioUrl,
        linkedinUrl,
        githubUrl,
        cvUrl,
        isOpenToOpportunities,
        onboardingComplete,
        createdAt,
      ];
}
