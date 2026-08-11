import 'package:gymgenius/domain/enums/workout_adjustment.dart';

/// Compact, LLM-safe snapshot of today's decision context.
///
/// Built from [DailyPlan] — never from raw Hive access in the LLM layer.
class CoachContext {
  final String userId;
  final DateTime now;

  final String? goal;
  final String? experience;

  final bool isRestDay;
  final bool isAdapted;
  final String workoutAdjustment;
  final List<String> decisionReasons;
  final int plannedExerciseCount;

  final int? readinessScore;
  final int? recoveryScore;
  final double? volumeMultiplier;

  final int? nutritionCalories;
  final int? nutritionProteinG;
  final String? nutritionStatus;

  final int? consistencyScore;
  final bool weightPlateau;
  final bool strengthPlateau;
  final List<String> progressReasons;

  final String? healthPrimaryAction;
  final String? healthReason;

  final double decisionConfidence;

  const CoachContext({
    required this.userId,
    required this.now,
    this.goal,
    this.experience,
    required this.isRestDay,
    required this.isAdapted,
    required this.workoutAdjustment,
    required this.decisionReasons,
    required this.plannedExerciseCount,
    this.readinessScore,
    this.recoveryScore,
    this.volumeMultiplier,
    this.nutritionCalories,
    this.nutritionProteinG,
    this.nutritionStatus,
    this.consistencyScore,
    this.weightPlateau = false,
    this.strengthPlateau = false,
    this.progressReasons = const [],
    this.healthPrimaryAction,
    this.healthReason,
    required this.decisionConfidence,
  });

  bool get volumeWasReduced =>
      workoutAdjustment == WorkoutAdjustment.reduceVolume.value ||
      workoutAdjustment == WorkoutAdjustment.deload.value ||
      workoutAdjustment == WorkoutAdjustment.reduceIntensity.value ||
      (volumeMultiplier != null && volumeMultiplier! < 1.0);

  Map<String, dynamic> toPromptMap() {
    return {
      'userId': userId,
      'date': now.toIso8601String(),
      'goal': goal,
      'experience': experience,
      'isRestDay': isRestDay,
      'isAdapted': isAdapted,
      'workoutAdjustment': workoutAdjustment,
      'decisionReasons': decisionReasons,
      'plannedExerciseCount': plannedExerciseCount,
      'readinessScore': readinessScore,
      'recoveryScore': recoveryScore,
      'volumeMultiplier': volumeMultiplier,
      'nutritionCalories': nutritionCalories,
      'nutritionProteinG': nutritionProteinG,
      'nutritionStatus': nutritionStatus,
      'consistencyScore': consistencyScore,
      'weightPlateau': weightPlateau,
      'strengthPlateau': strengthPlateau,
      'progressReasons': progressReasons,
      'healthPrimaryAction': healthPrimaryAction,
      'healthReason': healthReason,
      'decisionConfidence': decisionConfidence,
    };
  }
}
