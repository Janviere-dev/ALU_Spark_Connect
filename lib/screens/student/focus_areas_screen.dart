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
import '../../widgets/app_header.dart';

class FocusAreasScreen extends StatefulWidget {
  const FocusAreasScreen({super.key});

  @override
  State<FocusAreasScreen> createState() => _FocusAreasScreenState();
}

class _FocusAreasScreenState extends State<FocusAreasScreen> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _selected = List.from(authState.user.focusAreas);
      context.read<ProfileCubit>().load(authState.user);
    } else {
      _selected = [];
    }
  }

  void _toggle(String area) {
    setState(() {
      _selected.contains(area)
          ? _selected.remove(area)
          : _selected.add(area);
    });
  }

  Future<void> _save() async {
    await context.read<ProfileCubit>().saveFocusAreas(List.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showBack: true,
        title: 'ALU Connect',
        userInitials: authState is AuthAuthenticated
            ? authState.user.initials
            : 'U',
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaveSuccess) {
            context.read<AuthBloc>().add(AuthUserUpdated(state.user));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Focus areas updated')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Focus Areas', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 4),
                  Text(
                    'Choose the domains you\'re passionate about. Startups will use these to find you.',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selected.length} selected',
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.focusAreas.map((area) {
                    final isSelected = _selected.contains(area);
                    return GestureDetector(
                      onTap: () => _toggle(area),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected ? AppColors.primaryGradient : null,
                          color: isSelected
                              ? null
                              : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.outlineVariant,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              area,
                              style: AppTextStyles.labelMd.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) => AppButton(
                  label: 'Save Focus Areas',
                  isLoading: state is ProfileLoading,
                  onPressed: _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
