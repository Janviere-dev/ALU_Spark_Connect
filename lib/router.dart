import 'package:flutter/material.dart';
import 'data/models/opportunity_model.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/onboarding/complete_profile_screen.dart';
import 'screens/onboarding/tailor_feed_screen.dart';
import 'screens/startup/applicants_screen.dart';
import 'screens/startup/post_opportunity_screen.dart';
import 'screens/startup/settings_screen.dart';
import 'screens/startup/startup_shell.dart';
import 'screens/student/edit_profile_screen.dart';
import 'screens/student/invitation_screen.dart';
import 'screens/student/notifications_screen.dart';
import 'screens/student/opportunity_detail_screen.dart';
import 'screens/student/apply_screen.dart';
import 'screens/student/settings_screen.dart';
import 'screens/student/student_shell.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final name = settings.name ?? '/';

  // /student/opportunity/:id
  if (name.startsWith('/student/opportunity/')) {
    final id = name.replaceFirst('/student/opportunity/', '');
    return _slide(OpportunityDetailScreen(opportunityId: id), settings);
  }

  // /student/apply/:id  — expects OpportunityModel as arguments
  if (name.startsWith('/student/apply/')) {
    final opp = settings.arguments as OpportunityModel?;
    if (opp != null) {
      return _slide(ApplyScreen(opportunity: opp), settings);
    }
    return _notFound(settings);
  }

  // /student/invitation/:id
  if (name.startsWith('/student/invitation/')) {
    final id = name.replaceFirst('/student/invitation/', '');
    return _slide(InvitationScreen(applicationId: id), settings);
  }

  // /startup/applicants — optional opportunityId as argument
  if (name == '/startup/applicants') {
    final oppId = settings.arguments as String?;
    return _slide(ApplicantsScreen(opportunityId: oppId), settings);
  }

  switch (name) {
    case '/':
      return _fade(const WelcomeScreen(), settings);
    case '/sign-in':
      return _slide(const SignInScreen(), settings);
    case '/sign-up':
      return _slide(const SignUpScreen(), settings);
    case '/onboarding/tailor-feed':
      return _slide(const TailorFeedScreen(), settings);
    case '/onboarding/complete-profile':
      return _slide(const CompleteProfileScreen(), settings);
    case '/student/home':
      return _fade(const StudentShell(), settings);
    case '/student/notifications':
      return _slide(const StudentNotificationsScreen(), settings);
    case '/student/settings':
      return _slide(const StudentSettingsScreen(), settings);
    case '/student/edit-profile':
      return _slide(const EditProfileScreen(), settings);
    case '/startup/dashboard':
      return _fade(const StartupShell(), settings);
    case '/startup/notifications':
      return _slide(const StudentNotificationsScreen(), settings);
    case '/startup/post':
      return _slide(const PostOpportunityScreen(), settings);
    case '/startup/settings':
      return _slide(const StartupSettingsScreen(), settings);
    default:
      return _notFound(settings);
  }
}

PageRoute<T> _slide<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

PageRoute<T> _fade<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 220),
  );
}

PageRoute<T> _notFound<T>(RouteSettings settings) {
  return _fade<T>(
    Scaffold(
      body: Center(
        child: Text('Page not found: ${settings.name}'),
      ),
    ),
    settings,
  );
}
