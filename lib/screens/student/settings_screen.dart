import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_header.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileCubit>().load(authState.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showNotification: true,
        showSettings: false,
        userInitials: user?.initials ?? 'U',
        notificationCount: 3,
        onNotification: () => Navigator.pushNamed(context, '/student/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (user != null)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/student/edit-profile'),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                            Text(user.fullName, style: AppTextStyles.headlineSm),
                            Text(
                              user.email,
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _SettingsSection(
              label: 'SECURITY & ACCESS',
              items: [
                _SettingsItem(
                  icon: Icons.lock_outline,
                  iconBg: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  title: 'Account Security',
                  subtitle: '2FA, Password, & Login alerts',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.devices_outlined,
                  iconBg: AppColors.secondary.withValues(alpha: 0.1),
                  iconColor: AppColors.secondary,
                  title: 'Linked Devices',
                  subtitle: 'Manage where you\'re logged in',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              label: 'PERSONAL DATA',
              items: [
                _SettingsItem(
                  icon: Icons.shield_outlined,
                  iconBg: AppColors.tertiary.withValues(alpha: 0.1),
                  iconColor: AppColors.tertiary,
                  title: 'Privacy Settings',
                  subtitle: 'Profile visibility & data sharing',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.history,
                  iconBg: AppColors.statusUnderReview.withValues(alpha: 0.1),
                  iconColor: AppColors.statusUnderReview,
                  title: 'Activity Log',
                  subtitle: 'Review your interactions',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'ALERTS',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.error, size: 20),
                    ),
                    title: Text('Notification Preferences', style: AppTextStyles.labelLg),
                    subtitle: Text(
                      'Push, Email, and SMS',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              label: 'SUPPORT',
              items: [
                _SettingsItem(
                  icon: Icons.help_outline,
                  iconBg: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Help & Support',
                  subtitle: 'FAQs, Guides & Chat support',
                  onTap: () {},
                ),
                _SettingsItem(
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
                    Text(
                      'Logout',
                      style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
                    ),
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
  final List<_SettingsItem> items;
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

class _SettingsItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
