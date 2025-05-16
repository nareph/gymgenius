// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/screens/home_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

const bool _useEmulators = kDebugMode;

Future<void> _configureFirebaseEmulators() async {
  final String host = '192.168.8.46'; // Replace with your local IP address

  // Host configuration:
  // - Android Emulator: '10.0.2.2' (special address to reach host machine)
  // - iOS Simulator/Web/Desktop/Physical Device on same network: Use your machine's local network IP.
  //   You can find this IP using 'ipconfig' (Windows) or 'ifconfig' (macOS/Linux).
  // const String host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  // IMPORTANT: Replace with YOUR specific local IP if testing on a physical device or if 'localhost' doesn't work for other emulators.
  Log.info('--- Configuring Firebase Emulators to connect to host: $host ---');
  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    Log.debug('FirebaseAuth emulator configured on $host:9099');

    FirebaseFirestore.instance.settings = Settings(
      host: '$host:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    Log.debug('FirebaseFirestore emulator configured on $host:8080');

    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    Log.debug('FirebaseFunctions emulator configured on $host:5001');

    Log.info('Firebase Emulators configured successfully');
  } catch (e, stack) {
    Log.error('Error configuring Firebase emulators',
        error: e, stackTrace: stack);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (_useEmulators) {
    await _configureFirebaseEmulators();
  } else {
    Log.info("--- Using Production Firebase Services ---");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutSessionManager(),
      child: MaterialApp(
        title: 'GymGenius',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return SignUpScreen(onboardingData: args?['onboardingData']);
          },
          '/main_app': (context) => const MainDashboardScreen(),
        },
        onUnknownRoute: (settings) {
          Log.warning("Unknown route accessed: ${settings.name}");
          return MaterialPageRoute(builder: (_) => const UnknownRouteScreen());
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _isOnboardingComplete(String userId) async {
    if (userId.isEmpty) {
      Log.warning("_isOnboardingComplete called with empty userId");
      return false;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final userData = doc.data()!;
        final bool completedFlag =
            userData['onboardingCompleted'] as bool? ?? false;
        if (completedFlag) {
          Log.debug("User $userId has 'onboardingCompleted: true'");
          return true;
        } else {
          Log.debug(
              "User $userId has 'onboardingCompleted: false' or flag is missing");
          return false;
        }
      }
      Log.debug("User document for $userId does not exist");
      return false;
    } catch (e, stack) {
      Log.error("Error checking onboarding status for user $userId",
          error: e, stackTrace: stack);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          Log.debug("Auth stream is waiting");
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (authSnapshot.hasError) {
          Log.error("Auth stream error", error: authSnapshot.error);
          return const Scaffold(
              body: Center(
                  child:
                      Text("Authentication error. Please restart the app.")));
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final User user = authSnapshot.data!;
          Log.debug(
              "User authenticated (UID: ${user.uid}). Checking onboarding completion");

          return FutureBuilder<bool>(
            key: ValueKey('onboarding_check_${user.uid}'),
            future: _isOnboardingComplete(user.uid),
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                Log.debug(
                    "Onboarding status check is waiting for UID: ${user.uid}");
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (onboardingSnapshot.hasError) {
                Log.error(
                    "Error checking onboarding status for UID ${user.uid}",
                    error: onboardingSnapshot.error);
                Log.debug(
                    "Onboarding check failed, proceeding to MainDashboardScreen as fallback");
                return const MainDashboardScreen();
              }

              if (onboardingSnapshot.data == true) {
                Log.info(
                    "Onboarding complete for UID: ${user.uid}. Navigating to MainDashboardScreen");
                return const MainDashboardScreen();
              } else {
                Log.info(
                    "Onboarding not complete for UID: ${user.uid}. Navigating to OnboardingScreen");
                return BlocProvider(
                  create: (_) => OnboardingBloc(),
                  child: const OnboardingScreen(isPostLoginCompletion: true),
                );
              }
            },
          );
        } else {
          Log.debug("User is not authenticated. Navigating to HomeScreen");
          return const HomeScreen();
        }
      },
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page Not Found")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Sorry, the page you were looking for could not be found. Please check the URL or return to the previous page.",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
