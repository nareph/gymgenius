// lib/core/exceptions/auth_exception.dart

/// Authentication-specific exception.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
