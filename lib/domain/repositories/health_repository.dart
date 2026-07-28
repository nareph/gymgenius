// lib/domain/repositories/health_repository.dart

import 'package:gymgenius/domain/entities/health_profile.dart';

/// Contract for health profile persistence operations.
abstract interface class HealthRepository {
  Future<HealthProfile?> getCurrentProfile();
  Future<HealthProfile?> getHealthProfile(String userId);
  Future<void> saveHealthProfile(HealthProfile profile);
  Future<void> deleteHealthProfile(String userId);
  Stream<HealthProfile?> watchHealthProfile(String userId);
}
