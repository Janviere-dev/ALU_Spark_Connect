import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/application/application_cubit.dart';
import '../../blocs/application/application_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/opportunity/opportunity_cubit.dart';
import '../../blocs/opportunity/opportunity_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/application_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

class StudentApplicationsScreen extends StatefulWidget {
  const StudentApplicationsScreen({super.key});

  @override
  State<StudentApplicationsScreen> createState() => _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState extends State<StudentApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ApplicationCubit>().loadForStudent(authState.user.id);
      context.read<OpportunityCubit>().loadAll(userSkills: authState.user.skills);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: false,
        userInitials: 'JM',
        notificationCount: 3,
        onNotification: () => Navigator.pushNamed(context, '/student/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Track Your Journey', style: AppTextStyles.headlineLg),
            const SizedBox(height: 4),
            Text(
              'Manage your applications and discover new opportunities.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            BlocBuilder<ApplicationCubit, ApplicationState>(
              builder: (context, state) {
                if (state is ApplicationsLoaded) {
                  final apps = state.applications;
                  final interviews = apps
                      .where((a) => a.status == ApplicationStatus.interviewScheduled)
                      .length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total Applications',
                              value: '${apps.length}',
                              isPrimary: true,
                              icon: Icons.description_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Interviews Scheduled',
                              value: '$interviews',
                              isPrimary: false,
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SectionHeader(
                        title: 'Recent Applications',
                        actionLabel: 'View All',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      ...apps.take(3).map((app) => _ApplicationCard(
                            application: app,
                            onTap: app.status == ApplicationStatus.interviewScheduled
                                ? () => Navigator.pushNamed(
                                    context, '/student/invitation/${app.id}')
                                : null,
                          )),
                    ],
                  );
                }
                if (state is ApplicationLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recommended for You', style: AppTextStyles.headlineSm),
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<OpportunityCubit, OpportunityState>(
              builder: (context, state) {
                if (state is OpportunityLoaded && state.recommended.isNotEmpty) {
                  return SizedBox(
                    height: 290,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.recommended.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(right: i < state.recommended.length - 1 ? 12 : 0),
                        child: RecommendedCard(
                          opportunity: state.recommended[i],
                          onTap: () => Navigator.pushNamed(
                              context, '/student/opportunity/${state.recommended[i].id}'),
                          isNew: i == 0,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
            _StrengthBanner(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isPrimary,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.cardGradient : null,
        color: isPrimary ? null : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isPrimary ? Colors.white : AppColors.primary, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: isPrimary ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineLg.copyWith(
              color: isPrimary ? Colors.white : AppColors.primary,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback? onTap;

  const _ApplicationCard({required this.application, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.roleTitle,
                    style: AppTextStyles.labelLg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    application.startupName,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: application.status),
                const SizedBox(height: 4),
                Text(
                  application.appliedTimeAgo,
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StrengthBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Strength',
            style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Your profile matches 85% of recent roles.',
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.85,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/student/edit-profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Complete Profile',
                    style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
