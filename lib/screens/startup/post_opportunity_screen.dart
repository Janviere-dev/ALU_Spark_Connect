import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/startup/startup_cubit.dart';
import '../../blocs/startup/startup_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/opportunity_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_chip.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _compensationCtrl = TextEditingController();
  String? _selectedCategory;
  String _selectedCommitment = 'Part-time';
  String _selectedLocation = 'Remote';
  final List<String> _selectedSkills = [];

  final List<String> _commitmentOptions = ['Part-time', 'Full-time', 'Project-based'];
  final List<String> _locationOptions = ['Remote', 'On-site', 'Hybrid'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _compensationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final opportunity = OpportunityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startupId: authState.user.id,
      startupName: authState.user.ventureName ?? authState.user.fullName,
      roleTitle: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      category: _selectedCategory!,
      commitment: _selectedCommitment,
      location: _selectedLocation,
      duration: '3 months',
      isRemoteFriendly: _selectedLocation == 'Remote' || _selectedLocation == 'Hybrid',
      compensation: _compensationCtrl.text.trim().isNotEmpty
          ? _compensationCtrl.text.trim()
          : null,
      skills: _selectedSkills,
      postedAt: DateTime.now(),
    );

    context.read<StartupCubit>().postOpportunity(opportunity);
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
      ),
      body: BlocListener<StartupCubit, StartupState>(
        listener: (context, state) {
          if (state is OpportunityPostSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('Opportunity Posted!', style: AppTextStyles.headlineMd),
                    const SizedBox(height: 8),
                    Text(
                      '${state.opportunity.roleTitle} is now live and visible to students.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'View Dashboard',
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StartupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Post an Opportunity', style: AppTextStyles.headlineLg),
                const SizedBox(height: 4),
                Text(
                  'Find the right talent from the ALU community.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                _Card(
                  icon: Icons.work_outline,
                  title: 'Role Details',
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Role Title',
                        hint: 'e.g. Product Design Intern',
                        controller: _titleCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Role title is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Description',
                        hint: 'Describe the role, responsibilities, and what the intern will learn...',
                        controller: _descriptionCtrl,
                        maxLines: 5,
                        validator: (v) => (v == null || v.trim().length < 30)
                            ? 'Please write at least 30 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Compensation (optional)',
                        hint: 'e.g. \$1,000/mo or Equity only',
                        controller: _compensationCtrl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  icon: Icons.category_outlined,
                  title: 'Category',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.opportunityCategories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected ? null : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.outlineVariant,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: AppTextStyles.labelMd.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  icon: Icons.tune_outlined,
                  title: 'Logistics',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commitment', style: AppTextStyles.labelLg),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _commitmentOptions.map((opt) {
                          final isSelected = _selectedCommitment == opt;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCommitment = opt),
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
                                opt,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text('Location', style: AppTextStyles.labelLg),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _locationOptions.map((opt) {
                          final isSelected = _selectedLocation == opt;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedLocation = opt),
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
                                opt,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  icon: Icons.bolt_outlined,
                  title: 'Required Skills',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.skillsList.map((skill) {
                          final isSelected = _selectedSkills.contains(skill);
                          return SkillChip(
                            label: skill,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSkills.remove(skill);
                                } else {
                                  _selectedSkills.add(skill);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<StartupCubit, StartupState>(
                  builder: (context, state) => AppButton(
                    label: 'Post Opportunity',
                    isLoading: state is StartupLoading,
                    icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Card({required this.icon, required this.title, required this.child});

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
