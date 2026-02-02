// lib/blocs/auth/auth_state.dart
part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  authenticatedOfflineNoCache,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final bool isProfileComplete;

  const AuthState._({
    required this.status,
    this.user,
    this.isProfileComplete = false,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated({
    required UserModel user,
    required bool isProfileComplete,
  }) : this._(
          status: AuthStatus.authenticated,
          user: user,
          isProfileComplete: isProfileComplete,
        );

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.authenticatedOfflineNoCache({required UserModel user})
      : this._(
          status: AuthStatus.authenticatedOfflineNoCache,
          user: user,
        );

  @override
  List<Object?> get props => [status, user, isProfileComplete];

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.uid}, isProfileComplete: $isProfileComplete)';
  }
}
