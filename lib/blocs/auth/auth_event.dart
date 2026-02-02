// lib/blocs/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class _AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthStateCheckRequested extends AuthEvent {
  const AuthStateCheckRequested();
}
