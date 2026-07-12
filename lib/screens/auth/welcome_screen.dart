import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserRole _selectedRole = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
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
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Hero — ALU branded banner
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: const _AluHeroBanner(),
                ),
              ),
              // Bottom card
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4)),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'I AM A...',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            title: 'Student',
                            subtitle: 'Seeking real-world experience & internships.',
                            icon: Icons.school_outlined,
                            isSelected: _selectedRole == UserRole.student,
                            onTap: () => setState(() => _selectedRole = UserRole.student),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            title: 'Startup',
                            subtitle: 'Looking for world-class African talent.',
                            icon: Icons.business_center_outlined,
                            isSelected: _selectedRole == UserRole.startup,
                            onTap: () => setState(() => _selectedRole = UserRole.startup),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Get Started',
                      icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/sign-up',
                        arguments: _selectedRole,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?  ',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/sign-in'),
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AluHeroBanner extends StatelessWidget {
  const _AluHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.darkHeroGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 60,
            spreadRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Purple radial glow behind logo
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 0.75,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.28),
                      AppColors.secondary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Subtle top-right glow
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryContainer.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-left glow
            Positioned(
              bottom: -40,
              left: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tertiary.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Floating role pills
            Positioned(
              top: 22,
              right: 22,
              child: _PurpleFloatingIcon(Icons.rocket_launch_outlined),
            ),
            Positioned(
              bottom: 26,
              left: 22,
              child: _PurpleFloatingIcon(Icons.school_outlined),
            ),
            // Main centred content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ALU logotype row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAluLetters(),
                      Container(
                        width: 1.5,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _UniNameLine('AFRICAN'),
                          _UniNameLine('LEADERSHIP'),
                          _UniNameLine('UNIVERSITY'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Gradient divider line
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.heroGradient.createShader(bounds),
                    child: Container(height: 1.5, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  // CONNECT wordmark
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.heroGradient.createShader(bounds),
                    child: const Text(
                      'C O N N E C T',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tagline
                  Text(
                    'Where ALU talent meets student-led ventures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12.5,
                      letterSpacing: 0.3,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAluLetters() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const _AluLetter(letter: 'A'),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const _AluLetter(letter: 'L'),
            Positioned(
              top: 8,
              right: 2,
              bottom: 6,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE01515),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ],
        ),
        const _AluLetter(letter: 'U'),
      ],
    );
  }
}

class _AluLetter extends StatelessWidget {
  final String letter;
  const _AluLetter({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 52,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        height: 1,
      ),
    );
  }
}

class _UniNameLine extends StatelessWidget {
  final String text;
  const _UniNameLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        height: 1.65,
      ),
    );
  }
}

class _PurpleFloatingIcon extends StatelessWidget {
  final IconData icon;
  const _PurpleFloatingIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: AppColors.primaryContainer.withValues(alpha: 0.7), size: 20),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.labelLg),
            const SizedBox(height: 4),
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
