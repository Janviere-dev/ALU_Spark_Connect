import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/opportunity/opportunity_cubit.dart';
import '../../blocs/opportunity/opportunity_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/skill_chip.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final studentId = authState is AuthAuthenticated ? authState.user.id : '';
    context.read<OpportunityCubit>().loadDetail(widget.opportunityId, studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Opportunity Details', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
            onPressed: () => Navigator.pushNamed(context, '/student/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
            onPressed: () => Navigator.pushNamed(context, '/student/settings'),
          ),
        ],
      ),
      body: BlocBuilder<OpportunityCubit, OpportunityState>(
        builder: (context, state) {
          if (state is OpportunityLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is OpportunityDetailLoaded) {
            final opp = state.opportunity;
            final whyJoinLines = (opp.whyJoinUs ?? '').split('\n').where((l) => l.isNotEmpty).toList();
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: AppColors.cardGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.star_outline, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(opp.roleTitle, style: AppTextStyles.headlineMd),
                                  const SizedBox(height: 4),
                                  Text(
                                    opp.startupName,
                                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: opp.skills.take(3).map((s) => SkillChip(label: s)).toList(),
                                  ),
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
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.schedule_outlined,
                                iconColor: AppColors.primary.withValues(alpha: 0.7),
                                label: 'COMMITMENT',
                                value: opp.commitment,
                              ),
                              const Divider(height: 20),
                              _DetailRow(
                                icon: Icons.location_on_outlined,
                                iconColor: AppColors.tertiary.withValues(alpha: 0.8),
                                label: 'LOCATION',
                                value: opp.location,
                              ),
                              const Divider(height: 20),
                              _DetailRow(
                                icon: Icons.calendar_month_outlined,
                                iconColor: AppColors.statusInterview.withValues(alpha: 0.8),
                                label: 'POSTED DATE',
                                value: 'Posted ${opp.postedTimeAgo}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('About the Role', style: AppTextStyles.headlineSm),
                        const SizedBox(height: 10),
                        Text(opp.description, style: AppTextStyles.bodyLg),
                        const SizedBox(height: 24),
                        Text('Skills Required', style: AppTextStyles.headlineSm),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: opp.skills
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.outlineVariant),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_outline,
                                            color: AppColors.primary, size: 16),
                                        const SizedBox(width: 6),
                                        Text(s, style: AppTextStyles.labelMd),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        if (whyJoinLines.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Why ${opp.startupName}?', style: AppTextStyles.headlineSm),
                                const SizedBox(height: 12),
                                ...whyJoinLines.map(
                                  (line) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.rocket_launch_outlined,
                                            color: AppColors.primary, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(line, style: AppTextStyles.bodyMd)),
                                      ],
                                    ),
                                  ),
                                ),
                                if (opp.compensation != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money,
                                          color: AppColors.statusShortlisted, size: 16),
                                      const SizedBox(width: 8),
                                      Text(opp.compensation!, style: AppTextStyles.bodyMd),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    const Icon(Icons.business, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(opp.startupName, style: AppTextStyles.labelLg),
                                    Text(
                                      '${opp.category} Startup • 20-50 Employees',
                                      style: AppTextStyles.labelMd
                                          .copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.outline),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        BlocBuilder<BookmarkCubit, BookmarkState>(
                          builder: (context, bmState) {
                            final saved = context
                                .read<BookmarkCubit>()
                                .isOpportunitySaved(widget.opportunityId);
                            final authState =
                                context.read<AuthBloc>().state;
                            return GestureDetector(
                              onTap: () {
                                if (authState is AuthAuthenticated) {
                                  context
                                      .read<BookmarkCubit>()
                                      .toggleOpportunity(
                                        authState.user.id,
                                        widget.opportunityId,
                                      );
                                }
                              },
                              child: Container(
                                width: 52,
                                height: 52,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: saved
                                      ? AppColors.primary
                                          .withValues(alpha: 0.1)
                                      : null,
                                  border: Border.all(
                                    color: saved
                                        ? AppColors.primary
                                        : AppColors.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  saved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: saved
                                      ? AppColors.primary
                                      : AppColors.onSurface,
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: state.hasApplied
                              ? Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.statusAcceptedBg,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Applied ✓',
                                      style: AppTextStyles.labelLg
                                          .copyWith(color: AppColors.statusAccepted),
                                    ),
                                  ),
                                )
                              : AppButton(
                                  label: 'Apply Now',
                                  icon: const Icon(Icons.send_outlined,
                                      color: Colors.white, size: 18),
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/student/apply/${opp.id}',
                                    arguments: opp,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is OpportunityError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.labelLg),
          ],
        ),
      ],
    );
  }
}
