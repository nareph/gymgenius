// lib/blocs/login/login_event.dart
part of 'login_bloc.dart';

// Abstract base class for all login-related events.
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched when the user types in the email field.
class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

/// Event dispatched when the user types in the password field.
class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);
  final String password;

  @override
  List<Object> get props => [password];
}

/// Event dispatched when the user presses the login button.
class LoginSubmitted extends LoginEvent {}

/// Event dispatched when the user requests a password reset.
class LoginPasswordResetRequested extends LoginEvent {}