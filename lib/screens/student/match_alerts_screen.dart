import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/opportunity/opportunity_cubit.dart';
import '../../blocs/opportunity/opportunity_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/opportunity_card.dart';

class MatchAlertsScreen extends StatefulWidget {
  const MatchAlertsScreen({super.key});

  @override
  State<MatchAlertsScreen> createState() => _MatchAlertsScreenState();
}

class _MatchAlertsScreenState extends State<MatchAlertsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OpportunityCubit>().loadMatching(
            skills: authState.user.skills,
            focusAreas: authState.user.focusAreas,
          );
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
        userInitials: user?.initials ?? 'U',
      ),
      body: BlocBuilder<OpportunityCubit, OpportunityState>(
        builder: (context, state) {
          if (state is OpportunityLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is OpportunityLoaded) {
            final opps = state.opportunities;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matching Roles', style: AppTextStyles.headlineLg),
                      const SizedBox(height: 4),
                      Text(
                        opps.isEmpty
                            ? 'No matches yet! Update your skills and focus areas to see relevant roles.'
                            : '${opps.length} role${opps.length == 1 ? '' : 's'} matching your skills & focus areas',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      if (user != null && (user.skills.isNotEmpty || user.focusAreas.isNotEmpty)) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...user.skills.take(3).map((s) => _Tag(s, AppColors.primary)),
                            ...user.focusAreas.take(2).map((a) => _Tag(a, AppColors.secondary)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (opps.isEmpty)
                  Expanded(child: _EmptyState())
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: opps.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final opp = opps[i];
                        final bm = context.watch<BookmarkCubit>();
                        return OpportunityCard(
                          opportunity: opp,
                          onTap: () => Navigator.pushNamed(
                              context, '/student/opportunity/${opp.id}'),
                          isBookmarked: bm.isOpportunitySaved(opp.id),
                          onBookmark: () {
                            if (authState is AuthAuthenticated) {
                              bm.toggleOpportunity(authState.user.id, opp.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          if (state is OpportunityError) {
            return Center(
                child: Text(state.message, style: AppTextStyles.bodyMd));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
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
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No matching roles yet', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text(
              'Add skills and focus areas to your profile so we can surface the right opportunities for you.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/student/skills'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Update Skills & Focus Areas',
                    style:
                        AppTextStyles.labelLg.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
