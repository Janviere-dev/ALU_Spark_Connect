import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'section_header.dart';

class ALUAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final String? userInitials;
  final String? avatarUrl;
  final bool showNotification;
  final bool showSettings;
  final int notificationCount;
  final VoidCallback? onNotification;
  final VoidCallback? onSettings;
  final VoidCallback? onAvatar;

  const ALUAppBar({
    super.key,
    this.title = 'ALU Connect',
    this.showBack = false,
    this.userInitials,
    this.avatarUrl,
    this.showNotification = false,
    this.showSettings = false,
    this.notificationCount = 0,
    this.onNotification,
    this.onSettings,
    this.onAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.rocket_launch, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
      leadingWidth: showBack ? 40 : 52,
      title: Text(
        title,
        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
      ),
      actions: [
        if (showNotification)
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
                onPressed: onNotification,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        if (showSettings)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
            onPressed: onSettings,
          ),
        if (userInitials != null)
          GestureDetector(
            onTap: onAvatar,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: UserAvatar(
                initials: userInitials!,
                imageUrl: avatarUrl,
                size: 36,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
