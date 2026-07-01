import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/application/application_cubit.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/notification/notification_cubit.dart';
import 'blocs/onboarding/onboarding_cubit.dart';
import 'blocs/opportunity/opportunity_cubit.dart';
import 'blocs/profile/profile_cubit.dart';
import 'blocs/startup/startup_cubit.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/application_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/opportunity_repository.dart';
import 'data/repositories/startup_repository.dart';
import 'router.dart';

void main() {
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

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: oppRepo),
        RepositoryProvider.value(value: appRepo),
        RepositoryProvider.value(value: notifRepo),
        RepositoryProvider.value(value: startupRepo),
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

