// lib/data/repositories/user_repository_impl.dart

import 'dart:async';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../mappers/user_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl();

  @override
  Future<User?> getCurrentUser() async {
    final userId = HiveDatasource.getCurrentUserId();
    if (userId == null) return null;
    final model = HiveDatasource.getUser(userId);
    if (model == null) return null;
    return UserMapper.toDomain(model);
  }

  @override
  Future<void> saveUser(User user) async {
    final model = UserMapper.toHive(user);
    await HiveDatasource.saveUser(model);
    await HiveDatasource.setCurrentUserId(user.id);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await HiveDatasource.deleteUser(userId);
    if (HiveDatasource.getCurrentUserId() == userId) {
      await HiveDatasource.setCurrentUserId(null);
    }
  }

  @override
  Stream<User?> watchUser(String userId) {
    // Watch changes to currentUser box (uid) and emit the current user
    return HiveDatasource.watchCurrentUser().asyncMap((_) async {
      return await getCurrentUser();
    });
  }
}
