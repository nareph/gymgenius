import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';

/// Contract for progress persistence and snapshot retrieval.
abstract interface class ProgressRepository {
  Future<ProgressSnapshot?> getLatestSnapshot(String userId);

  Future<ProgressSnapshot?> getSnapshot(
    String userId,
    DateTime computedAt,
  );

  Future<void> saveSnapshot(ProgressSnapshot snapshot);

  Future<List<ProgressSnapshot>> getSnapshotHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  });

  /// Computes (or loads cached) snapshot for the given period.
  Future<ProgressSnapshot> computeSnapshot(
    String userId, {
    ProgressPeriod period = ProgressPeriod.weekly,
    DateTime? now,
  });

  Future<WeeklyProgressReport> computeWeeklyReport(
    String userId, {
    DateTime? weekStart,
  });
}
