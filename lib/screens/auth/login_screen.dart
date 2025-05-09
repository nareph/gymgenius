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

  // --- Login Function ---
  Future<void> _loginWithEmail() async {
    // Validate the form
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
      // Redirect to the main app screen upon successful login
      if (mounted) {
        // '/main_app' should be the route name for your main dashboard or home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main_app',
          (Route<dynamic> route) => false, // Removes all previous routes
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Display specific Firebase Auth error messages
        String errorMessage =
            "Login failed. Please check your credentials."; // Default message
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          // 'invalid-credential' is a common newer code
          errorMessage = "Invalid email or password. Please try again.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "The email address is badly formatted.";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many login attempts. Please try again later.";
        }
        // else {
        //   errorMessage = e.message ?? errorMessage; // Use Firebase message if available and more specific
        // }
        // It's often better to show generic messages for security for common auth errors.
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      // Catch other potential errors
      if (mounted) {
        print("Login error: $e"); // Log for debugging
        _showErrorSnackBar("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper to show error SnackBars using the theme's styling
  void _showErrorSnackBar(String message) {
    // Check if the widget is still mounted before showing SnackBar
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
        duration: const Duration(seconds: 3), // Display duration
        behavior:
            SnackBarBehavior.floating, // Optional: for a floating SnackBar
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
    // Access theme properties
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // final inputTheme = Theme.of(context).inputDecorationTheme; // Not explicitly needed here if using global theme

    return Scaffold(
      // --- AppBar ---
      // Style comes from AppBarTheme in AppTheme
      // The back button is automatically added by default during push navigation.
      appBar: AppBar(
          // title: const Text("Login"), // Title would be styled by AppBarTheme
          ),
      // --- Body ---
      // Background color comes from scaffoldBackgroundColor in theme
      body: Center(
        // Vertically centers content if it's small
        child: SingleChildScrollView(
          // Allows scrolling for smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Centers the column vertically on the screen
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretches children horizontally
              children: [
                // --- Screen Title ---
                Text(
                  "Welcome Back!", // Title
                  textAlign: TextAlign.center,
                  style:
                      textTheme.headlineMedium, // Uses theme's headlineMedium
                ),
                Text(
                  "Log in to your account", // Subtitle
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge
                      ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 40), // Increased spacing

                // --- Email Field ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // Text style inherited from theme
                  decoration: const InputDecoration(
                    // Uses InputDecorationTheme from global theme
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation regex
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

                // --- Password Field ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Hides password input
                  // Text style inherited from theme
                  decoration: const InputDecoration(
                    // Uses InputDecorationTheme from global theme
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 35),

                // --- Login Button ---
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme
                              .secondary, // Use secondary color for loading
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _loginWithEmail,
                        // Style comes from ElevatedButtonThemeData in global theme
                        child: const Text(
                            "LOG IN"), // Conventionally uppercase for buttons
                      ),

                // Optional: "Forgot Password?" button
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       // TODO: Implement forgot password logic
                //       // e.g., Navigator.pushNamed(context, '/forgot_password');
                //     },
                //     child: Text("Forgot Password?"),
                //   ),
                // ),

                // Optional: Navigate to Sign Up Screen
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text("Don't have an account?", style: textTheme.bodyMedium),
                //     TextButton(
                //       onPressed: () {
                //         // TODO: Navigate to your sign-up screen
                //         // e.g., Navigator.pushNamed(context, '/signup');
                //       },
                //       child: Text("Sign Up"),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
