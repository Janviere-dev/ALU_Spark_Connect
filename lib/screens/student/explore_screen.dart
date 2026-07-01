import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/opportunity/opportunity_cubit.dart';
import '../../blocs/opportunity/opportunity_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/skill_chip.dart';

class StudentExploreScreen extends StatefulWidget {
  const StudentExploreScreen({super.key});

  @override
  State<StudentExploreScreen> createState() => _StudentExploreScreenState();
}

class _StudentExploreScreenState extends State<StudentExploreScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All Opportunities';

  @override
  void initState() {
    super.initState();
    context.read<OpportunityCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    context.read<OpportunityCubit>().search(query, category: _selectedCategory);
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _search,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Search startups, roles, or skills...',
                prefixIcon: const Icon(Icons.search, color: AppColors.outline, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                'All Opportunities',
                ...AppConstants.opportunityCategories,
              ].map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SkillChip(
                    label: cat,
                    isSelected: selected,
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _search(_searchCtrl.text);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<OpportunityCubit, OpportunityState>(
              builder: (context, state) {
                if (state is OpportunityLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is OpportunityLoaded) {
                  final opps = state.opportunities;
                  final featured = opps.where((o) => o.isFeatured).toList();
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (featured.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        FeaturedOpportunityCard(
                          opportunity: featured.first,
                          onTap: () => Navigator.pushNamed(
                              context, '/student/opportunity/${featured.first.id}'),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discover Openings', style: AppTextStyles.headlineSm),
                          Text(
                            '${opps.length} results found',
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...opps.map((opp) => OpportunityCard(
                            opportunity: opp,
                            onTap: () => Navigator.pushNamed(
                                context, '/student/opportunity/${opp.id}'),
                          )),
                      const SizedBox(height: 16),
                      _BottomBannerRow(),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                if (state is OpportunityError) {
                  return Center(child: Text(state.message, style: AppTextStyles.bodyMd));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBannerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 8),
                Text('New Skills', style: AppTextStyles.labelLg),
                Text(
                  'Based on your browsing history',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 8),
                Text('Match Alerts', style: AppTextStyles.labelLg),
                Text(
                  '3 new matching roles today',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
