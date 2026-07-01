import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../blocs/profile/profile_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_chip.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _pitchCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileCubit>().load(authState.user);
    }
  }

  void _initControllers(ProfileLoaded state) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = state.user.fullName;
    _educationCtrl.text = state.user.education ?? '';
    _pitchCtrl.text = state.user.shortPitch ?? '';
    _portfolioCtrl.text = state.user.portfolioUrl ?? '';
    _linkedinCtrl.text = state.user.linkedinUrl ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _educationCtrl.dispose();
    _pitchCtrl.dispose();
    _portfolioCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
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
        title: Text('ALU Ventures', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
            onPressed: () => Navigator.pushNamed(context, '/student/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text('JM', style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaveSuccess) {
            context.read<AuthBloc>().add(AuthUserUpdated(state.user));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile saved successfully!')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _initControllers(state);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Edit Profile', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 4),
                  Text(
                    'Update your venture identity and academic details.',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              state.user.initials,
                              style: AppTextStyles.headlineLg.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Change Profile Picture',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Recommended: Square, min 400×400px',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    icon: Icons.person_outline,
                    title: 'Basic Information',
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          hint: 'Your full name',
                          controller: _nameCtrl,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Education',
                          hint: 'e.g. Global Challenges & Entrepreneurship',
                          controller: _educationCtrl,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Short Pitch',
                          hint: 'Tell startups about yourself in a few sentences...',
                          controller: _pitchCtrl,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Portfolio & Skills',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bolt, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text('Core Skills',
                                          style: AppTextStyles.labelLg
                                              .copyWith(color: Colors.white)),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => _showSkillPicker(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Add New',
                                        style: AppTextStyles.labelSm
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: state.editSkills
                                    .map((skill) => SkillChip(
                                          label: skill,
                                          isSelected: true,
                                          isRemovable: true,
                                          onRemove: () =>
                                              context.read<ProfileCubit>().removeSkill(skill),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.link,
                    title: 'Digital Presence',
                    child: Column(
                      children: [
                        _LinkField(
                          icon: Icons.language,
                          label: 'PORTFOLIO',
                          controller: _portfolioCtrl,
                          hint: 'https://yourportfolio.com',
                        ),
                        const SizedBox(height: 12),
                        _LinkField(
                          icon: Icons.alternate_email,
                          label: 'LINKEDIN',
                          controller: _linkedinCtrl,
                          hint: 'linkedin.com/in/yourprofile',
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.outlineVariant, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text('Add Another Link',
                                    style: AppTextStyles.labelLg
                                        .copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, profileState) => AppButton(
                      label: 'Save Profile',
                      isLoading: profileState is ProfileLoading,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      onPressed: () {
                        context.read<ProfileCubit>().save(
                              fullName: _nameCtrl.text,
                              education: _educationCtrl.text,
                              shortPitch: _pitchCtrl.text,
                              portfolioUrl: _portfolioCtrl.text,
                              linkedinUrl: _linkedinCtrl.text,
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Discard changes',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        },
      ),
    );
  }

  void _showSkillPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Skills', style: AppTextStyles.headlineSm),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final current =
                          state is ProfileLoaded ? state.editSkills : <String>[];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.skillsList
                            .where((s) => !current.contains(s))
                            .map((skill) => SkillChip(
                                  label: skill,
                                  onTap: () {
                                    context.read<ProfileCubit>().addSkill(skill);
                                    Navigator.pop(ctx);
                                  },
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.onSurface, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headlineSm),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LinkField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hint;

  const _LinkField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                TextField(
                  controller: controller,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
