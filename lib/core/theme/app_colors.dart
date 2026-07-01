import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9B00BE);
  static const Color primaryContainer = Color(0xFFC200EE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF5400C3);
  static const Color secondaryContainer = Color(0xFF7000FF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFFB5015E);
  static const Color tertiaryContainer = Color(0xFFD72C76);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF8F9FD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3F7);
  static const Color surfaceContainer = Color(0xFFEDEEF2);
  static const Color surfaceContainerHigh = Color(0xFFE7E8EC);
  static const Color onSurface = Color(0xFF191C1F);
  static const Color onSurfaceVariant = Color(0xFF524154);

  static const Color outline = Color(0xFF847185);
  static const Color outlineVariant = Color(0xFFD7BFD6);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color background = Color(0xFFF8F9FD);
  static const Color onBackground = Color(0xFF191C1F);

  static const Color statusShortlisted = Color(0xFF00C896);
  static const Color statusShortlistedBg = Color(0xFFE0FFF6);
  static const Color statusUnderReview = Color(0xFFF5A623);
  static const Color statusUnderReviewBg = Color(0xFFFFF4E0);
  static const Color statusAccepted = Color(0xFF2ECC71);
  static const Color statusAcceptedBg = Color(0xFFE0FAE9);
  static const Color statusInterview = Color(0xFFE91E8C);
  static const Color statusInterviewBg = Color(0xFFFFE0F2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondaryContainer],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [secondary, primary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF7B00B0), secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [tertiary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF0A0015), Color(0xFF1A0040), Color(0xFF2A0060)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
