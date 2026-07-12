import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/opportunity_model.dart';
import 'skill_chip.dart';

class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryIcon(category: opportunity.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opportunity.roleTitle,
                      style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${opportunity.startupName} • ${opportunity.location}',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: opportunity.skills
                        .take(2)
                        .map((s) => SkillChip(label: s))
                        .toList(),
                  ),
                  if (opportunity.deadline != null) ...[
                    const SizedBox(height: 8),
                    _DeadlineBadge(opportunity: opportunity),
                  ],
                ],
              ),
            ),
            if (onBookmark != null)
              GestureDetector(
                onTap: onBookmark,
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primary : AppColors.outline,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FeaturedOpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  final VoidCallback? onApply;

  const FeaturedOpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FEATURED OPPORTUNITY',
                style: AppTextStyles.labelSm.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.roleTitle,
                        style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${opportunity.startupName} • ${opportunity.location}',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                if (opportunity.isRemoteFriendly)
                  _GlassTag('Remote Friendly'),
                _GlassTag(opportunity.duration),
                if (opportunity.equityOffered)
                  _GlassTag('Equity Offered'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Apply Now',
                  style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassTag extends StatelessWidget {
  final String label;
  const _GlassTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
    );
  }
}

class RecommendedCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  final VoidCallback? onApply;
  final bool isNew;

  const RecommendedCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.onApply,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.pinkGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(Icons.work_outline, color: Colors.white, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          opportunity.roleTitle,
                          style: AppTextStyles.labelLg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statusAcceptedBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'New',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.statusAccepted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${opportunity.startupName} • ${opportunity.location}',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: opportunity.skills
                        .take(2)
                        .map((s) => SkillChip(label: s))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onApply ?? onTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Apply Now',
                          style: AppTextStyles.labelMd.copyWith(color: Colors.white),
                        ),
                      ),
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
}

class _DeadlineBadge extends StatelessWidget {
  final OpportunityModel opportunity;
  const _DeadlineBadge({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final daysLeft = opportunity.deadline!.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    final color = isUrgent ? const Color(0xFFE53935) : AppColors.onSurfaceVariant;
    final bgColor = isUrgent
        ? const Color(0xFFE53935).withValues(alpha: 0.08)
        : AppColors.surfaceContainerLow;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.alarm_outlined, size: 13, color: color),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            opportunity.deadlineLabel,
            style: AppTextStyles.labelSm.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;
  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconData();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  (IconData, Color) _iconData() {
    switch (category) {
      case 'Engineering':
        return (Icons.code, AppColors.secondary);
      case 'Design':
        return (Icons.palette_outlined, AppColors.tertiary);
      case 'Marketing':
        return (Icons.campaign_outlined, AppColors.statusInterview);
      case 'Operations':
        return (Icons.business_center_outlined, AppColors.statusShortlisted);
      case 'Data & Analytics':
        return (Icons.bar_chart, AppColors.primary);
      case 'Content Creation':
        return (Icons.edit_outlined, AppColors.statusUnderReview);
      default:
        return (Icons.rocket_launch_outlined, AppColors.primary);
    }
  }
}
