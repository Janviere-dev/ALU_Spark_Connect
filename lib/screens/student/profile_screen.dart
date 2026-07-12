import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/application/application_cubit.dart';
import '../../blocs/application/application_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/application_model.dart';
import '../../widgets/app_header.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ApplicationCubit>().loadForStudent(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        title: 'Profile',
        userInitials: user?.initials ?? 'U',
        showNotification: true,
        showSettings: true,
        onNotification: () =>
            Navigator.pushNamed(context, '/student/notifications'),
        onSettings: () => Navigator.pushNamed(context, '/student/settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Avatar + name + location 
            Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.initials ?? 'U',
                      style: AppTextStyles.headlineLg.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? '',
                  style: AppTextStyles.headlineSm,
                  textAlign: TextAlign.center,
                ),
                if (user?.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        user!.location!,
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            //  Stats row 
            BlocBuilder<ApplicationCubit, ApplicationState>(
              builder: (context, state) {
                final apps = state is ApplicationsLoaded ? state.applications : [];
                final shortlisted = apps
                    .where((a) =>
                        a.status == ApplicationStatus.shortlisted ||
                        a.status == ApplicationStatus.interviewScheduled)
                    .length;
                final accepted = apps
                    .where((a) => a.status == ApplicationStatus.accepted)
                    .length;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                      _Stat(value: '${apps.length}', label: 'Applications'),
                      _StatDivider(),
                      _Stat(value: '$shortlisted', label: 'Shortlisted'),
                      _StatDivider(),
                      _Stat(value: '$accepted', label: 'Accepted'),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            //  Menu items 
            _MenuTile(
              icon: Icons.person_outline,
              iconColor: AppColors.primary,
              title: 'My Profile',
              subtitle: 'Edit your info, bio & links',
              onTap: () => Navigator.pushNamed(context, '/student/edit-profile'),
            ),
            _MenuTile(
              icon: Icons.auto_awesome_outlined,
              iconColor: const Color(0xFF7B5EA7),
              title: 'Skills & Interests',
              subtitle: 'Update skills and focus areas',
              onTap: () => Navigator.pushNamed(context, '/student/skills'),
            ),
            _MenuTile(
              icon: Icons.bookmark_outline,
              iconColor: const Color(0xFF2E7D8C),
              title: 'Saved Opportunities',
              subtitle: 'Roles you bookmarked',
              onTap: () => Navigator.pushNamed(context, '/student/saved'),
            ),
            _MenuTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFE67E22),
              title: 'Notifications',
              subtitle: 'Invitations and updates',
              onTap: () => Navigator.pushNamed(context, '/student/notifications'),
            ),
            _MenuTile(
              icon: Icons.help_outline,
              iconColor: AppColors.onSurfaceVariant,
              title: 'Help & Support',
              subtitle: 'FAQs, guides & chat support',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            //  Logout 
            GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(AuthSignOutRequested());
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: AppTextStyles.labelLg
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headlineSm
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSm
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.outlineVariant);
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: AppTextStyles.labelLg),
        subtitle: Text(subtitle,
            style: AppTextStyles.labelMd
                .copyWith(color: AppColors.onSurfaceVariant)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
        onTap: onTap,
      ),
    );
  }
}
