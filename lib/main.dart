import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/application/application_cubit.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/bookmark/bookmark_cubit.dart';
import 'blocs/invitation/invitation_cubit.dart';
import 'blocs/notification/notification_cubit.dart';
import 'blocs/onboarding/onboarding_cubit.dart';
import 'blocs/opportunity/opportunity_cubit.dart';
import 'blocs/profile/profile_cubit.dart';
import 'blocs/startup/startup_cubit.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/application_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/invitation_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/opportunity_repository.dart';
import 'data/repositories/startup_repository.dart';
import 'router.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final oppRepo = OpportunityRepository();
    final appRepo = ApplicationRepository();
    final notifRepo = NotificationRepository();
    final startupRepo = StartupRepository();
    final invitationRepo = InvitationRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: oppRepo),
        RepositoryProvider.value(value: appRepo),
        RepositoryProvider.value(value: notifRepo),
        RepositoryProvider.value(value: startupRepo),
        RepositoryProvider.value(value: invitationRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRepository: authRepo)
              ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (_) => OnboardingCubit(authRepository: authRepo),
          ),
          BlocProvider(
            create: (_) => OpportunityCubit(
              opportunityRepository: oppRepo,
              applicationRepository: appRepo,
            ),
          ),
          BlocProvider(
            create: (_) =>
                ApplicationCubit(applicationRepository: appRepo),
          ),
          BlocProvider(
            create: (_) =>
                NotificationCubit(notificationRepository: notifRepo),
          ),
          BlocProvider(
            create: (_) => StartupCubit(
              startupRepository: startupRepo,
              opportunityRepository: oppRepo,
            ),
          ),
          BlocProvider(
            create: (_) => ProfileCubit(authRepository: authRepo),
          ),
          BlocProvider(
            create: (_) => InvitationCubit(
              invitationRepository: invitationRepo,
            ),
          ),
          BlocProvider(
            create: (_) => BookmarkCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'ALU Spark Connect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: '/',
          onGenerateRoute: generateRoute,
        ),
      ),
    );
  }
}

