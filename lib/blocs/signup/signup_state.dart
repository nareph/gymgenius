// lib/blocs/signup/signup_state.dart
import 'package:equatable/equatable.dart';

enum SignUpStatus {
  initial,
  loading,
  success,
  failure,
}

class SignUpState extends Equatable {
  final String email;
  final String password;
  final SignUpStatus status;
  final String? errorMessage;

  const SignUpState({
    this.email = '',
    this.password = '',
    this.status = SignUpStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    String? email,
    String? password,
    SignUpStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage];
}
