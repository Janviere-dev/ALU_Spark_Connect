import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/startup/startup_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'dashboard_screen.dart';
import 'talent_explore_screen.dart';
import 'applicants_screen.dart';
import 'settings_screen.dart';

class StartupShell extends StatefulWidget {
  final int initialIndex;
  const StartupShell({super.key, this.initialIndex = 0});

  @override
  State<StartupShell> createState() => _StartupShellState();
}

class _StartupShellState extends State<StartupShell> {
  late int _currentIndex;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookmarkCubit>().load(authState.user.id);
    }
    // Pre-load talent if that is the opening tab
    if (widget.initialIndex == 1) {
      context.read<StartupCubit>().loadTalent();
    }
    _screens = [
      StartupDashboardScreen(
        onSwitchToTalent: () => _onTap(1),
        onSwitchToApplicants: () => _onTap(2),
      ),
      const TalentExploreScreen(),
      const ApplicantsScreen(),
      const StartupSettingsScreen(),
    ];
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      context.read<StartupCubit>().loadTalent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Home', index: 0, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Talent', index: 1, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'Applicants', index: 2, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', index: 3, currentIndex: _currentIndex, onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(activeIcon, color: AppColors.primary, size: 22),
              )
            else
              Icon(icon, color: AppColors.outline, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isActive ? AppColors.primary : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
