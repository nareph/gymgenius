// lib/domain/repositories/user_repository.dart

import 'package:gymgenius/domain/entities/user.dart';

/// Contract for user persistence operations.
abstract interface class UserRepository {
  Future<User?> getCurrentUser();
  Future<void> saveUser(User user);
  Future<void> deleteUser(String userId);
  Stream<User?> watchUser(String userId);
}
