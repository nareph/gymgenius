// lib/blocs/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// Internal event to handle user changes from the stream
class _AuthUserChanged extends AuthEvent {
  final User? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

// Public event to request a sign-out
class AuthLogoutRequested extends AuthEvent {}

// Public event to request a re-check of the authentication state
class AuthStateCheckRequested extends AuthEvent {}

