import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/opportunity/opportunity_cubit.dart';
import '../../blocs/opportunity/opportunity_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/section_header.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    final user = _getUser(context);
    context.read<OpportunityCubit>().loadAll(userSkills: user?.skills ?? []);
  }

  UserModel? _getUser(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUser(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: false,
        userInitials: user?.initials ?? 'U',
        notificationCount: 3,
        onNotification: () => Navigator.pushNamed(context, '/student/notifications'),
        onAvatar: () => Navigator.pushNamed(context, '/student/edit-profile'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<OpportunityCubit>().loadAll(userSkills: user?.skills ?? []);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: 'Hello, ${user?.fullName.split(' ').first ?? 'there'} ',
                  style: AppTextStyles.headlineLg,
                  children: const [
                    TextSpan(text: '👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find meaningful ways to contribute.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _SearchBar(onTap: () => Navigator.pushNamed(context, '/student/explore')),
              const SizedBox(height: 28),
              BlocBuilder<OpportunityCubit, OpportunityState>(
                builder: (context, state) {
                  if (state is OpportunityLoading) {
                    return const _LoadingState();
                  }
                  if (state is OpportunityLoaded) {
                    return _LoadedContent(
                      state: state,
                      onOpportunityTap: (id) =>
                          Navigator.pushNamed(context, '/student/opportunity/$id'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final OpportunityLoaded state;
  final void Function(String) onOpportunityTap;

  const _LoadedContent({required this.state, required this.onOpportunityTap});

  @override
  Widget build(BuildContext context) {
    final featured = state.featured.isNotEmpty ? state.featured.first : null;
    final recommended = state.recommended.isNotEmpty
        ? state.recommended
        : state.opportunities.take(4).toList();
    final recent = state.opportunities.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (featured != null) ...[
          SectionHeader(
            title: 'Recommended',
            actionLabel: 'See all',
            onAction: () => Navigator.pushNamed(context, '/student/explore'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, i) => RecommendedCard(
                opportunity: recommended[i],
                isNew: i == 0,
                onTap: () => onOpportunityTap(recommended[i].id),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
        SectionHeader(title: 'Browse by category'),
        const SizedBox(height: 16),
        _CategoryRow(),
        const SizedBox(height: 28),
        SectionHeader(title: 'Recent opportunities'),
        const SizedBox(height: 12),
        ...recent.map((opp) => OpportunityCard(
              opportunity: opp,
              onTap: () => onOpportunityTap(opp.id),
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      (Icons.palette_outlined, 'Design'),
      (Icons.code, 'Engineering'),
      (Icons.campaign_outlined, 'Marketing'),
      (Icons.bar_chart, 'Data'),
      (Icons.more_horiz, 'Other'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/student/explore'),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(cat.$1, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 6),
              Text(cat.$2, style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.outline, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search opportunities...',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
              ),
            ),
            const Icon(Icons.tune, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 90,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
