import 'package:flutter/material.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/services/logger_service.dart';

/// HomeScreen: The initial landing screen for unauthenticated users.
///
/// It provides two main actions:
/// 1. "GET STARTED": Navigates to the onboarding/sign-up flow.
/// 2. "Log In": Navigates to the login screen for existing users.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    // Responsive UI values based on screen size.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Log.debug(
        'Building HomeScreen with dimensions: ${screenWidth}x$screenHeight');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Image.asset(
                  'assets/launcher_icon/launcher_icon.png',
                  height: screenHeight * 0.15,
                  errorBuilder: (context, error, stackTrace) {
                    Log.error('Failed to load app logo',
                        error: error, stackTrace: stackTrace);
                    return Icon(
                      Icons.fitness_center,
                      size: screenHeight * 0.15,
                      color: colorScheme.primary,
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                // App Title
                Text(
                  "GYMGENIUS",
                  textAlign: TextAlign.center,
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // App Tagline
                Text(
                  "Your AI-Powered Fitness Coach",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(217), // ~85% opacity
                  ),
                ),
                SizedBox(height: screenHeight * 0.1),

                // "Get Started" Button
                ElevatedButton(
                  onPressed: () {
                    Log.debug('User tapped GET STARTED button');
                    // Navigate to OnboardingScreen, which now manages its own providers.
                    // Using pushReplacement provides a better UX as the user can't go "back" to the splash screen.
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(
                            isPostLoginCompletion: false),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("GET STARTED"),
                ),
                SizedBox(height: screenHeight * 0.025),

                // "Log In" Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface
                            .withAlpha(204), // ~80% opacity
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Log.debug('User tapped Log In button');
                        // Use pushReplacement to maintain a clean navigation stack.
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "Log In",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
