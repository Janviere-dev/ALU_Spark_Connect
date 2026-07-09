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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (!state.user.onboardingComplete) {
              Navigator.pushReplacementNamed(context, '/onboarding/tailor-feed');
            } else if (state.user.role == UserRole.student) {
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
                                AppTextField(
                                  label: 'ALU Email',
                                  hint: 'j.example@alustudent.com',
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: AppColors.outline, size: 20),
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
                            '© 2024 ALU Connect. All rights reserved.',
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
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _emailCtrl.text = 'amina.okoro@alustudent.com';
                              _passwordCtrl.text = 'password123';
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Demo: Fill student credentials',
                                style: AppTextStyles.labelSm
                                    .copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _emailCtrl.text = 'john.doe@alueducation.com';
                              _passwordCtrl.text = 'password123';
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Demo: Fill startup credentials',
                                style: AppTextStyles.labelSm
                                    .copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ),
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
