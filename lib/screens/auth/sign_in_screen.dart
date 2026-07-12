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

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _keepSignedIn = false;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _selectedRole,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.role == UserRole.admin) {
              Navigator.pushReplacementNamed(context, '/admin');
              return;
            }
            if (user.role == UserRole.startup && user.status == 'pending') {
              Navigator.pushReplacementNamed(context, '/pending');
              return;
            }
            if (!user.onboardingComplete) {
              if (user.role == UserRole.startup) {
                Navigator.pushReplacementNamed(context, '/onboarding/startup');
              } else {
                Navigator.pushReplacementNamed(context, '/onboarding/tailor-feed');
              }
            } else if (user.role == UserRole.student) {
              Navigator.pushReplacementNamed(context, '/student/home');
            } else {
              Navigator.pushReplacementNamed(context, '/startup/dashboard');
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ALU Connect',
                      style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                    ),
                    Row(
                      children: [
                        Text(
                          "Don't have an account?  ",
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/sign-up'),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text('Welcome Back', style: AppTextStyles.headlineLg),
                        const SizedBox(height: 6),
                        Text(
                          'Empowering the next generation of African entrepreneurs.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sign in as', style: AppTextStyles.labelLg),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = UserRole.student),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: _selectedRole == UserRole.student
                                                ? AppColors.primaryGradient
                                                : null,
                                            color: _selectedRole == UserRole.student
                                                ? null
                                                : AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedRole == UserRole.student
                                                  ? Colors.transparent
                                                  : AppColors.outlineVariant,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Student',
                                              style: AppTextStyles.labelLg.copyWith(
                                                color: _selectedRole == UserRole.student
                                                    ? Colors.white
                                                    : AppColors.onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _selectedRole = UserRole.startup),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: _selectedRole == UserRole.startup
                                                ? AppColors.primaryGradient
                                                : null,
                                            color: _selectedRole == UserRole.startup
                                                ? null
                                                : AppColors.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedRole == UserRole.startup
                                                  ? Colors.transparent
                                                  : AppColors.outlineVariant,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Startup',
                                              style: AppTextStyles.labelLg.copyWith(
                                                color: _selectedRole == UserRole.startup
                                                    ? Colors.white
                                                    : AppColors.onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                AppTextField(
                                  label: _selectedRole == UserRole.startup
                                      ? 'Email'
                                      : 'ALU Email',
                                  hint: _selectedRole == UserRole.startup
                                      ? 'founder@alueducation.com or @gmail.com'
                                      : 'j.example@alustudent.com',
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: AppColors.outline, size: 20),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Email is required';
                                    final lower = v.toLowerCase().trim();
                                    if (_selectedRole == UserRole.startup) {
                                      if (!lower.endsWith('@alueducation.com') &&
                                          !lower.endsWith('@gmail.com')) {
                                        return 'Use @alueducation.com or @gmail.com';
                                      }
                                    } else {
                                      if (!lower.endsWith('@alustudent.com') &&
                                          !lower.endsWith('@alueducation.com')) {
                                        return 'Only ALU emails allowed';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Password', style: AppTextStyles.labelLg),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'Forgot Password?',
                                        style: AppTextStyles.labelLg
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  hint: '••••••••',
                                  controller: _passwordCtrl,
                                  showToggle: true,
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: AppColors.outline, size: 20),
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Password is required' : null,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _keepSignedIn,
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4)),
                                      onChanged: (v) =>
                                          setState(() => _keepSignedIn = v ?? false),
                                    ),
                                    Text(
                                      'Keep me signed in on this device',
                                      style: AppTextStyles.bodyMd
                                          .copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) => AppButton(
                                    label: 'Sign In',
                                    isLoading: state is AuthLoading,
                                    icon: const Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 18),
                                    onPressed: _submit,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Need help accessing your account?  ',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.onSurfaceVariant),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Contact Support',
                                      style: AppTextStyles.labelLg
                                          .copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            '© 2026 ALU Connect. All rights reserved.',
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FooterLink('Privacy Policy'),
                            const SizedBox(width: 16),
                            _FooterLink('Terms of Service'),
                            const SizedBox(width: 16),
                            _FooterLink('Community Guidelines'),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
    );
  }
}
