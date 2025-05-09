// lib/screens/auth/signin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// The import for static_routine is not necessary here.

class SignInScreen extends StatefulWidget {
  final Map<String, dynamic>?
      onboardingData; // Received from the previous onboarding screen
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
        // Prepare data for the user document in Firestore
        final Map<String, dynamic> userProfileData = {
          'email': user.email,
          'uid':
              user.uid, // It's useful to have the UID in the document as well
          'createdAt': FieldValue
              .serverTimestamp(), // Use server timestamp for creation time
          'displayName':
              user.email?.split('@')[0] ?? 'New User', // A default display name
          // Store onboarding data in a dedicated map field
          // Use the spread operator on a conditionally created map
          if (widget.onboardingData != null &&
              widget.onboardingData!.isNotEmpty) ...{
            'onboardingData': widget.onboardingData
          } else ...{
            'onboardingData': {}
          }, // Always an empty map if no data
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userProfileData);

        if (mounted) {
          // Navigate to the main app screen and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
              context, '/main_app', (route) => false);
        }
      } else {
        // This case should ideally not happen if createUserWithEmailAndPassword succeeds
        // and returns a non-null user, but it's a good defensive check.
        if (mounted) {
          _showErrorSnackBar(
              "Sign up failed. User data unavailable after creation.");
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
              "The password provided is too weak. Please use a stronger password.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is not valid.";
        } else {
          // For other Firebase errors, you might log e.message for debugging
          // but show a generic message to the user.
          print(
              "FirebaseAuthException during sign up: ${e.code} - ${e.message}");
          // errorMessage = e.message ?? errorMessage; // Avoid showing raw Firebase messages to users
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e, s) {
      // Catch any other unexpected errors
      print("Unexpected sign up error: $e\nStacktrace: $s");
      if (mounted) {
        _showErrorSnackBar(
            "An unexpected error occurred. Please try again later.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to show error SnackBars
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme =
        Theme.of(context).textTheme; // For consistent text styling

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating, // Consistent with LoginScreen
      ),
    );
  }

  // Formats onboarding data for display in the summary.
  String _formatOnboardingDataForDisplay(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      // Capitalize and replace underscores for better readability of keys
      String displayKey = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');

      if (value is Map<String, dynamic>) {
        // Explicitly check for Map<String, dynamic>
        buffer.writeln("- $displayKey:");
        value.forEach((subKey, subValue) {
          String displaySubKey = subKey
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1)
                  : '')
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
          onPressed: () =>
              Navigator.of(context).pop(), // Standard back navigation
        ),
        // title: Text("Create Account"), // Optional title
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
                  "Final Step: Create Your Account", // Slightly rephrased for clarity
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

                // Display onboarding data summary if available
                if (widget.onboardingData != null &&
                    widget.onboardingData!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16), // Slightly more padding
                    margin: const EdgeInsets.only(
                        bottom: 25), // Slightly more margin
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerLowest, // Subtle background
                      borderRadius:
                          BorderRadius.circular(12), // Consistent border radius
                      border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Summary of Your Preferences:",
                          style: textTheme.titleMedium?.copyWith(
                              // Using titleMedium for more emphasis
                              fontWeight: FontWeight.bold,
                              color:
                                  colorScheme.onSurface // Ensure good contrast
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatOnboardingDataForDisplay(
                              widget.onboardingData!),
                          style: textTheme.bodyMedium?.copyWith(
                            // Using bodyMedium for better readability
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4, // Line height for readability
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon:
                        Icon(Icons.email_outlined, color: colorScheme.primary),
                    // Using the global theme for InputDecoration by default,
                    // but can be customized here if needed.
                    // border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                ),
                const SizedBox(height: 15),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password (min. 6 characters)",
                    prefixIcon:
                        Icon(Icons.lock_outline, color: colorScheme.primary),
                    // border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

                // Sign Up Button
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.primary))
                    : ElevatedButton(
                        onPressed: _signUpWithEmail,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16), // Slightly taller button
                          textStyle: textTheme.labelLarge?.copyWith(
                            // Using labelLarge for button text
                            fontWeight: FontWeight.bold,
                            // letterSpacing: 0.5, // Optional: for better text appearance
                          ),
                        ),
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
