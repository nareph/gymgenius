// lib/data/repositories/health_repository_impl.dart

import 'dart:async';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';

import '../../domain/entities/health_profile.dart';
import '../../domain/repositories/health_repository.dart';
import '../mappers/health_mapper.dart';

class HealthRepositoryImpl implements HealthRepository {
  const HealthRepositoryImpl();

  @override
  Future<HealthProfile?> getCurrentProfile() async {
    final userId = HiveDatasource.getCurrentUserId();
    if (userId == null) return null;
    final model = HiveDatasource.getHealthProfile(userId);
    if (model == null) return null;
    return HealthMapper.toDomain(model);
  }

  @override
  Future<HealthProfile?> getHealthProfile(String userId) async {
    final model = HiveDatasource.getHealthProfile(userId);
    if (model == null) return null;
    return HealthMapper.toDomain(model);
  }

  @override
  Future<void> saveHealthProfile(HealthProfile profile) async {
    final model = HealthMapper.toHive(profile);
    await HiveDatasource.saveHealthProfile(model);
  }

  @override
  Future<void> deleteHealthProfile(String userId) async {
    await HiveDatasource.deleteHealthProfile(userId);
  }

  @override
  Stream<HealthProfile?> watchHealthProfile(String userId) {
    return HiveDatasource.watchHealthProfile(userId).map((event) {
      final model = HiveDatasource.getHealthProfile(userId);
      return model != null ? HealthMapper.toDomain(model) : null;
    });
  }
}
