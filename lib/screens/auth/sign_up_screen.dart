// lib/screens/auth/sign_up_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart'; // Importer OnboardingData

class SignUpScreen extends StatefulWidget {
  final Map<String, dynamic>?
      onboardingData; // Reçu de OnboardingScreen (state.answers du Bloc)

  const SignUpScreen({super.key, this.onboardingData});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;

      if (user != null) {
        bool finalOnboardingCompletedFlag = false;
        Map<String, dynamic> finalOnboardingDataMap;

        if (widget.onboardingData != null &&
            widget.onboardingData!.isNotEmpty) {
          // Les données viennent de OnboardingBloc.state.answers
          // OnboardingBloc doit s'assurer que 'completed' est dans ce map (par ex. mis à true lors de CompleteOnboarding)
          finalOnboardingDataMap = widget.onboardingData!;
          finalOnboardingCompletedFlag =
              finalOnboardingDataMap['completed'] as bool? ?? false;

          // Si 'completed' n'est pas dans le map venant du bloc, on le force ici.
          // C'est une sécurité, mais OnboardingBloc devrait le gérer.
          if (finalOnboardingDataMap['completed'] == null) {
            finalOnboardingDataMap['completed'] =
                true; // L'utilisateur a "terminé" le flux d'onboarding
            finalOnboardingCompletedFlag = true;
          }
        } else {
          // Cas où SignUpScreen est accédé directement sans passer par OnboardingScreen
          // (ou si OnboardingBloc n'a pas fourni de données).
          // Créer un OnboardingData par défaut, marqué comme non complété.
          finalOnboardingDataMap = OnboardingData(completed: false).toMap();
          finalOnboardingCompletedFlag = false;
        }

        final Map<String, dynamic> userProfileData = {
          'email': user.email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'displayName': user.email?.split('@')[0] ?? 'New User',
          'onboardingData':
              finalOnboardingDataMap, // Contient son propre 'completed'
          'onboardingCompleted':
              finalOnboardingCompletedFlag, // Drapeau de haut niveau pour AuthWrapper
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userProfileData);

        if (mounted) {
          // AuthWrapper gérera la redirection vers OnboardingScreen (post-login)
          // si 'onboardingCompleted' est false.
          Navigator.pushNamedAndRemoveUntil(
              context, '/main_app', (route) => false);
        }
      } else {
        if (mounted) {
          _showErrorSnackBar("Sign up failed. User data unavailable.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = "An error occurred during sign up.";
        if (e.code == 'email-already-in-use') {
          errorMessage =
              "This email is already registered. Please log in or use a different email.";
        } else if (e.code == 'weak-password') {
          errorMessage =
              "The password provided is too weak. Please use a stronger password (min. 6 characters).";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is not valid.";
        } else if (e.code == 'network-request-failed') {
          errorMessage =
              "Network error. Please check your connection and try again.";
        } else {
          print(
              "FirebaseAuthException during sign up: ${e.code} - ${e.message}");
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e, s) {
      print("Unexpected sign up error: $e\nStacktrace: $s");
      if (mounted) {
        _showErrorSnackBar(
            "An unexpected error occurred. Please try again later.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatOnboardingDataForDisplay(Map<String, dynamic> data) {
    final displayableData = Map<String, dynamic>.from(data);
    displayableData
        .remove('completed'); // Ne pas afficher 'completed' dans le résumé

    final buffer = StringBuffer();
    if (displayableData.isEmpty) {
      return "No preferences selected yet.";
    }

    displayableData.forEach((key, value) {
      if (value == null)
        return; // Ne pas afficher les clés avec des valeurs null

      String displayKey = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');

      if (key == 'physical_stats' && value is Map<String, dynamic>) {
        final stats = PhysicalStats.fromMap(
            value); // Utiliser le modèle pour un formatage propre
        buffer.writeln("- $displayKey:");
        if (stats.age != null) buffer.writeln("  - Age: ${stats.age} years");
        if (stats.weightKg != null)
          buffer.writeln("  - Weight: ${stats.weightKg} kg");
        if (stats.heightM != null)
          buffer.writeln("  - Height: ${stats.heightM} m");
        if (stats.targetWeightKg != null)
          buffer.writeln("  - Target Weight: ${stats.targetWeightKg} kg");
      } else if (value is List) {
        if (value.isNotEmpty) {
          // Afficher seulement si la liste n'est pas vide
          buffer.writeln("- $displayKey: ${value.join(', ')}");
        }
      } else {
        buffer.writeln("- $displayKey: $value");
      }
    });

    String result = buffer.toString().trim();
    return result.isEmpty ? "No preferences selected yet." : result;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // Vérifier si des données significatives existent (en excluant 'completed' s'il est le seul champ)
    final bool hasMeaningfulOnboardingData = widget.onboardingData != null &&
        widget.onboardingData!.keys
            .any((k) => k != 'completed' && widget.onboardingData![k] != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            hasMeaningfulOnboardingData // ou widget.onboardingData != null && widget.onboardingData!.isNotEmpty
                ? "Final Step"
                : "Create Account",
            style: textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: ModalRoute.of(context)?.canPop == true
            ? BackButton(color: colorScheme.onSurface)
            : null,
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
                  hasMeaningfulOnboardingData
                      ? "Create Your Account"
                      : "Get Started with GymGenius",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  hasMeaningfulOnboardingData
                      ? "Your preferences will be saved with your new account."
                      : "Enter your details below to create your account.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
                SizedBox(height: hasMeaningfulOnboardingData ? 15 : 30),
                if (hasMeaningfulOnboardingData) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.outlineVariant
                              .withAlpha((0.5 * 255).round())),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Summary of Your Preferences:",
                          style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatOnboardingDataForDisplay(
                              widget.onboardingData!),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email_outlined,
                        color: colorScheme.onSurfaceVariant),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    labelText: "Password (min. 6 characters)",
                    prefixIcon: Icon(Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(
                          () => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() =>
                          _isConfirmPasswordObscured =
                              !_isConfirmPasswordObscured),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                      _isLoading ? null : _signUpWithEmail(),
                ),
                const SizedBox(height: 35),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.primary))
                    : ElevatedButton(
                        onPressed: _signUpWithEmail,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        child: Text(
                          hasMeaningfulOnboardingData
                              ? "CREATE ACCOUNT & GET STARTED"
                              : "SIGN UP",
                        ),
                      ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
