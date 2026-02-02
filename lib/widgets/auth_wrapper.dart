// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/screens/home_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/services/logger_service.dart';

/// AuthWrapper is the gatekeeper of the application's navigation.
/// It listens to the global [AuthBloc] state and displays the correct screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Log state changes for debugging
        Log.info(
            "AuthWrapper: State changed to ${state.status}, user: ${state.user?.email}, profileComplete: ${state.isProfileComplete}");
      },
      builder: (context, state) {
        Log.info("AuthWrapper: Building with auth status: ${state.status}");

        switch (state.status) {
          case AuthStatus.authenticated:
            // User is authenticated, check if profile is complete
            if (state.isProfileComplete) {
              Log.debug(
                  "AuthWrapper: User authenticated with complete profile -> MainDashboard");
              return const MainDashboardScreen();
            } else {
              Log.debug(
                  "AuthWrapper: User authenticated but profile incomplete -> Onboarding");
              return const OnboardingScreen(isPostLoginCompletion: true);
            }

          case AuthStatus.unauthenticated:
            // User is not authenticated
            Log.debug("AuthWrapper: User unauthenticated -> HomeScreen");
            return const HomeScreen();

          case AuthStatus.unknown:
          default:
            // Still determining auth state - show loading
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
