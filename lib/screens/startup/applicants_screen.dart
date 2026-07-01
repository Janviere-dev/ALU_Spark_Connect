import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/application/application_cubit.dart';
import '../../blocs/application/application_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/application_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';

class ApplicantsScreen extends StatefulWidget {
  final String? opportunityId;
  const ApplicantsScreen({super.key, this.opportunityId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (widget.opportunityId != null) {
        context.read<ApplicationCubit>().loadForOpportunity(widget.opportunityId!);
      } else {
        context.read<ApplicationCubit>().loadForOpportunity('all');
      }
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
        onNotification: () => Navigator.pushNamed(context, '/startup/notifications'),
        onSettings: () => Navigator.pushNamed(context, '/startup/settings'),
      ),
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return _EmptyApplicants();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Applicants', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 4),
                  Text(
                    '${state.applications.length} application${state.applications.length == 1 ? '' : 's'} received',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  // Summary stats
                  Row(
                    children: [
                      _StatCard(
                        label: 'Total',
                        value: state.applications.length.toString(),
                        gradient: AppColors.primaryGradient,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Shortlisted',
                        value: state.applications
                            .where((a) => a.status == ApplicationStatus.shortlisted)
                            .length
                            .toString(),
                        gradient: AppColors.pinkGradient,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Interviews',
                        value: state.applications
                            .where((a) =>
                                a.status == ApplicationStatus.interviewScheduled)
                            .length
                            .toString(),
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.7)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...state.applications.map(
                    (app) => _ApplicantCard(
                      application: app,
                      onShortlist: () => context
                          .read<ApplicationCubit>()
                          .updateStatus(app.id, ApplicationStatus.shortlisted),
                      onReject: () => context
                          .read<ApplicationCubit>()
                          .updateStatus(app.id, ApplicationStatus.rejected),
                      onInterview: () => context
                          .read<ApplicationCubit>()
                          .updateStatus(app.id, ApplicationStatus.interviewScheduled),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return _EmptyApplicants();
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final LinearGradient gradient;
  const _StatCard({required this.label, required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headlineMd.copyWith(color: Colors.white)),
            Text(label,
                style: AppTextStyles.labelSm.copyWith(color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onShortlist;
  final VoidCallback onReject;
  final VoidCallback onInterview;

  const _ApplicantCard({
    required this.application,
    required this.onShortlist,
    required this.onReject,
    required this.onInterview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    application.studentName.isNotEmpty
                        ? application.studentName[0].toUpperCase()
                        : 'S',
                    style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(application.studentName, style: AppTextStyles.headlineSm),
                    Text(
                      application.roleTitle,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: application.status),
            ],
          ),
          const SizedBox(height: 12),
          if (application.pitch.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${application.pitch}"',
                style: AppTextStyles.bodyMd.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Text(
                application.appliedTimeAgo,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              if (application.cvUrl != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: AppColors.primary, size: 12),
                      const SizedBox(width: 4),
                      Text('CV',
                          style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (application.status == ApplicationStatus.submitted ||
                  application.status == ApplicationStatus.underReview) ...[
                _ActionBtn(
                  label: 'Shortlist',
                  color: AppColors.statusShortlisted,
                  icon: Icons.star_outline,
                  onTap: onShortlist,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Interview',
                  color: AppColors.primary,
                  icon: Icons.calendar_month_outlined,
                  onTap: onInterview,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Reject',
                  color: AppColors.error,
                  icon: Icons.close,
                  onTap: onReject,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSm.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyApplicants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              child: const Icon(Icons.inbox_outlined, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No applicants yet', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here once students apply to your opportunities.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
