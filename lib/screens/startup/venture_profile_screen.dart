import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/skill_chip.dart';

class VentureProfileScreen extends StatelessWidget {
  const VentureProfileScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.darkHeroGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.initials ?? 'S',
                        style:
                            AppTextStyles.headlineSm.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.ventureName ?? 'Your Venture',
                          style: AppTextStyles.headlineSm
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          user?.email ?? '',
                          style: AppTextStyles.bodyMd.copyWith(
                              color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Venture Profile', style: AppTextStyles.headlineLg),
            const SizedBox(height: 4),
            Text(
              'Details students see when exploring your startup.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _ProfileCard(
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.primary,
              title: 'Founder',
              content: user?.founderName ?? user?.fullName,
              emptyLabel: 'Founder name not set.',
            ),
            const SizedBox(height: 16),
            _ProfileCard(
              icon: Icons.flag_outlined,
              iconColor: AppColors.primary,
              title: 'Mission',
              content: user?.shortPitch,
              emptyLabel: 'No mission set yet.',
            ),
            const SizedBox(height: 16),
            _ProfileCard(
              icon: Icons.lightbulb_outline,
              iconColor: AppColors.tertiary,
              title: 'Problem We Solve',
              content: user?.problemStatement,
              emptyLabel: 'No problem statement set yet.',
            ),
            const SizedBox(height: 16),
            _ProfileCard(
              icon: Icons.people_outline,
              iconColor: AppColors.secondary,
              title: 'Team Size',
              content: user?.teamSize != null ? '${user!.teamSize} members' : null,
              emptyLabel: 'Team size not specified.',
            ),
            const SizedBox(height: 16),
            if ((user?.focusAreas ?? []).isNotEmpty)
              _ChipsCard(
                icon: Icons.explore_outlined,
                iconColor: const Color(0xFF7B5EA7),
                title: 'Focus Areas',
                chips: user!.focusAreas,
              )
            else
              _ProfileCard(
                icon: Icons.explore_outlined,
                iconColor: const Color(0xFF7B5EA7),
                title: 'Focus Areas',
                content: null,
                emptyLabel: 'No focus areas added yet.',
              ),
            const SizedBox(height: 16),
            _ProfileCard(
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF2E7D8C),
              title: 'Impact at ALU',
              content: user?.impact,
              emptyLabel: 'No impact statement added yet.',
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/onboarding/startup'),
                child: Center(
                  child: Text(
                    'Edit Venture Profile',
                    style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? content;
  final String emptyLabel;

  const _ProfileCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.headlineSm),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content ?? emptyLabel,
            style: AppTextStyles.bodyMd.copyWith(
              color: content != null
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> chips;

  const _ChipsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.headlineSm),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((c) => SkillChip(label: c, isSelected: true)).toList(),
          ),
        ],
      ),
    );
  }
}
