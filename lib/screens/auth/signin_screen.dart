// lib/screens/auth/signin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// N'est plus nécessaire si on utilise pushNamedAndRemoveUntil('/main_app')
// import 'package:gymgenius/screens/main_dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;

  const SignInScreen({
    super.key,
    this.onboardingData,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey =
      GlobalKey<FormState>(); // Ajout d'une clé de formulaire pour validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- Fonction d'inscription (_signUpWithEmail) ---
  Future<void> _signUpWithEmail() async {
    // Valider le formulaire avant de continuer
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Arrête si le formulaire n'est pas valide
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;

      if (user != null) {
        final profileData = {
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          ...?widget.onboardingData,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(profileData);

        if (mounted) {
          // Utilise la route nommée définie dans main.dart
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main_app', // Route vers MainDashboardScreen
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar("Sign up failed. User data unavailable.", context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message ?? "Sign up error occurred.", context);
      }
    } catch (e) {
      if (mounted) {
        print("Error saving profile or other: $e");
        _showErrorSnackBar(
            "An error occurred during sign up. Please try again.", context);
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  // La fonction _formatOnboardingData reste inchangée (utile pour le debug)
  String _formatOnboardingData(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      if (value is Map) {
        buffer.writeln("- $key:");
        (value).forEach((subKey, subValue) {
          buffer.writeln("  - $subKey: $subValue");
        });
      } else if (value is List) {
        buffer.writeln("- $key: ${value.join(', ')}");
      } else {
        buffer.writeln("- $key: $value");
      }
    });
    return buffer.toString();
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

    return Scaffold(
      // --- AppBar ---
      // Style vient de AppBarTheme dans AppTheme
      appBar: AppBar(
        // title: const Text("Create Your Account"), // Style déjà dans le thème
        // Pas besoin de backgroundColor ou elevation
        leading: IconButton(
          // Garde le bouton retour
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // --- Body ---
      // Fond vient de scaffoldBackgroundColor
      // body: Container( ... decoration ... ), // <-- SUPPRIMÉ
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 30.0, vertical: 20.0), // Padding ajusté
          child: Form(
            // Enveloppe la colonne dans un Form
            key: _formKey, // Attache la clé
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Titre de l'Écran --- (Ajouté pour clarté)
                Text(
                  "Create Your Account",
                  textAlign: TextAlign.center,
                  style: textTheme
                      .headlineMedium, // Utilise un style de titre du thème
                ),
                const SizedBox(height: 30), // Espace après le titre

                // --- Affichage Debug (Optionnel) ---
                if (widget.onboardingData != null &&
                    widget.onboardingData!.isNotEmpty) ...[
                  Text(
                    "Your preferences will be saved:\n${_formatOnboardingData(widget.onboardingData!)}",
                    // Utilise un style de texte petit/discret du thème
                    style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6)),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 25),
                ],

                // --- Champ Email ---
                TextFormField(
                  // Remplacé TextField par TextFormField pour la validation
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // style: const TextStyle(color: Colors.white), // <-- SUPPRIMÉ (vient du thème)
                  // Utilise l'InputDecorationTheme, surcharge seulement labelText et icon
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    // Le reste (couleurs, bordures, etc.) vient du thème
                  ),
                  // Ajout de la validation
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    // Regex simple pour la validation d'email (peut être améliorée)
                    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null; // Valide
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 15),

                // --- Champ Mot de Passe ---
                TextFormField(
                  // Remplacé TextField par TextFormField
                  controller: _passwordController,
                  obscureText: true,
                  // style: const TextStyle(color: Colors.white), // <-- SUPPRIMÉ
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    // Le reste vient du thème
                  ),
                  // Ajout de la validation
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null; // Valide
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 35), // Espace augmenté

                // --- Bouton Sign Up ---
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        // Utilise la couleur secondaire du thème
                        color: colorScheme.secondary,
                      ))
                    : ElevatedButton(
                        onPressed: _signUpWithEmail,
                        // Le style vient automatiquement de ElevatedButtonThemeData
                        // style: ElevatedButton.styleFrom(...), // <-- SUPPRIMÉ
                        // Le texte utilise le style de ElevatedButtonThemeData
                        child: const Text("CREATE ACCOUNT"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
