// lib/screens/auth/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gymgenius/blocs/signup/signup_bloc.dart';
import 'package:gymgenius/models/onboarding.dart'; // For PhysicalStats
import 'package:gymgenius/models/onboarding_question.dart'; // For questions
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/screens/auth/login_screen.dart';

class SignUpScreen extends StatelessWidget {
  final Map<String, dynamic>? onboardingData;

  const SignUpScreen({super.key, this.onboardingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (onboardingData != null && onboardingData!.isNotEmpty)
              ? "Final Step"
              : "Create Account",
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocProvider(
        create: (context) => SignUpBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: SignUpForm(onboardingData: onboardingData),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  const SignUpForm({super.key, this.onboardingData});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // Local UI state for password visibility.
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Controller for the confirmation password field to check for equality.
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to the BLoC's password changes to update the local controller.
    context.read<SignUpBloc>().stream.listen((state) {
      if (_passwordController.text != state.password.value) {
        _passwordController.text = state.password.value;
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Sign-Up Failed')),
            );
        }
        // Navigation is handled globally by AuthBloc and AuthWrapper,
        // so no navigation logic is needed here on success.
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(hasOnboardingData: widget.onboardingData != null),
              if (widget.onboardingData != null)
                _OnboardingSummary(data: widget.onboardingData!),
              const SizedBox(height: 20),
              _EmailInput(),
              const SizedBox(height: 20),
              _PasswordInput(
                  isObscured: _isPasswordObscured,
                  onToggle: () => setState(
                      () => _isPasswordObscured = !_isPasswordObscured)),
              const SizedBox(height: 20),
              _ConfirmPasswordInput(
                passwordController: _passwordController,
                isObscured: _isConfirmPasswordObscured,
                onToggle: () => setState(() =>
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
              ),
              const SizedBox(height: 35),
              _SignUpButton(onboardingData: widget.onboardingData),
              const SizedBox(height: 30),
              const _LoginRedirectButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UI Sub-Widgets for Clarity ---

class _Header extends StatelessWidget {
  final bool hasOnboardingData;
  const _Header({required this.hasOnboardingData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          hasOnboardingData
              ? "Create Your Account"
              : "Get Started with GymGenius",
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold, color: colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          hasOnboardingData
              ? "Your preferences will be saved with your new account."
              : "Enter your details below to create your account.",
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class _OnboardingSummary extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OnboardingSummary({required this.data});

  String _formatOnboardingDataForDisplay() {
    final displayableData = Map<String, dynamic>.from(data);
    displayableData.remove('completed');

    final buffer = StringBuffer();
    if (displayableData.isEmpty) {
      return "No preferences selected yet.";
    }

    for (var question in defaultOnboardingQuestions) {
      final key = question.id;
      final value = displayableData[key];

      if (value == null || (value is List && value.isEmpty)) {
        continue;
      }

      String displayKey = question.text;
      if (displayKey.endsWith("?")) {
        displayKey = displayKey.substring(0, displayKey.length - 1);
      }

      if (key == 'physical_stats' && value is Map<String, dynamic>) {
        final stats = PhysicalStats.fromMap(value);
        if (stats.isNotEmpty) {
          buffer.writeln("- $displayKey:");
          if (stats.age != null) buffer.writeln("  - Age: ${stats.age} years");
          if (stats.weightKg != null) {
            buffer.writeln("  - Weight: ${stats.weightKg} kg");
          }
          if (stats.heightM != null) {
            buffer.writeln("  - Height: ${stats.heightM} m");
          }
          if (stats.targetWeightKg != null) {
            buffer.writeln("  - Target Weight: ${stats.targetWeightKg} kg");
          }
        }
      } else if (value is List) {
        final selectedOptionTexts = value.map((val) {
          try {
            return question.options.firstWhere((opt) => opt.value == val).text;
          } catch (e) {
            return val.toString();
          }
        }).toList();
        if (selectedOptionTexts.isNotEmpty) {
          buffer.writeln("- $displayKey: ${selectedOptionTexts.join(', ')}");
        }
      } else if (question.type == QuestionType.singleChoice) {
        try {
          final selectedOptionText =
              question.options.firstWhere((opt) => opt.value == value).text;
          buffer.writeln("- $displayKey: $selectedOptionText");
        } catch (e) {
          buffer.writeln("- $displayKey: $value");
        }
      } else {
        buffer.writeln("- $displayKey: $value");
      }
    }

    String result = buffer.toString().trim();
    return result.isEmpty ? "No preferences selected yet." : result;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Summary of Your Preferences:", style: textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(_formatOnboardingDataForDisplay(), style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (p, c) => p.email != c.email,
      builder: (context, state) {
        return TextField(
          onChanged: (email) =>
              context.read<SignUpBloc>().add(SignUpEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            errorText: state.email.displayError != null
                ? 'Please enter a valid email'
                : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onToggle;
  const _PasswordInput({required this.isObscured, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      buildWhen: (p, c) => p.password != c.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<SignUpBloc>().add(SignUpPasswordChanged(password)),
          obscureText: isObscured,
          decoration: InputDecoration(
            labelText: 'Password (min. 6 characters)',
            errorText: state.password.displayError != null
                ? 'Password must be at least 6 characters'
                : null,
            suffixIcon: IconButton(
              icon: Icon(isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: onToggle,
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  final TextEditingController passwordController;
  final bool isObscured;
  final VoidCallback onToggle;

  const _ConfirmPasswordInput({
    required this.passwordController,
    required this.isObscured,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Using TextFormField for its validator
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        suffixIcon: IconButton(
          icon: Icon(isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: onToggle,
        ),
      ),
      validator: (value) {
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}

class _SignUpButton extends StatelessWidget {
  final Map<String, dynamic>? onboardingData;
  const _SignUpButton({this.onboardingData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: state.isValid
                    ? () => context
                        .read<SignUpBloc>()
                        .add(SignUpSubmitted(onboardingData: onboardingData))
                    : null,
                child: const Text('CREATE ACCOUNT'),
              );
      },
    );
  }
}

class _LoginRedirectButton extends StatelessWidget {
  const _LoginRedirectButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          ),
          child: const Text("Log In"),
        ),
      ],
    );
  }
}
