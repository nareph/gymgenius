// lib/blocs/login/login_state.dart
part of 'login_bloc.dart';

/// Represents the state of the login screen.
class LoginState extends Equatable {
  const LoginState({
    this.status = FormzSubmissionStatus.initial,
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.errorMessage,
    this.successMessage,
  });

  final FormzSubmissionStatus status;
  final Email email;
  final Password password;
  final bool isValid;
  final String? errorMessage;
  final String? successMessage; // For password reset success

  LoginState copyWith({
    FormzSubmissionStatus? status,
    Email? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
    String? successMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage, // Always overwrite
      successMessage: successMessage, // Always overwrite
    );
  }

  @override
  List<Object?> get props =>
      [status, email, password, isValid, errorMessage, successMessage];
}
