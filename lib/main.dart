// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// --- BlocProvider et Onboarding ---
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';
import 'package:gymgenius/screens/auth/signin_screen.dart';
import 'package:gymgenius/screens/home_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/theme/app_theme.dart'; // Import du thème
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          WorkoutSessionManager(), // Créer une instance du manager
      child: MaterialApp(
        title: 'GymGenius',
        // Applique le thème défini dans app_theme.dart
        theme: AppTheme.darkTheme,
        // Vous pouvez aussi spécifier darkTheme et themeMode si vous prévoyez un thème clair plus tard
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.dark, // Force le mode sombre pour l'instant
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(), // Gère l'authentification initiale
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signin': (context) =>
              const SignInScreen(), // Peut être appelé sans data via route
          // Route pour Onboarding AVEC BlocProvider (utilisée si pushNamed est appelé)
          '/onboarding': (context) => BlocProvider(
                create: (context) => OnboardingBloc(),
                child: const OnboardingScreen(),
              ),
          '/main_app': (context) => const MainDashboardScreen(),
        },
      ),
    );
  }
}

// AuthWrapper pour la gestion de l'état de connexion
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Utilise la couleur secondaire du thème pour l'indicateur
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          // Utilise la couleur d'erreur du thème
          return Scaffold(
            body: Center(
              child: Text(
                "Error checking authentication state.",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const MainDashboardScreen(); // Utilisateur connecté
        } else {
          return const HomeScreen(); // Utilisateur déconnecté
        }
      },
    );
  }
}
