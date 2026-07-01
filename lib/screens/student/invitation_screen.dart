import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/application/application_cubit.dart';
import '../../blocs/application/application_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';

class InvitationScreen extends StatelessWidget {
  final String applicationId;
  const InvitationScreen({super.key, required this.applicationId});

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
      body: BlocListener<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Invitation card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'INVITATION',
                        style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nexus AI Solutions',
                      style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "You've been invited to interview for the",
                      style: AppTextStyles.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Product Design Intern',
                        style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                        children: [
                          TextSpan(
                            text: ' role.',
                            style: AppTextStyles.bodyMd.copyWith(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PillRow(icon: Icons.calendar_today_outlined, label: 'Oct 24, 2023'),
                    const SizedBox(height: 8),
                    _PillRow(icon: Icons.schedule_outlined, label: '2:30 PM – 3:15 PM'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Message from founder
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.darkHeroGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Message from Sarah Chen', style: AppTextStyles.labelLg),
                            Text(
                              'Founder & CEO',
                              style: AppTextStyles.labelMd
                                  .copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '"Hi there! We were incredibly impressed by your portfolio projects, especially your recent work on the decentralized energy app. Your approach to user-centric design aligns perfectly with our vision at Nexus. I\'d love to chat more about how you could contribute to our upcoming Q4 initiatives."',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE ROLE',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RoleDetailRow(icon: Icons.bolt, label: 'Fast-paced R&D Team'),
                    const SizedBox(height: 8),
                    _RoleDetailRow(icon: Icons.attach_money, label: '\$2,500/mo + Equity'),
                    const SizedBox(height: 20),
                    Text(
                      'WHERE',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.videocam_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Google Meet', style: AppTextStyles.labelLg),
                              Text(
                                'Link provided on acceptance',
                                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Accept Invitation',
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation accepted! Meeting link will be emailed.')),
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reschedule',
                      isOutlined: true,
                      icon: const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 18),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Decline',
                      isOutlined: true,
                      icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                      backgroundColor: Colors.transparent,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PillRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _RoleDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RoleDetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.bodyMd),
      ],
    );
  }
}
