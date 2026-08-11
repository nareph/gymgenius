import 'package:hive/hive.dart';

part 'progress_snapshot_hive_model.g.dart';

@HiveType(typeId: 15)
class ProgressSnapshotHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime computedAt;

  /// Stored as [ProgressPeriod.value].
  @HiveField(2)
  String period;

  @HiveField(3)
  double? currentWeightKg;

  @HiveField(4)
  double? weeklyAverageWeightKg;

  @HiveField(5)
  double? weightChangeKg;

  @HiveField(6)
  String? weightDirection;

  @HiveField(7)
  double? distanceToTargetKg;

  @HiveField(8)
  int weightDataPointCount;

  @HiveField(9)
  int trackedExerciseCount;

  @HiveField(10)
  String? strengthOverallTrend;

  @HiveField(11)
  double strengthChangePercent;

  @HiveField(12)
  bool strengthPlateauDetected;

  @HiveField(13)
  int plannedWorkouts;

  @HiveField(14)
  int completedWorkouts;

  @HiveField(15)
  int consistencyScore;

  @HiveField(16)
  double weeklyFrequency;

  @HiveField(17)
  int consecutiveTrainingDays;

  @HiveField(18)
  String? consistencyTrend;

  @HiveField(19)
  bool weightPlateauDetected;

  @HiveField(20)
  List<String> reasons;

  @HiveField(21)
  String generatedBy;

  /// JSON-encoded list of top exercise metrics.
  @HiveField(22)
  String? topExercisesJson;

  ProgressSnapshotHiveModel({
    required this.userId,
    required this.computedAt,
    required this.period,
    this.currentWeightKg,
    this.weeklyAverageWeightKg,
    this.weightChangeKg,
    this.weightDirection,
    this.distanceToTargetKg,
    this.weightDataPointCount = 0,
    this.trackedExerciseCount = 0,
    this.strengthOverallTrend,
    this.strengthChangePercent = 0,
    this.strengthPlateauDetected = false,
    this.plannedWorkouts = 0,
    this.completedWorkouts = 0,
    this.consistencyScore = 0,
    this.weeklyFrequency = 0,
    this.consecutiveTrainingDays = 0,
    this.consistencyTrend,
    this.weightPlateauDetected = false,
    this.reasons = const [],
    this.generatedBy = 'progress_engine_v1',
    this.topExercisesJson,
  });
}
