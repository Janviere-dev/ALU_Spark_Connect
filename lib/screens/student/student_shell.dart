import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'applications_screen.dart';
import 'profile_screen.dart';

class StudentShell extends StatefulWidget {
  final int initialIndex;
  const StudentShell({super.key, this.initialIndex = 0});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late int _currentIndex;

  final _screens = const [
    StudentHomeScreen(),
    StudentExploreScreen(),
    StudentApplicationsScreen(),
    StudentProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookmarkCubit>().load(authState.user.id);
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
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', index: 0, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore', index: 1, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Applications', index: 2, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', index: 3, currentIndex: _currentIndex, onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
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
