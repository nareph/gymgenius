// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Pour BlocProvider
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // Import du Bloc
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart'; // Import de l'écran Onboarding

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accès aux dimensions et au thème
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // Accéder au thème pour les styles de texte et les couleurs
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // --- Fond Dégradé (Optionnel) ---
      // Si vous voulez un fond uni, commentez/supprimez le Container et sa décoration.
      // Le Scaffold utilisera alors colorScheme.background du thème.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface, // Couleur de fond du thème
              colorScheme.surface, // Couleur de surface du thème
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Titre de l'Application ---
                Text(
                  "GYMGENIUS",
                  textAlign: TextAlign.center,
                  // Utilise le style de texte 'displayLarge'
                  // La couleur vient implicitement de 'textTheme' qui utilise 'onSurface'/'onBackground'
                  // Si vous aviez forcé la couleur, ce serait ici:
                  // style: textTheme.displayLarge?.copyWith(color: colorScheme.onSurface), // Utilise onSurface
                  style: textTheme
                      .displayLarge, // Le thème devrait déjà utiliser la bonne couleur (onSurface)
                ),
                SizedBox(height: screenHeight * 0.02),
                // --- Tagline ---
                Text(
                  "Your AI-Powered Fitness Coach",
                  textAlign: TextAlign.center,
                  // Utilise 'headlineSmall'. Ajuste l'opacité de onSurface si besoin.
                  style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface
                          .withOpacity(0.85) // Utilise onSurface
                      ),
                ),
                SizedBox(height: screenHeight * 0.1),

                // --- Bouton Principal "Get Started" ---
                ElevatedButton(
                  onPressed: () {
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
                  // Style vient du thème
                  child: const Text("GET STARTED"),
                ),
                SizedBox(height: screenHeight * 0.05),

                // --- Lien Secondaire "Login" ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      // Utilise 'bodyMedium'. Ajuste l'opacité de onSurface.
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface
                              .withOpacity(0.7) // Utilise onSurface
                          ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      // Style vient du thème
                      child: const Text("Log In"),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05), // Espace en bas
              ],
            ),
          ),
        ),
      ),
    );
  }
}
