part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final bool isProfileComplete;

  /// Required question ids still missing when [isProfileComplete] is
  /// false — lets ProfileSetupScreen resume with only what's left instead
  /// of the whole questionnaire. Empty when the profile is complete or
  /// unknown.
  final List<String> missingFieldIds;

  const AuthState._({
    required this.status,
    this.user,
    this.isProfileComplete = false,
    this.missingFieldIds = const [],
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated({
    required User user,
    required bool isProfileComplete,
    List<String> missingFieldIds = const [],
  }) : this._(
          status: AuthStatus.authenticated,
          user: user,
          isProfileComplete: isProfileComplete,
          missingFieldIds: missingFieldIds,
        );

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user, isProfileComplete, missingFieldIds];

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.id}, isProfileComplete: $isProfileComplete, missingFieldIds: $missingFieldIds)';
  }
}
