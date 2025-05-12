// lib/screens/auth/sign_up_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  final Map<String, dynamic>?
      onboardingData; // Received from the onboarding screen

  const SignUpScreen({super.key, this.onboardingData});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // For confirm password
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  // bool _agreedToTerms = false; // Uncomment if adding Terms & Conditions

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
    // Uncomment if adding Terms & Conditions
    // if (!_agreedToTerms) {
    //   _showErrorSnackBar("Please agree to the Terms & Conditions to continue.");
    //   return;
    // }

    // Hide keyboard
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
        final Map<String, dynamic> userProfileData = {
          'email': user.email,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'displayName': user.email?.split('@')[0] ?? 'New User',
          'onboardingData':
              widget.onboardingData ?? {}, // Ensure it's at least an empty map
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
        if (mounted) {
          // TODO: Localize
          _showErrorSnackBar("Sign up failed. User data unavailable.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // TODO: Localize all error messages
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
        // TODO: Localize
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
    final buffer = StringBuffer();
    data.forEach((key, value) {
      String displayKey = key
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');

      if (value is Map<String, dynamic>) {
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
    return buffer.toString().trim(); // Trim to remove trailing newline if any
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasOnboardingData =
        widget.onboardingData != null && widget.onboardingData!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            hasOnboardingData
                ? "Final Step"
                : "Create Account", // TODO: Localize
            style: textTheme.titleLarge // Ensure AppBarTheme is set
            ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        // The default back button should appear if this screen was pushed.
        // If presented modally or as a replacement, a manual back might be needed if `canPop` is false.
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
                  hasOnboardingData
                      ? "Create Your Account"
                      : "Get Started with GymGenius", // TODO: Localize
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  hasOnboardingData
                      ? "Your preferences will be saved with your new account."
                      : "Enter your details below to create your account.", // TODO: Localize
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: hasOnboardingData ? 15 : 30),

                if (hasOnboardingData) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Summary of Your Preferences:", // TODO: Localize
                          style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight
                                  .w600, // Slightly less bold than title
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
                    labelText: "Email Address", // TODO: Localize
                    prefixIcon: Icon(Icons.email_outlined,
                        color: colorScheme.onSurfaceVariant),
                  ),
                  validator: (value) {
                    // TODO: Localize validation messages
                    if (value == null || value.trim().isEmpty)
                      return 'Please enter your email';
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
                    labelText: "Password (min. 6 characters)", // TODO: Localize
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
                    // TODO: Localize
                    if (value == null || value.isEmpty)
                      return 'Please enter a password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters long';
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
                    labelText: "Confirm Password", // TODO: Localize
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
                    // TODO: Localize
                    if (value == null || value.isEmpty)
                      return 'Please confirm your password';
                    if (value != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                      _isLoading ? null : _signUpWithEmail(),
                ),
                const SizedBox(height: 35),

                // --- Terms and Conditions Checkbox (Example) ---
                // Uncomment and adapt if you need this
                // CheckboxListTile(
                //   title: RichText(
                //     text: TextSpan(
                //       text: 'I agree to the ', // TODO: Localize
                //       style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                //       children: <TextSpan>[
                //         TextSpan(
                //             text: 'Terms & Conditions', // TODO: Localize
                //             style: TextStyle(color: colorScheme.primary, decoration: TextDecoration.underline),
                //             recognizer: TapGestureRecognizer()..onTap = () {
                //               // TODO: Launch URL for Terms & Conditions
                //               print('Navigate to Terms & Conditions');
                //             }),
                //         const TextSpan(text: ' and '), // TODO: Localize
                //         TextSpan(
                //             text: 'Privacy Policy', // TODO: Localize
                //             style: TextStyle(color: colorScheme.primary, decoration: TextDecoration.underline),
                //             recognizer: TapGestureRecognizer()..onTap = () {
                //               // TODO: Launch URL for Privacy Policy
                //               print('Navigate to Privacy Policy');
                //             }),
                //       ],
                //     ),
                //   ),
                //   value: _agreedToTerms,
                //   onChanged: (bool? value) {
                //     setState(() {
                //       _agreedToTerms = value ?? false;
                //     });
                //   },
                //   controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                //   contentPadding: EdgeInsets.zero,
                //   dense: true,
                // ),
                // const SizedBox(height: 15), // Add spacing if T&C is enabled

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
                          hasOnboardingData
                              ? "CREATE ACCOUNT & GET STARTED"
                              : "SIGN UP", // TODO: Localize
                        ),
                      ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?", // TODO: Localize
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        "Log In", // TODO: Localize
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
