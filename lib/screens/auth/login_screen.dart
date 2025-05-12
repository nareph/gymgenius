// lib/screens/auth/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // For the loading indicator
  bool _isPasswordObscured = true; // For password visibility toggle

  // --- Login Function ---
  Future<void> _loginWithEmail() async {
    // Validate the form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Redirect to the main app screen upon successful login
      if (mounted) {
        // It's usually better for AuthWrapper to handle this navigation based on auth state changes
        // However, if you want explicit navigation here:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main_app', // Should be the route name for your main dashboard
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage =
            "Login failed. Please check your credentials."; // Default
        // TODO: Localize all these error messages
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = "Invalid email or password. Please try again.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is badly formatted.";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many login attempts. Please try again later.";
        } else if (e.code == 'network-request-failed') {
          errorMessage =
              "Network error. Please check your connection and try again.";
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      // Catch other potential errors
      if (mounted) {
        print("Login error: $e"); // Log for debugging
        _showErrorSnackBar(
            "An unexpected error occurred. Please try again."); // TODO: Localize
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Forgot Password Function ---
  Future<void> _sendPasswordResetEmail() async {
    // Simple validation for email (can be more robust)
    // We only need the email field for password reset
    if (_emailController.text.trim().isEmpty ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_emailController.text.trim())) {
      _showErrorSnackBar(
          "Please enter a valid email address to reset your password."); // TODO: Localize
      return;
    }

    FocusScope.of(context).unfocus(); // Hide keyboard

    setState(() {
      _isLoading = true; // Use the same loading indicator
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Password reset email sent to ${_emailController.text.trim()}. Please check your inbox (and spam folder).", // TODO: Localize
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant), // Using a less alarming color for success
            ),
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // Using a less alarming background
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration:
                const Duration(seconds: 5), // Longer duration for this message
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage =
            "Failed to send password reset email. Please try again."; // TODO: Localize
        if (e.code == 'user-not-found') {
          // It's often better not to reveal if an email exists for security reasons
          // So, a generic message might be preferred for 'user-not-found' in production
          errorMessage =
              "If this email is registered, a password reset link has been sent."; // TODO: Localize
        } else if (e.code == 'invalid-email') {
          errorMessage =
              "The email address is badly formatted."; // TODO: Localize
        } else if (e.code == 'network-request-failed') {
          errorMessage =
              "Network error. Please check your connection and try again."; // TODO: Localize
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        print("Password Reset error: $e"); // Log for debugging
        _showErrorSnackBar(
            "An unexpected error occurred. Please try again."); // TODO: Localize
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper to show error SnackBars
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
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16), // Add some margin for floating
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)), // Rounded corners
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
                  "Welcome Back!", // TODO: Localize
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  "Log in to continue your fitness journey", // TODO: Localize
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface
                        .withAlpha((255 * 0.7).round()), // FIXED withOpacity
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email", // TODO: Localize
                    prefixIcon: Icon(Icons.email_outlined,
                        color: colorScheme.onSurfaceVariant),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email'; // TODO: Localize
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address'; // TODO: Localize
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
                    labelText: "Password", // TODO: Localize
                    prefixIcon: Icon(Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password'; // TODO: Localize
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                      _isLoading ? null : _loginWithEmail(),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : _sendPasswordResetEmail, // Connect to the new function
                    child: Text(
                      "Forgot Password?", // TODO: Localize
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _loginWithEmail,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        child: const Text("LOG IN"), // TODO: Localize
                      ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?", // TODO: Localize
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(
                            (255 * 0.7).round()), // FIXED withOpacity
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Ensure you have a '/signup' route or use direct navigation.
                        // If SignUpScreen needs onboarding data, it should be optional or handled.
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text(
                        "Sign Up", // TODO: Localize
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
