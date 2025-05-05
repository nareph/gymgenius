// lib/screens/auth/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Pour l'indicateur de chargement

  // --- Fonction de connexion ---
  Future<void> _loginWithEmail() async {
    // Valide le formulaire
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Redirection vers l'écran principal après succès
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main_app', // Route vers MainDashboardScreen
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Afficher l'erreur spécifique de Firebase Auth
        String errorMessage =
            "Login failed. Please check your credentials."; // Message par défaut
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = "Invalid email or password. Please try again.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is badly formatted.";
        } else {
          errorMessage = e.message ??
              errorMessage; // Utilise le message Firebase si disponible
        }
        _showErrorSnackBar(errorMessage, context);
      }
    } catch (e) {
      // Attrape d'autres erreurs potentielles
      if (mounted) {
        print("Login error: $e");
        _showErrorSnackBar(
            "An unexpected error occurred. Please try again.", context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper pour afficher les SnackBar d'erreur avec le style du thème
  void _showErrorSnackBar(String message, BuildContext context) {
    // Vérifie si le widget est toujours monté
    if (!context.mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 3), // Durée d'affichage
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accès au thème
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // final inputTheme = Theme.of(context).inputDecorationTheme; // Pas explicitement nécessaire ici

    return Scaffold(
      // --- AppBar ---
      // Style vient de AppBarTheme dans AppTheme
      appBar: AppBar(
          // title: const Text("Login"), // Style du thème
          // Le bouton retour est ajouté automatiquement par défaut lors de la navigation push
          ),
      // --- Body ---
      // Fond vient de scaffoldBackgroundColor
      body: Center(
        // Centre verticalement si peu de contenu
        child: SingleChildScrollView(
          // Permet le défilement
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            // Enveloppe dans un Form
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centre la colonne
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Titre de l'Écran ---
                Text(
                  "Welcome Back!", // Titre
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium,
                ),
                Text(
                  "Log in to your account", // Sous-titre
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge
                      ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 40), // Espace augmenté

                // --- Champ Email ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // Style texte hérité
                  decoration: const InputDecoration(
                    // Utilise InputDecorationTheme
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    // Validation
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 15),

                // --- Champ Mot de Passe ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  // Style texte hérité
                  decoration: const InputDecoration(
                    // Utilise InputDecorationTheme
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    // Validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 35),

                // --- Bouton Login ---
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.secondary))
                    : ElevatedButton(
                        onPressed: _loginWithEmail,
                        // Style vient de ElevatedButtonThemeData
                        child: const Text("LOG IN"), // Texte en majuscules ?
                      ),
                // Optionnel: Bouton "Forgot Password?"
                // TextButton(
                //   onPressed: () { /* Implémenter la logique mot de passe oublié */ },
                //   child: Text("Forgot Password?"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
