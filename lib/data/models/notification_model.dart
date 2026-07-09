import 'package:equatable/equatable.dart';

enum NotificationType {
  interviewInvitation,
  applicationStatusChange,
  newMessage,
  deadlineApproaching,
  profileAchievement,
  systemUpdate,
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final bool isPriority;
  final String? actionId;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.isPriority = false,
    this.actionId,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      isPriority: isPriority,
      actionId: actionId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'isRead': isRead,
        'isPriority': isPriority,
        'actionId': actionId,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        type: NotificationType.values.firstWhere(
            (t) => t.name == map['type'],
            orElse: () => NotificationType.systemUpdate),
        title: map['title'] as String,
        body: map['body'] as String,
        isRead: map['isRead'] as bool? ?? false,
        isPriority: map['isPriority'] as bool? ?? false,
        actionId: map['actionId'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            map['createdAt'] as int? ?? 0),
      );

  @override
  List<Object?> get props => [id, userId, type, isRead, createdAt];
}
