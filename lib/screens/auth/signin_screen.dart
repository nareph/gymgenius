// lib/screens/auth/signin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// L'import de static_routine n'est pas nécessaire ici

class SignInScreen extends StatefulWidget {
  final Map<String, dynamic>?
      onboardingData; // Reçu de l'écran d'onboarding précédent
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user;

      if (user != null) {
        // Préparer les données pour le document utilisateur
        // Les onboardingData sont stockées sous une clé 'onboardingData'
        final Map<String, dynamic> userProfileData = {
          'email': user.email,
          'uid': user.uid, // Utile d'avoir l'UID dans le document aussi
          'createdAt': FieldValue.serverTimestamp(),
          'displayName':
              user.email?.split('@')[0] ?? 'New User', // Un nom par défaut
          // Stocker les données d'onboarding dans un champ map dédié
          // Utiliser le spread operator sur un map créé conditionnellement
          if (widget.onboardingData != null &&
              widget.onboardingData!.isNotEmpty) ...{
            'onboardingData': widget.onboardingData
          } else ...{
            'onboardingData': {}
          }, // Toujours un map vide si pas de données
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userProfileData);

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/main_app', (route) => false);
        }
      } else {
        if (mounted)
          _showErrorSnackBar("Sign up failed. User data unavailable.");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = "An error occurred during sign up.";
        if (e.code == 'email-already-in-use') {
          errorMessage = "This email is already registered. Please log in.";
        } else if (e.code == 'weak-password') {
          errorMessage = "The password provided is too weak.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is not valid.";
        } else {
          errorMessage = e.message ?? errorMessage;
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e, s) {
      print("Sign up error: $e\n$s");
      if (mounted)
        _showErrorSnackBar("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onError)),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  String _formatOnboardingDataForDisplay(Map<String, dynamic> data) {
    // ... (votre fonction de formatage est bonne)
    final buffer = StringBuffer();
    data.forEach((key, value) {
      // Vous voudrez peut-être utiliser les 'text' des OnboardingQuestion ici pour un affichage plus convivial
      String displayKey = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((e) => e[0].toUpperCase() + e.substring(1))
          .join(' ');
      if (value is Map) {
        buffer.writeln("- $displayKey:");
        (value).forEach((subKey, subValue) {
          String displaySubKey = subKey
              .replaceAll('_', ' ')
              .split(' ')
              .map((e) => e[0].toUpperCase() + e.substring(1))
              .join(' ');
          buffer.writeln("  - $displaySubKey: $subValue");
        });
      } else if (value is List) {
        buffer.writeln("- $displayKey: ${value.join(', ')}");
      } else {
        buffer.writeln("- $displayKey: $value");
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: Text("Create Account"), // Optionnel
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
                  "Final Step: Create Account",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your preferences will be saved with your new account.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 25),
                if (widget.onboardingData != null &&
                    widget.onboardingData!.isNotEmpty) ...[
                  Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: colorScheme
                              .surfaceContainerLowest, // Un fond subtil
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  colorScheme.outlineVariant.withOpacity(0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Summary of Your Preferences:",
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatOnboardingDataForDisplay(
                                widget.onboardingData!),
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5),
                          ),
                        ],
                      )),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon:
                        Icon(Icons.email_outlined, color: colorScheme.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Please enter your email';
                    if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) return 'Enter a valid email address';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password (min. 6 characters)",
                    prefixIcon:
                        Icon(Icons.lock_outline, color: colorScheme.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter your password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 35),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.primary))
                    : ElevatedButton(
                        onPressed: _signUpWithEmail,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        child: const Text("CREATE ACCOUNT & GET STARTED"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
