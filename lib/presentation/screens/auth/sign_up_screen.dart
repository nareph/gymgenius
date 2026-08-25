import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/presentation/blocs/signup/signup_bloc.dart';
import 'package:gymgenius/presentation/validators/form_validators.dart';

/// Screen for creating a new account.
///
/// After successful sign‑up, the user is authenticated but does NOT have
/// a HealthProfile yet — the flow will redirect to CompleteProfile.
class SignUpScreen extends StatelessWidget {
  final VoidCallback? onLoginRequested;

  const SignUpScreen({
    super.key,
    this.onLoginRequested,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(
        authRepository: getIt<AuthRepository>(),
      ),
      child: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == SignUpStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Sign up failed',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }

          if (state.status == SignUpStatus.success) {
            Log.debug('SignUpScreen: Account created successfully');
            // No HealthProfile is created here — the AuthBloc will detect
            // the missing profile and trigger CompleteProfile.
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Account'),
            automaticallyImplyLeading: false,
          ),
          body: _SignUpForm(
            onLoginRequested: onLoginRequested,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Internal form widget
// ---------------------------------------------------------------------

class _SignUpForm extends StatefulWidget {
  final VoidCallback? onLoginRequested;

  const _SignUpForm({
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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<SignUpBloc>().add(
          SignUpSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        final isLoading = state.status == SignUpStatus.loading;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email field
                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    context.read<SignUpBloc>().add(
                          SignUpEmailChanged(value),
                        );
                  },
                  validator: (value) {
                    final email = Email.dirty(value ?? '');
                    if (!email.isValid) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    context.read<SignUpBloc>().add(
                          SignUpPasswordChanged(value),
                        );
                  },
                  onFieldSubmitted: (_) {
                    if (!isLoading) {
                      _submit(context);
                    }
                  },
                  validator: (value) {
                    final password = Password.dirty(value ?? '');
                    if (!password.isValid) {
                      return password.displayError ==
                              PasswordValidationError.empty
                          ? 'Password cannot be empty'
                          : 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: isLoading ? null : () => _submit(context),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: 16),

                // Login link (conditional)
                if (widget.onLoginRequested != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: isLoading ? null : widget.onLoginRequested,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
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
