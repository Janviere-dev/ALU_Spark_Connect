import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole initialRole;
  const SignUpScreen({super.key, this.initialRole = UserRole.student});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ventureCtrl = TextEditingController();
  late UserRole _role;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ventureCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service.')),
      );
      return;
    }
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(AuthSignUpRequested(
          fullName: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          role: _role,
          ventureName: _role == UserRole.startup ? _ventureCtrl.text : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/onboarding/tailor-feed');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ALU Connect',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Build Your Future', style: AppTextStyles.headlineLg),
                  const SizedBox(height: 6),
                  Text(
                    'Join the ecosystem where students and startups converge to create impact across Africa.',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleToggle(
                          title: 'I am a Student',
                          subtitle: 'Seeking opportunities and mentorship.',
                          icon: Icons.school_outlined,
                          isSelected: _role == UserRole.student,
                          onTap: () => setState(() => _role = UserRole.student),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleToggle(
                          title: 'I am a Startup',
                          subtitle: 'Looking for talent and venture support.',
                          icon: Icons.rocket_launch_outlined,
                          isSelected: _role == UserRole.startup,
                          onTap: () => setState(() => _role = UserRole.startup),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.outline, size: 20),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_role == UserRole.startup) ...[
                    AppTextField(
                      label: 'Venture Name',
                      hint: 'My Awesome Startup',
                      controller: _ventureCtrl,
                      prefixIcon:
                          const Icon(Icons.business_outlined, color: AppColors.outline, size: 20),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Venture name is required' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    label: 'ALU Email',
                    hint: 'j.doe@alueducation.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: AppColors.outline, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      final lower = v.toLowerCase().trim();
                      if (!lower.endsWith('@alustudent.com') &&
                          !lower.endsWith('@alueducation.com')) {
                        return 'Only ALU emails allowed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordCtrl,
                    showToggle: true,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline, size: 20),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Create Account',
                      isLoading: state is AuthLoading,
                      icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?  ',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/sign-in'),
                          child: Text(
                            'Log In',
                            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
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
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.labelLg.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
