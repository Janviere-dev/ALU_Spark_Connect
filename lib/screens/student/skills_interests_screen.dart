import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/skill_chip.dart';

class SkillsInterestsScreen extends StatelessWidget {
  const SkillsInterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        return _SkillsInterestsView(user: user);
      },
    );
  }
}

class _SkillsInterestsView extends StatelessWidget {
  final UserModel? user;
  const _SkillsInterestsView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showBack: true,
        title: 'ALU Connect',
        userInitials: user?.initials ?? 'U',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Skills & Interests', style: AppTextStyles.headlineLg),
            const SizedBox(height: 4),
            Text(
              'Your skills and focus areas shown to startups.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              icon: Icons.bolt_outlined,
              iconColor: AppColors.primary,
              title: 'Your Skills',
              emptyLabel: 'No skills added yet.',
              chips: user?.skills ?? [],
              onEdit: () =>
                  Navigator.pushNamed(context, '/student/edit-profile'),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.explore_outlined,
              iconColor: const Color(0xFF7B5EA7),
              title: 'Focus Areas',
              emptyLabel: 'No focus areas added yet.',
              chips: user?.focusAreas ?? [],
              onEdit: () =>
                  Navigator.pushNamed(context, '/student/focus-areas'),
            ),
            const SizedBox(height: 16),
            _OpenToWork(user: user),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String emptyLabel;
  final List<String> chips;
  final VoidCallback onEdit;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.emptyLabel,
    required this.chips,
    required this.onEdit,
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
              Expanded(
                child: Text(title, style: AppTextStyles.headlineSm),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('Edit',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (chips.isEmpty)
            Text(emptyLabel,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((c) => SkillChip(label: c, isSelected: true))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _OpenToWork extends StatelessWidget {
  final UserModel? user;
  const _OpenToWork({required this.user});

  @override
  Widget build(BuildContext context) {
    final isOpen = user?.isOpenToOpportunities ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.statusAccepted.withValues(alpha: 0.06)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? AppColors.statusAccepted.withValues(alpha: 0.3)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isOpen ? AppColors.statusAccepted : AppColors.outline)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOpen
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              color: isOpen ? AppColors.statusAccepted : AppColors.outline,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Open to Opportunities' : 'Not Currently Available',
                  style: AppTextStyles.labelLg,
                ),
                Text(
                  isOpen
                      ? 'Startups can find and invite you.'
                      : 'You won\'t appear in talent search.',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/student/edit-profile'),
            child: Text(
              'Change',
              style: AppTextStyles.labelMd
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
