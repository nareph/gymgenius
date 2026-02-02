// lib/screens/auth/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/blocs/signup/signup_bloc.dart';
import 'package:gymgenius/blocs/signup/signup_event.dart';
import 'package:gymgenius/blocs/signup/signup_state.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/services/logger_service.dart';

class SignUpScreen extends StatelessWidget {
  final Map<String, dynamic>? onboardingData;
  final VoidCallback? onLoginRequested;

  const SignUpScreen({
    super.key,
    this.onboardingData,
    this.onLoginRequested,
  });

  @override
  Widget build(BuildContext context) {
    // Create SignUpBloc locally with AuthRepository from context
    return BlocProvider(
      create: (context) => SignUpBloc(
        authRepository: context.read<AuthRepository>(),
      ),
      child: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == SignUpStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Sign up failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          // Success is handled by AuthWrapper
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Account'),
            automaticallyImplyLeading: false,
          ),
          body: _SignUpForm(
            onboardingData: onboardingData,
            onLoginRequested: onLoginRequested,
          ),
        ),
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;
  final VoidCallback? onLoginRequested;

  const _SignUpForm({
    this.onboardingData,
    this.onLoginRequested,
  });

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) =>
                      context.read<SignUpBloc>().add(SignUpEmailChanged(value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  onChanged: (value) => context
                      .read<SignUpBloc>()
                      .add(SignUpPasswordChanged(value)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.status == SignUpStatus.loading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            Log.debug('SignUpScreen: Creating account');
                            context.read<SignUpBloc>().add(
                                  SignUpSubmitted(
                                    onboardingData: widget.onboardingData,
                                  ),
                                );
                          }
                        },
                  child: state.status == SignUpStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: 16),
                if (widget.onLoginRequested != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: widget.onLoginRequested,
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
