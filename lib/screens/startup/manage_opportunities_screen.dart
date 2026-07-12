import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/opportunity/opportunity_cubit.dart';
import '../../blocs/opportunity/opportunity_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/opportunity_model.dart';
import '../../widgets/app_header.dart';

class ManageOpportunitiesScreen extends StatefulWidget {
  const ManageOpportunitiesScreen({super.key});

  @override
  State<ManageOpportunitiesScreen> createState() =>
      _ManageOpportunitiesScreenState();
}

class _ManageOpportunitiesScreenState
    extends State<ManageOpportunitiesScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OpportunityCubit>().loadForStartup(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showBack: true,
        title: 'ALU Connect',
        userInitials: user?.initials ?? 'S',
      ),
      body: BlocBuilder<OpportunityCubit, OpportunityState>(
        builder: (context, state) {
          if (state is OpportunityLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final opps = state is OpportunityLoaded ? state.opportunities : <OpportunityModel>[];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manage Opportunities',
                          style: AppTextStyles.headlineLg),
                      const SizedBox(height: 4),
                      Text(
                        '${opps.length} posting${opps.length == 1 ? '' : 's'} total',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              if (opps.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _OppCard(opportunity: opps[i]),
                      childCount: opps.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/startup/post'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Role',
            style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _OppCard extends StatelessWidget {
  final OpportunityModel opportunity;
  const _OppCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final opp = opportunity;
    final isClosed = opp.status == OpportunityStatus.closed || opp.isExpired;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/startup/opportunity/${opp.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                color: (isClosed ? AppColors.outline : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.work_outline,
                color: isClosed ? AppColors.outline : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(opp.roleTitle,
                            style: AppTextStyles.labelLg,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.outline.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Closed',
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant))
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.statusAccepted.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Active',
                              style: AppTextStyles.labelSm
                                  .copyWith(color: AppColors.statusAccepted)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${opp.category} · ${opp.applicantCount} applicant${opp.applicantCount == 1 ? '' : 's'}',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              child: const Icon(Icons.work_outline,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No opportunities yet', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text(
              'Post your first role to start finding great students.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
