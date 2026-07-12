import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../widgets/app_button.dart';

class WelcomeSplashScreen extends StatelessWidget {
  const WelcomeSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isStartup = authState is AuthAuthenticated &&
        authState.user.role == UserRole.startup;

    final destination =
        isStartup ? '/startup/dashboard' : '/student/home';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              // Illustration placeholder — circular gradient icon
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  isStartup
                      ? Icons.rocket_launch_rounded
                      : Icons.laptop_chromebook_rounded,
                  color: Colors.white,
                  size: 88,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                isStartup
                    ? 'Get talented students\nfor your ALU startup!'
                    : 'Find your dream job\nnow here!',
                style: AppTextStyles.headlineLg.copyWith(height: 1.25),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                isStartup
                    ? 'You\'re all set. Post roles, discover talent, and build your team from the ALU community.'
                    : 'Your profile is ready. Explore opportunities, apply to roles, and grow your career.',
                style: AppTextStyles.bodyLg
                    .copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              // Dot indicators
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == 2 ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 2
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: isStartup ? 'Go to Dashboard' : 'Explore Opportunities',
                icon: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  destination,
                  (route) => false,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  destination,
                  (route) => false,
                ),
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
