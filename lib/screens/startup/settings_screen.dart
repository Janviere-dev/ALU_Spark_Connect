import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';

class StartupSettingsScreen extends StatelessWidget {
  const StartupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: false,
        userInitials: user?.initials ?? 'S',
        onNotification: () => Navigator.pushNamed(context, '/startup/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.darkHeroGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.ventureName ?? 'Your Venture',
                            style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                          ),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMd
                                .copyWith(color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _SettingsSection(
              label: 'VENTURE',
              items: [
                _Item(
                  icon: Icons.business_outlined,
                  iconBg: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  title: 'Venture Profile',
                  subtitle: 'Update your startup details',
                  onTap: () {},
                ),
                _Item(
                  icon: Icons.people_outline,
                  iconBg: AppColors.secondary.withValues(alpha: 0.1),
                  iconColor: AppColors.secondary,
                  title: 'Team Members',
                  subtitle: 'Invite co-founders and admins',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              label: 'POSTINGS',
              items: [
                _Item(
                  icon: Icons.work_outline,
                  iconBg: AppColors.tertiary.withValues(alpha: 0.1),
                  iconColor: AppColors.tertiary,
                  title: 'Manage Opportunities',
                  subtitle: 'Edit, pause, or close postings',
                  onTap: () {},
                ),
                _Item(
                  icon: Icons.bar_chart_outlined,
                  iconBg: AppColors.statusUnderReview.withValues(alpha: 0.1),
                  iconColor: AppColors.statusUnderReview,
                  title: 'Analytics',
                  subtitle: 'Views, clicks, and conversion',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              label: 'SUPPORT',
              items: [
                _Item(
                  icon: Icons.help_outline,
                  iconBg: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Help & Documentation',
                  subtitle: 'Guides and FAQs for founders',
                  onTap: () {},
                ),
                _Item(
                  icon: Icons.info_outline,
                  iconBg: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Legal & Terms',
                  subtitle: 'Privacy policy & Terms of Service',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(AuthSignOutRequested());
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Text('Logout', style: AppTextStyles.labelLg.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'App Version 1.0.0 (Build 1)',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String label;
  final List<_Item> items;
  const _SettingsSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 20),
              ),
              title: Text(item.title, style: AppTextStyles.labelLg),
              subtitle: Text(
                item.subtitle,
                style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
              onTap: item.onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
