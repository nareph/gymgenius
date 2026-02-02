// lib/blocs/signup/signup_event.dart
import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpEmailChanged extends SignUpEvent {
  final String email;
  const SignUpEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class SignUpPasswordChanged extends SignUpEvent {
  final String password;
  const SignUpPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class SignUpSubmitted extends SignUpEvent {
  final Map<String, dynamic>? onboardingData;
  const SignUpSubmitted({this.onboardingData});

  @override
  List<Object?> get props => [onboardingData];
}
