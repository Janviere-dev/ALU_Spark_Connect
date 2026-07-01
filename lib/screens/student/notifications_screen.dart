import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../blocs/notification/notification_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notification_model.dart';
import '../../widgets/app_header.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationCubit>().load(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showBack: true,
        title: 'ALU Ventures',
        userInitials: 'JM',
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is NotificationsLoaded) {
            final priority = state.notifications.where((n) => n.isPriority).toList();
            final regular = state.notifications.where((n) => !n.isPriority).toList();
            final earlier = regular.where((n) {
              return DateTime.now().difference(n.createdAt).inDays >= 3;
            }).toList();
            final recent = regular.where((n) {
              return DateTime.now().difference(n.createdAt).inDays < 3;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications', style: AppTextStyles.headlineLg),
                      GestureDetector(
                        onTap: () => context.read<NotificationCubit>().markAllRead(userId),
                        child: Text(
                          'Mark all read',
                          style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay updated with your opportunities',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  ...priority.map((n) => _PriorityNotificationCard(
                        notification: n,
                        onDetails: () => Navigator.pushNamed(
                            context, '/student/invitation/${n.actionId}'),
                      )),
                  ...recent.map((n) => _NotificationItem(notification: n)),
                  if (earlier.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'EARLIER THIS WEEK',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...earlier.map((n) => _NotificationItem(notification: n)),
                  ],
                  const SizedBox(height: 32),
                  _AllCaughtUp(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PriorityNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDetails;

  const _PriorityNotificationCard({required this.notification, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Priority',
                  style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                ),
              ),
              Text(
                notification.timeAgo,
                style: AppTextStyles.labelMd.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(notification.title, style: AppTextStyles.headlineSm.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            notification.body,
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Select Time',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Details',
                        style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconData();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead
            ? null
            : Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.labelLg.copyWith(
                          color: notification.isRead
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          notification.timeAgo,
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: notification.isRead
                        ? AppColors.onSurfaceVariant
                        : AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _iconData() {
    switch (notification.type) {
      case NotificationType.interviewInvitation:
        return (Icons.calendar_today_outlined, AppColors.primary);
      case NotificationType.applicationStatusChange:
        return (Icons.check_circle_outline, AppColors.statusShortlisted);
      case NotificationType.newMessage:
        return (Icons.chat_bubble_outline, AppColors.secondary);
      case NotificationType.deadlineApproaching:
        return (Icons.alarm_outlined, AppColors.tertiary);
      case NotificationType.profileAchievement:
        return (Icons.emoji_events_outlined, AppColors.statusUnderReview);
      case NotificationType.systemUpdate:
        return (Icons.info_outline, AppColors.outline);
    }
  }
}

class _AllCaughtUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 12),
        Text('All Caught Up!', style: AppTextStyles.headlineSm),
        const SizedBox(height: 4),
        Text(
          "You've handled all your recent updates. Great job staying organized!",
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
