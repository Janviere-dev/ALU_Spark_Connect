import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';
import '../../blocs/onboarding/onboarding_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_chip.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();

  @override
  void dispose() {
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
    _githubCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.isComplete) {
            Navigator.pushReplacementNamed(context, '/student/home');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 1.0,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Step 3 of 3',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete Your Profile', style: AppTextStyles.headlineLg),
                        const SizedBox(height: 6),
                        Text(
                          'The more complete your profile, the better we match you to opportunities.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),

                        // Skills section
                        _SectionCard(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Skills & Expertise',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select your top skills',
                                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: AppConstants.skillsList.map((skill) {
                                  final selected = state.selectedSkills.contains(skill);
                                  return SkillChip(
                                    label: skill,
                                    isSelected: selected,
                                    onTap: () => context.read<OnboardingCubit>().toggleSkill(skill),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Availability section
                        _SectionCard(
                          icon: Icons.schedule_outlined,
                          title: 'Availability',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hours per week',
                                style: AppTextStyles.labelLg,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: AppConstants.availabilityOptions.map((opt) {
                                  final selected = state.availability == opt;
                                  return SkillChip(
                                    label: opt,
                                    isSelected: selected,
                                    onTap: () => context.read<OnboardingCubit>().setAvailability(opt),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Text('Preferred start date', style: AppTextStyles.labelLg),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: AppConstants.startDateOptions.map((opt) {
                                  final selected = state.startDate == opt;
                                  return SkillChip(
                                    label: opt,
                                    isSelected: selected,
                                    onTap: () => context.read<OnboardingCubit>().setStartDate(opt),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Digital presence section
                        _SectionCard(
                          icon: Icons.link,
                          title: 'Digital Presence',
                          child: Column(
                            children: [
                              AppTextField(
                                hint: 'linkedin.com/in/yourprofile',
                                controller: _linkedinCtrl,
                                prefixIcon: const Icon(Icons.alternate_email, color: AppColors.outline, size: 20),
                                onChanged: (v) => context.read<OnboardingCubit>().setLinkedinUrl(v),
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                hint: 'yourportfolio.com',
                                controller: _portfolioCtrl,
                                prefixIcon: const Icon(Icons.language, color: AppColors.outline, size: 20),
                                onChanged: (v) => context.read<OnboardingCubit>().setPortfolioUrl(v),
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                hint: 'github.com/yourusername',
                                controller: _githubCtrl,
                                prefixIcon: const Icon(Icons.code, color: AppColors.outline, size: 20),
                                onChanged: (v) => context.read<OnboardingCubit>().setGithubUrl(v),
                              ),
                            ],
                          ),
                        ),
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
                          label: 'Finish Setup',
                          isLoading: state.isLoading,
                          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          onPressed: () => context.read<OnboardingCubit>().completeOnboarding(user),
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
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
