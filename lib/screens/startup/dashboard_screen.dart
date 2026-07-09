import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../blocs/notification/notification_state.dart';
import '../../blocs/startup/startup_cubit.dart';
import '../../blocs/startup/startup_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/section_header.dart';

class StartupDashboardScreen extends StatefulWidget {
  const StartupDashboardScreen({super.key});

  @override
  State<StartupDashboardScreen> createState() => _StartupDashboardScreenState();
}

class _StartupDashboardScreenState extends State<StartupDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<StartupCubit>().loadDashboard(authState.user.id);
      context.read<NotificationCubit>().load(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: true,
        userInitials: user?.initials ?? 'S',
        notificationCount: BlocProvider.of<NotificationCubit>(context).state
            is NotificationsLoaded
            ? (BlocProvider.of<NotificationCubit>(context).state
                    as NotificationsLoaded)
                .unreadCount
            : 0,
        onNotification: () => Navigator.pushNamed(context, '/startup/notifications'),
        onSettings: () => Navigator.pushNamed(context, '/startup/settings'),
      ),
      body: BlocConsumer<StartupCubit, StartupState>(
        listener: (context, state) {
          if (state is OpportunityPostSuccess) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.read<StartupCubit>().loadDashboard(authState.user.id);
            }
          }
        },
        builder: (context, state) {
          if (state is StartupLoading || state is OpportunityPostSuccess) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is StartupDashboardLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Hero header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.darkHeroGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FOUNDER DASHBOARD',
                                    style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user?.ventureName ?? 'Your Venture',
                                  style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
                                ),
                                Text(
                                  user?.fullName ?? '',
                                  style: AppTextStyles.bodyMd.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user?.initials ?? 'S',
                                  style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _StatPill(
                              label: 'Active Roles',
                              value: state.activeRoles.toString(),
                            ),
                            const SizedBox(width: 10),
                            _StatPill(
                              label: 'Applications',
                              value: state.totalApplications.toString(),
                            ),
                            const SizedBox(width: 10),
                            _StatPill(
                              label: 'New Today',
                              value: state.newApplicationsToday.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_circle_outline,
                          label: 'Post\nOpportunity',
                          gradient: AppColors.primaryGradient,
                          onTap: () => Navigator.pushNamed(context, '/startup/post'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.people_outline,
                          label: 'Browse\nTalent',
                          gradient: AppColors.pinkGradient,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.inbox_outlined,
                          label: 'Review\nApplicants',
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary,
                              AppColors.secondary.withValues(alpha: 0.7)
                            ],
                          ),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state.postings.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Your Postings',
                      actionLabel: 'View All',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    ...state.postings.map(
                      (opp) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OpportunityCard(
                          opportunity: opp,
                          onTap: () => Navigator.pushNamed(context, '/startup/applicants',
                              arguments: opp.id),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (state.recentActivity.isNotEmpty) ...[
                    SectionHeader(title: 'Recent Activity'),
                    const SizedBox(height: 12),
                    ...state.recentActivity.map(
                      (activity) => _ActivityItem(activity: activity),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/startup/post'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Post Role', style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headlineMd.copyWith(color: Colors.white)),
            Text(label,
                style: AppTextStyles.labelSm
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.labelMd.copyWith(color: Colors.white),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, String> activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['title'] ?? '', style: AppTextStyles.labelLg),
                Text(
                  activity['subtitle'] ?? '',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] ?? '',
            style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
