// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // For BlocProvider
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // Import the OnboardingBloc
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart'; // Import the OnboardingScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access screen dimensions and theme properties
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Access theme for text styles and colors
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color:
              colorScheme.surface, // Using a solid surface color from the theme
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
              children: [
                // --- Application Title / Logo Area ---
                // Consider replacing this with an Image.asset('path/to/logo.png') if you have a logo
                Text(
                  "GYMGENIUS",
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // --- Tagline ---
                Text(
                  "Your AI-Powered Fitness Coach",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: screenHeight * 0.12),

                // --- Main "Get Started" Button ---
                ElevatedButton(
                  onPressed: () {
                    // Current flow: HomeScreen -> OnboardingScreen -> SignUpScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (blocContext) => OnboardingBloc(),
                          child: const OnboardingScreen(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("GET STARTED"),
                ),
                SizedBox(height: screenHeight * 0.03),

                // --- Secondary "Login" Link ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
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
                SizedBox(height: screenHeight * 0.05), // Bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
