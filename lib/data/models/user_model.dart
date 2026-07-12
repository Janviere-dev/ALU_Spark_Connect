import 'package:equatable/equatable.dart';

enum UserRole { student, startup, admin }

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? ventureName;
  final String? education;
  final String? location;
  final String? shortPitch;
  final List<String> skills;
  final List<String> focusAreas;
  final String? availability;
  final String? startDate;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? cvUrl;
  final String? founderName;
  final String? problemStatement;
  final String? teamSize;
  final String? impact;
  final bool isOpenToOpportunities;
  final bool onboardingComplete;
  final List<String> savedOpportunityIds;
  final List<String> savedStudentIds;
  final DateTime createdAt;
  // Startup verification: 'pending' | 'approved' | 'rejected' | null (legacy = approved)
  final String? status;
  final String? docsLink;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.ventureName,
    this.founderName,
    this.education,
    this.location,
    this.shortPitch,
    this.problemStatement,
    this.teamSize,
    this.impact,
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
    this.savedOpportunityIds = const [],
    this.savedStudentIds = const [],
    required this.createdAt,
    this.status,
    this.docsLink,
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
    String? founderName,
    String? education,
    String? location,
    String? shortPitch,
    String? problemStatement,
    String? teamSize,
    String? impact,
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
    List<String>? savedOpportunityIds,
    List<String>? savedStudentIds,
    String? status,
    String? docsLink,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ventureName: ventureName ?? this.ventureName,
      founderName: founderName ?? this.founderName,
      education: education ?? this.education,
      location: location ?? this.location,
      shortPitch: shortPitch ?? this.shortPitch,
      problemStatement: problemStatement ?? this.problemStatement,
      teamSize: teamSize ?? this.teamSize,
      impact: impact ?? this.impact,
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
      savedOpportunityIds: savedOpportunityIds ?? this.savedOpportunityIds,
      savedStudentIds: savedStudentIds ?? this.savedStudentIds,
      createdAt: createdAt,
      status: status ?? this.status,
      docsLink: docsLink ?? this.docsLink,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'ventureName': ventureName,
        'founderName': founderName,
        'education': education,
        'location': location,
        'shortPitch': shortPitch,
        'problemStatement': problemStatement,
        'teamSize': teamSize,
        'impact': impact,
        'skills': skills,
        'focusAreas': focusAreas,
        'availability': availability,
        'startDate': startDate,
        'portfolioUrl': portfolioUrl,
        'linkedinUrl': linkedinUrl,
        'githubUrl': githubUrl,
        'cvUrl': cvUrl,
        'isOpenToOpportunities': isOpenToOpportunities,
        'onboardingComplete': onboardingComplete,
        'savedOpportunityIds': savedOpportunityIds,
        'savedStudentIds': savedStudentIds,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'status': status,
        'docsLink': docsLink,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        role: UserRole.values.firstWhere((r) => r.name == map['role']),
        avatarUrl: map['avatarUrl'] as String?,
        ventureName: map['ventureName'] as String?,
        founderName: map['founderName'] as String?,
        education: map['education'] as String?,
        location: map['location'] as String?,
        shortPitch: map['shortPitch'] as String?,
        problemStatement: map['problemStatement'] as String?,
        teamSize: map['teamSize'] as String?,
        impact: map['impact'] as String?,
        skills: List<String>.from(map['skills'] ?? []),
        focusAreas: List<String>.from(map['focusAreas'] ?? []),
        availability: map['availability'] as String?,
        startDate: map['startDate'] as String?,
        portfolioUrl: map['portfolioUrl'] as String?,
        linkedinUrl: map['linkedinUrl'] as String?,
        githubUrl: map['githubUrl'] as String?,
        cvUrl: map['cvUrl'] as String?,
        isOpenToOpportunities: map['isOpenToOpportunities'] as bool? ?? true,
        onboardingComplete: map['onboardingComplete'] as bool? ?? false,
        savedOpportunityIds:
            List<String>.from(map['savedOpportunityIds'] ?? []),
        savedStudentIds: List<String>.from(map['savedStudentIds'] ?? []),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            map['createdAt'] as int? ?? 0),
        status: map['status'] as String?,
        docsLink: map['docsLink'] as String?,
      );

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        role,
        avatarUrl,
        ventureName,
        founderName,
        education,
        location,
        shortPitch,
        problemStatement,
        teamSize,
        impact,
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
        savedOpportunityIds,
        savedStudentIds,
        createdAt,
        status,
        docsLink,
      ];
}
