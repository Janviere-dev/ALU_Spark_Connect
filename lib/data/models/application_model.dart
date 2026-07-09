import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  submitted,
  underReview,
  shortlisted,
  interviewScheduled,
  accepted,
  rejected,
}

extension ApplicationStatusExt on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'SUBMITTED';
      case ApplicationStatus.underReview:
        return 'UNDER REVIEW';
      case ApplicationStatus.shortlisted:
        return 'SHORTLISTED';
      case ApplicationStatus.interviewScheduled:
        return 'INTERVIEW SCHEDULED';
      case ApplicationStatus.accepted:
        return 'ACCEPTED';
      case ApplicationStatus.rejected:
        return 'REJECTED';
    }
  }
}

class ApplicationModel extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentUniversity;
  final String opportunityId;
  final String roleTitle;
  final String startupName;
  final String? startupLogoUrl;
  final String pitch;
  final String? cvUrl;
  final ApplicationStatus status;
  final int matchScore;
  final List<String> studentSkills;
  final DateTime appliedAt;
  final DateTime? interviewDate;

  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentUniversity,
    required this.opportunityId,
    required this.roleTitle,
    required this.startupName,
    this.startupLogoUrl,
    required this.pitch,
    this.cvUrl,
    this.status = ApplicationStatus.submitted,
    this.matchScore = 0,
    this.studentSkills = const [],
    required this.appliedAt,
    this.interviewDate,
  });

  String get appliedTimeAgo {
    final diff = DateTime.now().difference(appliedAt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  ApplicationModel copyWith({ApplicationStatus? status, DateTime? interviewDate}) {
    return ApplicationModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentUniversity: studentUniversity,
      opportunityId: opportunityId,
      roleTitle: roleTitle,
      startupName: startupName,
      startupLogoUrl: startupLogoUrl,
      pitch: pitch,
      cvUrl: cvUrl,
      status: status ?? this.status,
      matchScore: matchScore,
      studentSkills: studentSkills,
      appliedAt: appliedAt,
      interviewDate: interviewDate ?? this.interviewDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'studentUniversity': studentUniversity,
        'opportunityId': opportunityId,
        'roleTitle': roleTitle,
        'startupName': startupName,
        'startupLogoUrl': startupLogoUrl,
        'pitch': pitch,
        'cvUrl': cvUrl,
        'status': status.name,
        'matchScore': matchScore,
        'studentSkills': studentSkills,
        'appliedAt': appliedAt.millisecondsSinceEpoch,
        'interviewDate': interviewDate?.millisecondsSinceEpoch,
      };

  factory ApplicationModel.fromMap(Map<String, dynamic> map) => ApplicationModel(
        id: map['id'] as String,
        studentId: map['studentId'] as String,
        studentName: map['studentName'] as String,
        studentEmail: map['studentEmail'] as String,
        studentUniversity: map['studentUniversity'] as String?,
        opportunityId: map['opportunityId'] as String,
        roleTitle: map['roleTitle'] as String,
        startupName: map['startupName'] as String,
        startupLogoUrl: map['startupLogoUrl'] as String?,
        pitch: map['pitch'] as String,
        cvUrl: map['cvUrl'] as String?,
        status: ApplicationStatus.values.firstWhere(
            (s) => s.name == map['status'],
            orElse: () => ApplicationStatus.submitted),
        matchScore: map['matchScore'] as int? ?? 0,
        studentSkills: List<String>.from(map['studentSkills'] ?? []),
        appliedAt: DateTime.fromMillisecondsSinceEpoch(
            map['appliedAt'] as int? ?? 0),
        interviewDate: map['interviewDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['interviewDate'] as int)
            : null,
      );

  @override
  List<Object?> get props => [id, studentId, opportunityId, status, appliedAt];
}
