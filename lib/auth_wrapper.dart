// lib/presentation/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/screens/home_screen.dart';
import 'package:gymgenius/presentation/screens/main_dashboard_screen.dart';

/// AuthWrapper is the gatekeeper of the application's navigation.
/// It listens to the global [AuthBloc] state and displays the correct screen.
///
/// NOTE: this no longer hard-gates on profile completeness. Previously,
/// an authenticated user with an incomplete profile was forced into
/// ProfileSetupScreen here, before ever reaching MainDashboardScreen —
/// which made HomeTabScreen's own CompleteProfileView unreachable, since
/// AuthWrapper never let an incomplete-profile user get that far.
/// Account creation and profile completion are now separate steps (see
/// SignUpBloc / HomeScreen): a fresh account has an empty, incomplete
/// profile by design, and the user should land on the dashboard shell
/// regardless — it's HomeTabScreen's job to prompt for profile
/// completion before generating a program, not AuthWrapper's job to
/// block navigation entirely.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        Log.info(
            "AuthWrapper: State changed to ${state.status}, user: ${state.user?.email}, profileComplete: ${state.isProfileComplete}");
      },
      builder: (context, state) {
        Log.info("AuthWrapper: Building with auth status: ${state.status}");

        switch (state.status) {
          case AuthStatus.authenticated:
            Log.debug("AuthWrapper: User authenticated -> MainDashboard");
            return const MainDashboardScreen();

          case AuthStatus.unauthenticated:
            Log.debug("AuthWrapper: User unauthenticated -> HomeScreen");
            return const HomeScreen();

          case AuthStatus.unknown:
            Log.debug("AuthWrapper: Auth state unknown -> Loading");
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
