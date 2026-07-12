import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/startup_repository.dart';
import '../../widgets/skill_chip.dart';

class StartupPublicProfileScreen extends StatefulWidget {
  final String startupId;
  final String startupName;

  const StartupPublicProfileScreen({
    super.key,
    required this.startupId,
    required this.startupName,
  });

  @override
  State<StartupPublicProfileScreen> createState() =>
      _StartupPublicProfileScreenState();
}

class _StartupPublicProfileScreenState
    extends State<StartupPublicProfileScreen> {
  UserModel? _startup;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final profile = await context
          .read<StartupRepository>()
          .getPublicProfile(widget.startupId);
      if (mounted) {
        setState(() {
          _startup = profile;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.startupName, style: AppTextStyles.headlineSm),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant)))
              : _startup == null
                  ? _buildFallback()
                  : _buildProfile(_startup!),
    );
  }

  Widget _buildProfile(UserModel s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.darkHeroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      s.initials,
                      style: AppTextStyles.headlineMd
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.ventureName ?? s.fullName,
                        style: AppTextStyles.headlineSm
                            .copyWith(color: Colors.white),
                      ),
                      if (s.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              s.location!,
                              style: AppTextStyles.labelMd
                                  .copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Founder
          _InfoCard(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.primary,
            title: 'Founder',
            child: Text(s.founderName ?? s.fullName, style: AppTextStyles.bodyLg),
          ),

          // Mission
          if (s.shortPitch != null && s.shortPitch!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.rocket_launch_outlined,
              iconColor: const Color(0xFF7B5EA7),
              title: 'Mission',
              child: Text(s.shortPitch!, style: AppTextStyles.bodyLg),
            ),
          ],

          // Problem we solve
          if (s.problemStatement != null &&
              s.problemStatement!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.lightbulb_outline_rounded,
              iconColor: AppColors.secondary,
              title: 'Problem We Solve',
              child: Text(s.problemStatement!, style: AppTextStyles.bodyLg),
            ),
          ],

          // Team size
          if (s.teamSize != null) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.groups_outlined,
              iconColor: AppColors.statusShortlisted,
              title: 'Team Size',
              child: Text(s.teamSize!, style: AppTextStyles.bodyLg),
            ),
          ],

          // Focus areas
          if (s.focusAreas.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.explore_outlined,
              iconColor: AppColors.tertiary,
              title: 'Focus Areas',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    s.focusAreas.map((a) => SkillChip(label: a)).toList(),
              ),
            ),
          ],

          // ALU community impact
          if (s.impact != null && s.impact!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF2E7D8C),
              title: 'Impact at ALU',
              child: Text(s.impact!, style: AppTextStyles.bodyLg),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.darkHeroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.business,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.startupName,
                    style: AppTextStyles.headlineSm
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Full profile not available yet.\nThis startup hasn\'t completed their venture profile.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
