// lib/blocs/auth/auth_state.dart
part of 'auth_bloc.dart';

// Added a status for the offline-no-cache case
enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  authenticatedOfflineNoCache
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final bool isProfileComplete;

  const AuthState._({
    required this.status,
    this.user,
    this.isProfileComplete = false,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(
      {required User user, required bool isProfileComplete})
      : this._(
            status: AuthStatus.authenticated,
            user: user,
            isProfileComplete: isProfileComplete);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  // New state to handle the offline case
  const AuthState.authenticatedOfflineNoCache({required User user})
      : this._(status: AuthStatus.authenticatedOfflineNoCache, user: user);

  @override
  List<Object?> get props => [status, user, isProfileComplete];
}
