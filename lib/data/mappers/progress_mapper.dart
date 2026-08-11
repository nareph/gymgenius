import 'dart:convert';

import 'package:gymgenius/data/datasources/local/hive/models/progress_snapshot_hive_model.dart';
import 'package:gymgenius/domain/entities/exercise_strength_metric.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/strength_progress.dart';
import 'package:gymgenius/domain/entities/weight_trend.dart';
import 'package:gymgenius/domain/entities/workout_consistency.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';

class ProgressMapper {
  const ProgressMapper._();

  static ProgressSnapshot toDomain(ProgressSnapshotHiveModel model) {
    final weightTrend =
        model.weightDataPointCount > 0 || model.currentWeightKg != null
            ? WeightTrend(
                currentWeightKg: model.currentWeightKg,
                weeklyAverageKg: model.weeklyAverageWeightKg,
                changeKg: model.weightChangeKg,
                direction: model.weightDirection != null
                    ? TrendDirectionExtension.fromValue(model.weightDirection!)
                    : TrendDirection.insufficientData,
                distanceToTargetKg: model.distanceToTargetKg,
                dataPointCount: model.weightDataPointCount,
              )
            : null;

    final topExercises = _decodeExercises(model.topExercisesJson);

    final strengthProgress = model.trackedExerciseCount > 0
        ? StrengthProgress(
            trackedExerciseCount: model.trackedExerciseCount,
            topExercises: topExercises,
            overallTrend: model.strengthOverallTrend != null
                ? TrendDirectionExtension.fromValue(model.strengthOverallTrend!)
                : TrendDirection.insufficientData,
            strengthChangePercent: model.strengthChangePercent,
            plateauDetected: model.strengthPlateauDetected,
          )
        : null;

    final consistency = model.plannedWorkouts > 0
        ? WorkoutConsistency(
            plannedWorkouts: model.plannedWorkouts,
            completedWorkouts: model.completedWorkouts,
            consistencyScore: model.consistencyScore,
            weeklyFrequency: model.weeklyFrequency,
            consecutiveTrainingDays: model.consecutiveTrainingDays,
            trend: model.consistencyTrend != null
                ? TrendDirectionExtension.fromValue(model.consistencyTrend!)
                : TrendDirection.insufficientData,
          )
        : null;

    return ProgressSnapshot(
      userId: model.userId,
      computedAt: model.computedAt,
      period: ProgressPeriodExtension.fromValue(model.period),
      weightTrend: weightTrend,
      strengthProgress: strengthProgress,
      consistency: consistency,
      weightPlateauDetected: model.weightPlateauDetected,
      strengthPlateauDetected: model.strengthPlateauDetected,
      reasons: List<String>.from(model.reasons),
      generatedBy: model.generatedBy,
    );
  }

  static ProgressSnapshotHiveModel toHive(ProgressSnapshot entity) {
    final weight = entity.weightTrend;
    final strength = entity.strengthProgress;
    final consistency = entity.consistency;

    return ProgressSnapshotHiveModel(
      userId: entity.userId,
      computedAt: entity.computedAt,
      period: entity.period.value,
      currentWeightKg: weight?.currentWeightKg,
      weeklyAverageWeightKg: weight?.weeklyAverageKg,
      weightChangeKg: weight?.changeKg,
      weightDirection: weight?.direction.value,
      distanceToTargetKg: weight?.distanceToTargetKg,
      weightDataPointCount: weight?.dataPointCount ?? 0,
      trackedExerciseCount: strength?.trackedExerciseCount ?? 0,
      strengthOverallTrend: strength?.overallTrend.value,
      strengthChangePercent: strength?.strengthChangePercent ?? 0,
      plannedWorkouts: consistency?.plannedWorkouts ?? 0,
      completedWorkouts: consistency?.completedWorkouts ?? 0,
      consistencyScore: consistency?.consistencyScore ?? 0,
      weeklyFrequency: consistency?.weeklyFrequency ?? 0,
      consecutiveTrainingDays: consistency?.consecutiveTrainingDays ?? 0,
      consistencyTrend: consistency?.trend.value,
      weightPlateauDetected: entity.weightPlateauDetected,
      strengthPlateauDetected: entity.strengthPlateauDetected,
      reasons: List<String>.from(entity.reasons),
      generatedBy: entity.generatedBy,
      topExercisesJson: strength != null
          ? jsonEncode(
              strength.topExercises
                  .map(
                    (e) => {
                      'exerciseId': e.exerciseId,
                      'exerciseName': e.exerciseName,
                      'bestWeightKg': e.bestWeightKg,
                      'bestReps': e.bestReps,
                      'estimated1Rm': e.estimated1Rm,
                      'trend': e.trend.value,
                      'plateauDetected': e.plateauDetected,
                    },
                  )
                  .toList(),
            )
          : null,
    );
  }

  static List<ExerciseStrengthMetric> _decodeExercises(String? json) {
    if (json == null || json.isEmpty) return const [];

    final list = jsonDecode(json) as List<dynamic>;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return ExerciseStrengthMetric(
        exerciseId: map['exerciseId'] as String,
        exerciseName: map['exerciseName'] as String,
        bestWeightKg: (map['bestWeightKg'] as num).toDouble(),
        bestReps: map['bestReps'] as int,
        estimated1Rm: (map['estimated1Rm'] as num).toDouble(),
        trend: TrendDirectionExtension.fromValue(map['trend'] as String),
        plateauDetected: map['plateauDetected'] as bool? ?? false,
      );
    }).toList();
  }
}
