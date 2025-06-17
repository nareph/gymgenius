// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/screens/home_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/widgets/offline_no_data_screen.dart';

/// AuthWrapper is the gatekeeper of the application's navigation.
/// It listens to the global [AuthBloc] state and pushes the correct
/// screen flow onto its own [Navigator].
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // A GlobalKey for our root navigator.
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // The listener is the single source of truth for global navigation changes.
      listener: (context, state) {
        Log.info(
            "AuthWrapper Listener: Received new auth status: ${state.status}");
        switch (state.status) {
          case AuthStatus.authenticated:
            final route = state.isProfileComplete
                ? MainDashboardScreen.route()
                : OnboardingScreen.route();
            // Push the new screen and remove all previous routes.
            _navigator.pushAndRemoveUntil<void>(route, (route) => false);
            break;
          case AuthStatus.unauthenticated:
            // Push the home screen and remove all previous routes.
            _navigator.pushAndRemoveUntil<void>(
              HomeScreen.route(),
              (route) => false,
            );
            break;
          case AuthStatus.authenticatedOfflineNoCache:
            _navigator.pushAndRemoveUntil<void>(
              MaterialPageRoute(builder: (_) => const OfflineNoDataScreen()),
              (route) => false,
            );
            break;
          default:
            // For 'unknown' or other states, the initial route (loading screen) will be shown.
            break;
        }
      },
      child: Navigator(
        key: _navigatorKey,
        // The Navigator starts with a single, simple loading page.
        // The BlocListener above will immediately replace it with the correct page.
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
