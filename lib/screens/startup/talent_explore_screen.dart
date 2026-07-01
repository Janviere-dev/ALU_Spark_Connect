import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/startup/startup_cubit.dart';
import '../../blocs/startup/startup_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_header.dart';

class TalentExploreScreen extends StatefulWidget {
  const TalentExploreScreen({super.key});

  @override
  State<TalentExploreScreen> createState() => _TalentExploreScreenState();
}

class _TalentExploreScreenState extends State<TalentExploreScreen> {
  String? _selectedSkill;
  String? _selectedFocus;

  @override
  void initState() {
    super.initState();
    context.read<StartupCubit>().loadTalent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: true,
        userInitials: _userInitials(context),
        onNotification: () => Navigator.pushNamed(context, '/startup/notifications'),
        onSettings: () => Navigator.pushNamed(context, '/startup/settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover Talent', style: AppTextStyles.headlineLg),
                const SizedBox(height: 4),
                Text(
                  'Students open to internship opportunities at ALU ventures.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedSkill == null && _selectedFocus == null,
                        onTap: () {
                          setState(() {
                            _selectedSkill = null;
                            _selectedFocus = null;
                          });
                          context.read<StartupCubit>().loadTalent();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...AppConstants.skillsList.take(8).map(
                        (skill) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: skill,
                            isSelected: _selectedSkill == skill,
                            onTap: () {
                              setState(() => _selectedSkill = skill);
                              context
                                  .read<StartupCubit>()
                                  .loadTalent(skillFilter: skill);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: AppConstants.focusAreas.take(6).map(
                      (focus) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: focus,
                          isSelected: _selectedFocus == focus,
                          onTap: () {
                            setState(() => _selectedFocus = focus);
                            context
                                .read<StartupCubit>()
                                .loadTalent(focusFilter: focus);
                          },
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<StartupCubit, StartupState>(
              builder: (context, state) {
                if (state is StartupLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (state is TalentLoaded) {
                  if (state.students.isEmpty) {
                    return _EmptyState(
                      skillFilter: _selectedSkill,
                      focusFilter: _selectedFocus,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.students.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _StudentCard(student: state.students[index]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _userInitials(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.initials : 'S';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final UserModel student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(student.initials,
                      style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: AppTextStyles.headlineSm),
                    if (student.education != null)
                      Text(
                        student.education!,
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusAccepted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: AppColors.statusAccepted, size: 6),
                    const SizedBox(width: 4),
                    Text(
                      'Open',
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.statusAccepted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (student.shortPitch != null) ...[
            const SizedBox(height: 10),
            Text(
              student.shortPitch!,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (student.skills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: student.skills.take(4).map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skill,
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Invite to Apply',
                        style: AppTextStyles.labelMd.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Icon(Icons.bookmark_outline,
                      color: AppColors.onSurfaceVariant, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? skillFilter;
  final String? focusFilter;
  const _EmptyState({this.skillFilter, this.focusFilter});

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
              child: const Icon(Icons.people_outline,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No students found', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text(
              skillFilter != null || focusFilter != null
                  ? 'No students match this filter. Try removing some filters.'
                  : 'No students have enabled "Open to Opportunities" yet.',
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
