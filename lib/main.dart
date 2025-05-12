// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode and defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // For BlocProvider
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/screens/home_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // Ensure you have this generated file

const bool _useEmulators = kDebugMode;

Future<void> _configureFirebaseEmulators() async {
  // Choose the correct host based on your testing environment (emulator vs physical device)
  // For Android Emulator: '10.0.2.2'
  // For iOS Simulator/Web/Desktop/Physical Device on same network: Use your local network IP
  // final String host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  final String host =
      '192.168.8.46'; // Replace with YOUR specific IP if needed for physical device testing

  print('--- Configuring Firebase Emulators to connect to: $host ---');
  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    print('FirebaseAuth emulator configured on $host:9099');
    FirebaseFirestore.instance.settings = Settings(
      host: '$host:8080',
      sslEnabled: false, // Emulators typically don't use SSL
      persistenceEnabled:
          false, // Disable persistence when using emulators to avoid conflicts
    );
    print('FirebaseFirestore emulator configured on $host:8080');
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    print('FirebaseFunctions emulator configured on $host:5001');
    print('--- Firebase Emulators configured successfully ---');
  } catch (e, stack) {
    print('Error configuring Firebase emulators: $e');
    print(stack);
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
    print("--- Using Production Firebase Services ---");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide WorkoutSessionManager to the entire widget tree below
    return ChangeNotifierProvider(
      create: (context) => WorkoutSessionManager(),
      child: MaterialApp(
        title: 'GymGenius',
        theme: AppTheme.darkTheme, // Assuming you have defined this theme
        debugShowCheckedModeBanner:
            false, // Hide debug banner in release builds
        home: const AuthWrapper(), // Use AuthWrapper as the entry point
        routes: {
          // Define named routes for easy navigation
          '/home': (context) => const HomeScreen(), // Initial public screen
          '/login': (context) => const LoginScreen(),
          '/signup': (context) {
            // Allow passing onboarding data to SignUpScreen if needed
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return SignUpScreen(onboardingData: args?['onboardingData']);
          },
          // '/onboarding': // This route might not be directly needed if handled by AuthWrapper/HomeScreen
          '/main_app': (context) =>
              const MainDashboardScreen(), // The main app screen after login
        },
        onUnknownRoute: (settings) {
          // Handle cases where a route name is not found
          print("Unknown route accessed: ${settings.name}");
          return MaterialPageRoute(builder: (_) => const UnknownRouteScreen());
        },
      ),
    );
  }
}

/// AuthWrapper Widget: Listens to Firebase auth state changes and directs the user
/// to the appropriate screen (Login, Onboarding, or Main App).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /// Checks if the user has completed the onboarding process by checking
  /// the existence and content of 'onboardingData' in their Firestore document.
  Future<bool> _isOnboardingComplete(String userId) async {
    if (userId.isEmpty) return false; // Cannot check for empty user ID

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final userData = doc.data()!;
        final onboardingData = userData['onboardingData'];

        // Define "complete": data exists as a map and is not empty.
        // You could add more specific checks here, e.g., ensuring 'goal' is present.
        if (onboardingData is Map && onboardingData.isNotEmpty) {
          // Example: return onboardingData.containsKey('goal') && onboardingData['goal'] != null;
          return true;
        }
      }
      // Document doesn't exist or onboardingData is missing/empty/not a map
      return false;
    } catch (e, stack) {
      print("Error checking onboarding status for user $userId: $e");
      print(stack);
      // Decide fallback behavior on error. Returning false (incomplete) is safer.
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to authentication state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // --- 1. Handle Connection States & Errors ---
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          print("AuthWrapper: Waiting for auth state...");
          // Show loading indicator while checking auth state
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (authSnapshot.hasError) {
          print("AuthWrapper StreamBuilder error: ${authSnapshot.error}");
          // Show an error screen or navigate to a safe fallback (like HomeScreen)
          return const Scaffold(
            body: Center(child: Text("Authentication error. Please restart.")),
          );
        }

        // --- 2. Handle User State ---
        if (authSnapshot.hasData && authSnapshot.data != null) {
          // --- 2a. User is Authenticated ---
          final User user = authSnapshot.data!;
          print(
              "AuthWrapper: User is authenticated (UID: ${user.uid}). Checking onboarding status...");

          // Now check if onboarding is complete for this authenticated user
          return FutureBuilder<bool>(
            // Use ValueKey with UID to ensure FutureBuilder refetches if the user changes
            key: ValueKey('onboarding_check_${user.uid}'),
            future: _isOnboardingComplete(user.uid),
            builder: (context, onboardingSnapshot) {
              // --- Handle Onboarding Check States ---
              if (onboardingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                print("AuthWrapper: Waiting for onboarding status...");
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (onboardingSnapshot.hasError) {
                print(
                    "AuthWrapper: Error checking onboarding status: ${onboardingSnapshot.error}");
                // Fallback: Allow user into the main app despite the error checking onboarding.
                print(
                    "AuthWrapper: Onboarding check failed, proceeding to MainDashboardScreen as fallback.");
                return const MainDashboardScreen(); // Navigate to main app
              }

              // --- Onboarding Status Determined ---
              if (onboardingSnapshot.data == true) {
                // ---- ONBOARDING COMPLETE ----
                print(
                    "AuthWrapper: Onboarding complete for UID: ${user.uid}. Navigating to MainDashboardScreen.");
                return const MainDashboardScreen(); // Go to the main application
              } else {
                // ---- ONBOARDING INCOMPLETE ----
                print(
                    "AuthWrapper: Onboarding NOT complete for UID: ${user.uid}. Navigating to OnboardingScreen (post-login context).");
                // Provide the OnboardingBloc and navigate to OnboardingScreen,
                // explicitly telling it this is for post-login completion.
                return BlocProvider(
                  create: (blocContext) => OnboardingBloc(),
                  child: const OnboardingScreen(
                    // **** THIS IS THE CRUCIAL FLAG ****
                    isPostLoginCompletion: true,
                  ),
                );
              }
            },
          );
        } else {
          // --- 2b. User is NOT Authenticated ---
          print(
              "AuthWrapper: User is not authenticated. Navigating to HomeScreen.");
          // Show the initial public screen (e.g., landing page with login/signup options)
          return const HomeScreen();
        }
      },
    );
  }
}

/// A simple screen displayed when a route is not found.
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
