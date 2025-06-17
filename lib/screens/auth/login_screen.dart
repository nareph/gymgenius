// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gymgenius/blocs/login/login_bloc.dart';
import 'package:gymgenius/repositories/auth_repository.dart';
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/services/logger_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // Provide the LoginBloc to the widget tree below.
      body: BlocProvider(
        create: (context) => LoginBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // BlocListener handles "side effects" like navigation or showing SnackBars.
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        Log.info(
            "LoginForm: BlocListener detected state change: ${state.status}");
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Authentication Failure')),
            );
        }
        if (state.status.isSuccess && state.successMessage != null) {
          // Show success message
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
        }
        // AuthBloc will handle navigation automatically upon successful login.
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Welcome Back!",
                  style: textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("Log in to continue your fitness journey",
                  style: textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              _EmailInput(),
              const SizedBox(height: 20),
              _PasswordInput(
                isObscured: _isPasswordObscured,
                onToggleVisibility: () {
                  setState(() => _isPasswordObscured = !_isPasswordObscured);
                },
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => context
                        .read<LoginBloc>()
                        .add(LoginPasswordResetRequested()),
                    child: const Text("Forgot Password?")),
              ),
              const SizedBox(height: 25),
              _LoginButton(),
              const SizedBox(height: 30),
              _SignUpButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// Private sub-widgets to keep the build method clean.

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) =>
              context.read<LoginBloc>().add(LoginEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText:
                state.email.displayError != null ? 'Invalid Email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onToggleVisibility;

  const _PasswordInput(
      {required this.isObscured, required this.onToggleVisibility});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(password)),
          obscureText: isObscured,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: state.password.displayError != null
                ? 'Password cannot be empty'
                : null,
            suffixIcon: IconButton(
              icon: Icon(isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: onToggleVisibility,
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                key: const Key('loginForm_continue_raisedButton'),
                onPressed: state.isValid
                    ? () => context.read<LoginBloc>().add(LoginSubmitted())
                    : null,
                child: const Text('LOG IN'),
              );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignUpScreen()),
            (route) => false,
          ),
          child: const Text("Sign Up"),
        ),
      ],
    );
  }
}
