import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
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
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
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
        title: 'ALU Connect',
        userInitials: authState is AuthAuthenticated
            ? authState.user.initials
            : 'U',
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is NotificationsLoaded) {
            final all = state.notifications;
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifications', style: AppTextStyles.headlineLg),
                          Text(
                            '${state.unreadCount} unread',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      if (state.unreadCount > 0)
                        GestureDetector(
                          onTap: () => context
                              .read<NotificationCubit>()
                              .markAllRead(userId),
                          child: Text(
                            'Mark all read',
                            style: AppTextStyles.labelLg
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (all.isEmpty)
                  Expanded(child: _EmptyNotifications())
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      itemCount: all.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 68,
                        color: AppColors.outlineVariant,
                      ),
                      itemBuilder: (context, index) =>
                          _MessageRow(notification: all[index]),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

//  iOS-style message row 

class _MessageRow extends StatelessWidget {
  final NotificationModel notification;
  const _MessageRow({required this.notification});

  (IconData, Color) get _meta {
    switch (notification.type) {
      case NotificationType.interviewInvitation:
        return (Icons.calendar_today_rounded, AppColors.primary);
      case NotificationType.applicationStatusChange:
        return (Icons.check_circle_rounded, AppColors.statusShortlisted);
      case NotificationType.newMessage:
        return (Icons.chat_bubble_rounded, AppColors.secondary);
      case NotificationType.deadlineApproaching:
        return (Icons.alarm_rounded, AppColors.tertiary);
      case NotificationType.profileAchievement:
        return (Icons.emoji_events_rounded, AppColors.statusUnderReview);
      case NotificationType.systemUpdate:
        return (Icons.info_rounded, AppColors.outline);
      case NotificationType.newOpportunity:
        return (Icons.work_rounded, AppColors.secondary);
      case NotificationType.newApplication:
        return (Icons.person_add_rounded, AppColors.statusShortlisted);
      case NotificationType.startupApproved:
        return (Icons.verified_rounded, AppColors.statusShortlisted);
      case NotificationType.startupRejected:
        return (Icons.cancel_rounded, AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _meta;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () => _openDetail(context, color),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
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
                            color: isUnread
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.timeAgo,
                        style: AppTextStyles.labelSm.copyWith(
                          color: isUnread
                              ? color
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: isUnread
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Color accentColor) {
    if (!notification.isRead) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<NotificationCubit>().markRead(
              authState.user.id,
              notification.id,
            );
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationDetailSheet(
        notification: notification,
        accentColor: accentColor,
      ),
    );
  }
}

//  Detail sheet (unchanged logic, cleaned up) 

class _NotificationDetailSheet extends StatelessWidget {
  final NotificationModel notification;
  final Color accentColor;
  const _NotificationDetailSheet(
      {required this.notification, required this.accentColor});

  List<_Segment> _parseBody(String text) {
    final urlRe = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final segments = <_Segment>[];
    int cursor = 0;
    for (final m in urlRe.allMatches(text)) {
      if (m.start > cursor) {
        segments.add(_Segment(text.substring(cursor, m.start), false));
      }
      segments.add(_Segment(m.group(0)!, true));
      cursor = m.end;
    }
    if (cursor < text.length) {
      segments.add(_Segment(text.substring(cursor), false));
    }
    return segments.isEmpty ? [_Segment(text, false)] : segments;
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final segments = _parseBody(notification.body);
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_rounded,
                      color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.title,
                          style: AppTextStyles.headlineSm),
                      Text(notification.timeAgo,
                          style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: RichText(
                text: TextSpan(
                  children: segments.map((seg) {
                    if (seg.isUrl) {
                      return WidgetSpan(
                        child: GestureDetector(
                          onTap: () => _launch(seg.text),
                          child: Text(
                            seg.text,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      );
                    }
                    return TextSpan(
                      text: seg.text,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurface),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (notification.type == NotificationType.interviewInvitation &&
                notification.actionId != null) ...[
              const SizedBox(height: 16),
              _ActionButton(
                label: 'View Invitation',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, '/student/invitation/${notification.actionId}');
                },
              ),
            ],
            if (notification.type == NotificationType.newOpportunity &&
                notification.actionId != null) ...[
              const SizedBox(height: 16),
              _ActionButton(
                label: 'View Role',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, '/student/opportunity/${notification.actionId}');
                },
              ),
            ],
            if (notification.type == NotificationType.applicationStatusChange) ...[
              const SizedBox(height: 16),
              _ActionButton(
                label: 'View Application',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/student/applications',
                    (route) => route.isFirst,
                  );
                },
              ),
            ],
            if (notification.type == NotificationType.newApplication &&
                notification.actionId != null) ...[
              const SizedBox(height: 16),
              _ActionButton(
                label: 'Review Applicants',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/startup/applicants',
                    arguments: notification.actionId,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelLg.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Segment {
  final String text;
  final bool isUrl;
  const _Segment(this.text, this.isUrl);
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No notifications yet', style: AppTextStyles.headlineSm),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you about invitations,\napplication updates, and new roles.',
            style:
                AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
