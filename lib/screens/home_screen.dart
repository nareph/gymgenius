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
      // --- Optional Gradient Background ---
      // If you prefer a solid background, comment out or remove the Container and its decoration.
      // The Scaffold will then use `colorScheme.background` from your theme.
      body: Container(
        // Using a simple surface color from the theme for the background.
        // If you want a gradient, define it here. For a solid color,
        // setting `Scaffold(backgroundColor: colorScheme.surface)` is often simpler.
        decoration: BoxDecoration(
          color:
              colorScheme.surface, // Using a solid surface color from the theme
          // Example gradient (if desired):
          // gradient: LinearGradient(
          //   colors: [
          //     colorScheme.surfaceVariant, // A slightly different surface color
          //     colorScheme.surface,       // Main surface color
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08), // Adjusted horizontal padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons
              children: [
                // --- Application Title ---
                Text(
                  "GYMGENIUS",
                  textAlign: TextAlign.center,
                  // Uses 'displayLarge' text style.
                  // The color is implicitly derived from 'textTheme', which typically uses 'onSurface' or 'onBackground'.
                  // If you needed to force a color, it would be here:
                  // style: textTheme.displayLarge?.copyWith(color: colorScheme.onSurface),
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold, // Make title bolder
                    color:
                        colorScheme.primary, // Use primary color for emphasis
                  ),
                ),
                SizedBox(height: screenHeight * 0.015), // Reduced spacing

                // --- Tagline ---
                Text(
                  "Your AI-Powered Fitness Coach",
                  textAlign: TextAlign.center,
                  // Uses 'headlineSmall'. Adjust opacity of onSurface if needed.
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface
                        .withOpacity(0.8), // Slightly less prominent than title
                  ),
                ),
                SizedBox(
                    height:
                        screenHeight * 0.12), // Increased spacing before button

                // --- Main "Get Started" Button ---
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Provide OnboardingBloc to the OnboardingScreen and its descendants
                        builder: (_) => BlocProvider(
                          create: (blocContext) => OnboardingBloc(),
                          child: const OnboardingScreen(),
                        ),
                      ),
                    );
                  },
                  // Style comes from ElevatedButtonThemeData in AppTheme
                  // Ensure the theme provides adequate padding and text style.
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Make button taller
                  ),
                  child: const Text(
                      "GET STARTED"), // Text typically styled by ElevatedButtonTheme
                ),
                SizedBox(height: screenHeight * 0.03), // Adjusted spacing

                // --- Secondary "Login" Link ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      // Uses 'bodyMedium'. Adjust opacity of onSurface.
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context,
                          '/login'), // Assuming '/login' route is defined
                      // Style comes from TextButtonThemeData in AppTheme
                      child: Text(
                        "Log In",
                        style: textTheme.bodyMedium?.copyWith(
                          // Match text style
                          color:
                              colorScheme.primary, // Use primary color for link
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
