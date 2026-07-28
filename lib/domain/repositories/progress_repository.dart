// lib/domain/repositories/progress_repository.dart

import 'package:gymgenius/domain/entities/progress_metrics.dart';

/// Contract for progress persistence operations.
abstract interface class ProgressRepository {
  Future<ProgressMetrics?> getLatestProgressMetrics(String userId);
  Future<void> saveProgressMetrics(ProgressMetrics metrics);
  Future<List<ProgressMetrics>> getProgressHistory(String userId,
      {DateTime? from, DateTime? to});
}
