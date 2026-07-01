import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';
import '../../blocs/onboarding/onboarding_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/skill_chip.dart';

class TailorFeedScreen extends StatelessWidget {
  const TailorFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<OnboardingCubit, OnboardingState>(
          listener: (context, state) {
            if (state.isComplete) {
              if (user.role == UserRole.student) {
                Navigator.pushReplacementNamed(context, '/onboarding/complete-profile');
              } else {
                Navigator.pushReplacementNamed(context, '/startup/dashboard');
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 2 / 3,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Step 2 of 3', style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Let's tailor your feed", style: AppTextStyles.headlineLg),
                        const SizedBox(height: 6),
                        Text(
                          'Help us connect you with the right opportunities by confirming your path.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                title: 'Student',
                                subtitle: 'Seeking roles & growth',
                                icon: Icons.school_outlined,
                                isSelected: user.role == UserRole.student,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                title: 'Startup',
                                subtitle: 'Hiring & scaling talent',
                                icon: Icons.rocket_launch_outlined,
                                isSelected: user.role == UserRole.startup,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Focus Areas', style: AppTextStyles.headlineSm),
                            Text(
                              'Select 3+',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppConstants.focusAreas.map((area) {
                            final selected = state.selectedFocusAreas.contains(area);
                            return FocusAreaChip(
                              label: area,
                              isSelected: selected,
                              onTap: () => context.read<OnboardingCubit>().toggleFocusArea(area),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),
                        Text('You might like', style: AppTextStyles.headlineSm),
                        const SizedBox(height: 12),
                        _YouMightLikeCard(),
                        const SizedBox(height: 32),
                        if (state.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              state.error!,
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        AppButton(
                          label: 'Complete Profile',
                          isLoading: state.isLoading,
                          icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          onPressed: () {
                            if (user.role == UserRole.startup) {
                              context.read<OnboardingCubit>().completeOnboarding(user);
                            } else {
                              Navigator.pushNamed(context, '/onboarding/complete-profile');
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.read<OnboardingCubit>().skipOnboarding(user),
                            child: Text(
                              'Skip for now',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headlineSm.copyWith(
              color: isSelected ? AppColors.primary : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _YouMightLikeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.darkHeroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Early Bird Ventures',
                  style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                ),
                Text(
                  'AI Startup Program',
                  style: AppTextStyles.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Top Match', style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
