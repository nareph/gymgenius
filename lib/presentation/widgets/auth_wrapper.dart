// lib/presentation/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/screens/home_screen.dart';
import 'package:gymgenius/presentation/screens/main_dashboard_screen.dart';
import 'package:gymgenius/presentation/screens/profile_setup/profile_setup_screen.dart';

/// AuthWrapper is the gatekeeper of the application's navigation.
/// It listens to the global [AuthBloc] state and displays the correct screen.
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
            if (state.isProfileComplete) {
              Log.debug(
                  "AuthWrapper: User authenticated with complete profile -> MainDashboard");
              return const MainDashboardScreen();
            } else {
              Log.debug(
                  "AuthWrapper: User authenticated but profile incomplete -> ProfileSetup");
              return ProfileSetupScreen(
                isPostLogin: true,
                // Resume with only the still-missing questions instead of
                // the full questionnaire.
                missingFieldIds: state.missingFieldIds,
              );
            }

          case AuthStatus.unauthenticated:
            Log.debug("AuthWrapper: User unauthenticated -> HomeScreen");
            return const HomeScreen();

          case AuthStatus.unknown:
          default:
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
