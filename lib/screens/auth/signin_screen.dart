// lib/screens/auth/signin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// --- IMPORTEZ LE FICHIER CONTENANT VOTRE ROUTINE STATIQUE ---
// Cette importation n'est plus nécessaire ici, elle le sera dans le DashboardScreen
// import 'package:gymgenius/data/static_routine.dart';

class SignInScreen extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  const SignInScreen({super.key, this.onboardingData});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUpWithEmail() async {
    // Valide le formulaire avant de continuer
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Créer l'utilisateur Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;

      if (user != null) {
        // Préparer les données du profil
        final profileData = {
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          ...?widget.onboardingData, // Ajoute les données de l'onboarding
        };
        final profileRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Sauvegarder uniquement le profil utilisateur
        // La routine sera gérée depuis le DashboardScreen
        await profileRef.set(profileData);

        // Rediriger si le widget est toujours monté
        if (mounted) {
          // Redirige vers '/main_app' qui contiendra le DashboardScreen
          Navigator.pushNamedAndRemoveUntil(
              context, '/main_app', (route) => false);
        }
      } else {
        // Gérer le cas improbable où user est null
        if (mounted) {
          _showErrorSnackBar("Sign up failed. User data unavailable.", context);
        }
      }
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs d'authentification
      if (mounted) {
        String errorMessage = "Sign up error occurred.";
        if (e.code == 'email-already-in-use') {
          errorMessage =
              "This email is already registered. Please log in or use a different email.";
        } else if (e.code == 'weak-password') {
          errorMessage = "The password provided is too weak.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is badly formatted.";
        } else {
          errorMessage = e.message ??
              errorMessage; // Utilise le message Firebase si disponible
        }
        _showErrorSnackBar(errorMessage, context);
      }
    } catch (e) {
      // Gérer les autres erreurs (Firestore, etc.)
      if (mounted) {
        print("Error saving profile or other: $e");
        _showErrorSnackBar(
            "An error occurred during sign up. Please try again.", context);
      }
    } finally {
      // Assurer que l'indicateur de chargement s'arrête
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper pour afficher les SnackBar d'erreur avec le style du thème
  void _showErrorSnackBar(String message, BuildContext context) {
    if (!context.mounted) return; // Vérifie si le widget est toujours là
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Fonction pour formater les données d'onboarding pour l'affichage debug
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

  // Nettoie les contrôleurs
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Construit l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // Accès au thème
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create Your Account",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                if (widget.onboardingData != null &&
                    widget.onboardingData!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      "Your preferences will be saved with your profile:\n${_formatOnboardingData(widget.onboardingData!)}",
                      style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.4),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 35),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.secondary))
                    : ElevatedButton(
                        onPressed: _signUpWithEmail,
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
