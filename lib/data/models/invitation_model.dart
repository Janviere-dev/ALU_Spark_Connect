import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined }

class InvitationModel extends Equatable {
  final String id;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String opportunityId;
  final String roleTitle;
  final String message;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const InvitationModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.opportunityId,
    required this.roleTitle,
    required this.message,
    this.status = InvitationStatus.pending,
    required this.createdAt,
    this.respondedAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  InvitationModel copyWith({InvitationStatus? status, DateTime? respondedAt}) {
    return InvitationModel(
      id: id,
      startupId: startupId,
      startupName: startupName,
      studentId: studentId,
      studentName: studentName,
      opportunityId: opportunityId,
      roleTitle: roleTitle,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'startupId': startupId,
        'startupName': startupName,
        'studentId': studentId,
        'studentName': studentName,
        'opportunityId': opportunityId,
        'roleTitle': roleTitle,
        'message': message,
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'respondedAt': respondedAt?.millisecondsSinceEpoch,
      };

  factory InvitationModel.fromMap(Map<String, dynamic> map) => InvitationModel(
        id: map['id'] as String,
        startupId: map['startupId'] as String,
        startupName: map['startupName'] as String,
        studentId: map['studentId'] as String,
        studentName: map['studentName'] as String,
        opportunityId: map['opportunityId'] as String,
        roleTitle: map['roleTitle'] as String,
        message: map['message'] as String,
        status: InvitationStatus.values.firstWhere(
            (s) => s.name == map['status'],
            orElse: () => InvitationStatus.pending),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            map['createdAt'] as int? ?? 0),
        respondedAt: map['respondedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'] as int)
            : null,
      );

  @override
  List<Object?> get props => [id, startupId, studentId, opportunityId, status];
}
