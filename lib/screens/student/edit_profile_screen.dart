import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  String? _pickedImagePath;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedImagePath = result.files.single.path!);
    }
  }

  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _pitchCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  bool _initialized = false;

  // Extra dynamic links: list of {label, controller}
  final List<Map<String, dynamic>> _extraLinks = [];

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
    _locationCtrl.text = state.user.location ?? '';
    _educationCtrl.text = state.user.education ?? '';
    _pitchCtrl.text = state.user.shortPitch ?? '';
    _portfolioCtrl.text = state.user.portfolioUrl ?? '';
    _linkedinCtrl.text = state.user.linkedinUrl ?? '';
  }

  void _addLink() {
    showDialog(
      context: context,
      builder: (ctx) {
        final labelCtrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Link', style: AppTextStyles.headlineSm),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Label (e.g. GitHub, Behance)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                final label = labelCtrl.text.trim();
                if (label.isNotEmpty) {
                  setState(() => _extraLinks.add({
                    'label': label.toUpperCase(),
                    'controller': TextEditingController(),
                  }));
                }
                Navigator.pop(ctx);
              },
              child: Text('Add', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _educationCtrl.dispose();
    _pitchCtrl.dispose();
    _portfolioCtrl.dispose();
    _linkedinCtrl.dispose();
    for (final link in _extraLinks) {
      (link['controller'] as TextEditingController).dispose();
    }
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
        title: Text('ALU Connect', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
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
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: _pickedImagePath == null
                                  ? AppColors.primaryGradient
                                  : null,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _pickedImagePath != null
                                  ? Image.file(
                                      File(_pickedImagePath!),
                                      fit: BoxFit.cover,
                                      width: 88,
                                      height: 88,
                                    )
                                  : state.user.avatarUrl != null
                                      ? Image.network(
                                          state.user.avatarUrl!,
                                          fit: BoxFit.cover,
                                          width: 88,
                                          height: 88,
                                        )
                                      : Center(
                                          child: Text(
                                            state.user.initials,
                                            style: AppTextStyles.headlineLg
                                                .copyWith(color: Colors.white),
                                          ),
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
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Text(
                        'Change Profile Picture',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                      ),
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
                          label: 'Location',
                          hint: 'Kigali, Rwanda',
                          controller: _locationCtrl,
                          prefixIcon: const Icon(Icons.location_on_outlined,
                              color: AppColors.outline, size: 20),
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
                        ..._extraLinks.asMap().entries.map((entry) {
                          final i = entry.key;
                          final link = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _LinkField(
                                    icon: Icons.link,
                                    label: link['label'] as String,
                                    controller: link['controller'] as TextEditingController,
                                    hint: 'https://',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    (link['controller'] as TextEditingController).dispose();
                                    _extraLinks.removeAt(i);
                                  }),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _addLink,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.outlineVariant),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text('Add Another Link',
                                    style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
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
                              avatarUrl: _pickedImagePath,
                              location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
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
          initialChildSize: 0.65,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Skills', style: AppTextStyles.headlineSm),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _addCustomSkillToProfile(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('Custom', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a skill to add it. Can\'t find yours? Use Custom.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final current =
                          state is ProfileLoaded ? state.editSkills : <String>[];
                      return SingleChildScrollView(
                        controller: controller,
                        child: Wrap(
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
                        ),
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

  void _addCustomSkillToProfile(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Custom Skill', style: AppTextStyles.headlineSm),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Solidity, Blender, Swahili...',
            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              final skill = ctrl.text.trim();
              if (skill.isNotEmpty) {
                context.read<ProfileCubit>().addSkill(skill);
              }
              Navigator.pop(ctx);
            },
            child: Text('Add', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
          ),
        ],
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
