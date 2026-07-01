import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/application_model.dart';
import '../data/models/opportunity_model.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: AppTextStyles.labelSm.copyWith(color: color, letterSpacing: 0.5),
      ),
    );
  }

  (Color, Color) _colors() {
    switch (status) {
      case ApplicationStatus.shortlisted:
        return (AppColors.statusShortlisted, AppColors.statusShortlistedBg);
      case ApplicationStatus.underReview:
        return (AppColors.statusUnderReview, AppColors.statusUnderReviewBg);
      case ApplicationStatus.accepted:
        return (AppColors.statusAccepted, AppColors.statusAcceptedBg);
      case ApplicationStatus.interviewScheduled:
        return (AppColors.statusInterview, AppColors.statusInterviewBg);
      case ApplicationStatus.rejected:
        return (AppColors.error, AppColors.errorContainer);
      case ApplicationStatus.submitted:
        return (AppColors.onSurfaceVariant, AppColors.surfaceContainer);
    }
  }
}

class OpportunityStatusBadge extends StatelessWidget {
  final OpportunityStatus status;

  const OpportunityStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == OpportunityStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.statusAcceptedBg : AppColors.statusUnderReviewBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Paused',
        style: AppTextStyles.labelSm.copyWith(
          color: isActive ? AppColors.statusAccepted : AppColors.statusUnderReview,
        ),
      ),
    );
  }
}

class MatchBadge extends StatelessWidget {
  final int score;

  const MatchBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (score >= 90) {
      bg = AppColors.primary;
    } else if (score >= 80) {
      bg = AppColors.secondary;
    } else {
      bg = AppColors.onSurface;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        '$score% MATCH',
        style: AppTextStyles.labelSm.copyWith(color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }
}
