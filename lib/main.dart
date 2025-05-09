// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import pour Firestore
import 'package:cloud_functions/cloud_functions.dart'; // Import pour Functions
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';
import 'package:gymgenius/screens/auth/signin_screen.dart';
import 'package:gymgenius/screens/home_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/onboarding_screen.dart';
import 'package:gymgenius/theme/app_theme.dart';
import 'package:provider/provider.dart';

// Importer firebase_options.dart (généré par FlutterFire CLI)
import 'firebase_options.dart';

// Flag global pour utiliser les émulateurs (peut être contrôlé autrement si besoin)
// kDebugMode est true seulement quand l'app est lancée en mode debug depuis l'IDE/CLI
const bool useEmulators = true; //kDebugMode;

Future<void> _configureFirebaseEmulators() async {
  try {
/*     final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost'; */

    // For physical device testing with emulators, use your computer's local IP
    // final host = '192.168.1.X'; // Replace with your actual local IP

    final host = '192.168.8.46';
    print('Configuring Firebase emulators for $host');

    // Auth emulator configuration
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);

    // Disable app verification for testing
    FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
      forceRecaptchaFlow: false,
    );

    // Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

    // Functions emulator
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

    print('Firebase emulators configured successfully');
  } catch (e, stack) {
    print('Error configuring emulators: $e');
    print(stack);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure emulators if needed
  if (useEmulators) {
    await _configureFirebaseEmulators();
  } else {
    print("--- Using Production Firebase Services ---");
  }

  // Call this after emulator config
  WidgetsBinding.instance.addPostFrameCallback((_) {
    testAuth();
  });

  runApp(const MyApp());
}

Future<void> testAuth() async {
  try {
    final email = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
    print('Attempting to create user: $email');

    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: 'password123',
    );

    print('Success! User created with UID: ${credential.user?.uid}');

    // Modern way to check if email exists (non-deprecated)
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    print('Sign-in methods for $email: $methods');
  } catch (e, stack) {
    print('Authentication failed: $e');
    print(stack);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutSessionManager(), // Instance globale
      child: MaterialApp(
        title: 'GymGenius',
        theme: AppTheme.darkTheme, // Appliquer le thème sombre
        debugShowCheckedModeBanner: false, // Cacher la bannière de debug
        home: const AuthWrapper(), // Point d'entrée après initialisation
        routes: {
          // Routes principales accessibles par nom
          '/home': (context) => const HomeScreen(), // Écran si déconnecté
          '/login': (context) => const LoginScreen(),
          '/signin': (context) {
            // Récupérer les arguments passés via Navigator.pushNamed
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return SignInScreen(
                onboardingData: args?[
                    'onboardingData']); // Passer les données si elles existent
          },
          '/onboarding': (context) => BlocProvider(
                create: (context) => OnboardingBloc(), // Fournir le BLoC ici
                child: const OnboardingScreen(),
              ),
          '/main_app': (context) =>
              const MainDashboardScreen(), // Dashboard si connecté
        },
        // Optionnel : Gérer les routes inconnues
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => const UnknownRouteScreen());
        },
      ),
    );
  }
}

// AuthWrapper pour gérer l'état de connexion initial
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // --- NOTE : Déplacez la logique de vérification de l'onboarding ici si vous préférez ---
  // Future<bool> _isOnboardingComplete(String userId) async { ... }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Afficher un écran de chargement pendant la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Afficher une erreur si la vérification échoue
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }
        // Rediriger en fonction de l'état de connexion
        if (snapshot.hasData && snapshot.data != null) {
          // Utilisateur connecté -> Dashboard Principal
          // Vous pourriez ajouter la vérification d'onboarding ici si vous le souhaitez
          // avant de retourner MainDashboardScreen ou OnboardingScreen.
          // Pour l'instant, on va directement au Dashboard.
          return const MainDashboardScreen();
        } else {
          // Utilisateur déconnecté -> Écran d'accueil/landing
          return const HomeScreen();
        }
      },
    );
  }
}

// Écran simple pour les routes inconnues (optionnel)
class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page Not Found")),
      body: const Center(
        child: Text("Sorry, the page you are looking for does not exist."),
      ),
    );
  }
}
