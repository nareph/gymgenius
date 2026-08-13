import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/models/health_decision.dart';
import 'package:gymgenius/engines/decision_engine/policies/program_refresh_policy.dart';

import 'decision_context.dart';
import 'program_progress.dart';

/// Complete execution plan produced by the Decision Engine.
///
/// This is the ONLY object that the UI should consume.
///
/// It centralizes everything required for today's experience.
///
/// The UI should never call multiple engines directly.
/// Everything comes from DailyPlan.
class DailyPlan {
  /// Context used to generate today's plan.
  ///
  /// Useful for debugging, analytics and explainability.
  final DecisionContext context;

  /// Current progression inside the Training Program.
  final ProgramProgress programProgress;

  /// Final workout after all adaptations.
  final TodayWorkout todayWorkout;

  /// Resolved workout decision after conflict resolution.
  final WorkoutDecision finalDecision;

  /// Deterministic nutrition recommendation for today.
  final NutritionPlan? nutritionPlan;

  /// Recovery status computed from today's check-in (null if no check-in yet).
  final RecoveryStatus? recoveryStatus;

  /// Progress snapshot for today (null if not computed yet).
  final ProgressSnapshot? progressSnapshot;

  /// Health Platform day snapshot (null if not computed yet).
  final HealthPlatformSnapshot? healthPlatformSnapshot;

  /// Deterministic health recommendation for today.
  final HealthDecision? healthDecision;

  /// Decision Engine verdict on replacing the TrainingProgram.
  /// Independent from [todayWorkout] / [finalDecision].
  final ProgramRefreshDecision? programRefresh;

  /// Confidence of the final decision (0–1).
  final double confidence;

  /// Generation timestamp.
  final DateTime generatedAt;

  const DailyPlan({
    required this.context,
    required this.programProgress,
    required this.todayWorkout,
    required this.finalDecision,
    this.nutritionPlan,
    this.recoveryStatus,
    this.progressSnapshot,
    this.healthPlatformSnapshot,
    this.healthDecision,
    this.programRefresh,
    required this.confidence,
    required this.generatedAt,
  });

  bool get hasWorkout => todayWorkout.hasExercises;

  bool get isRestDay => todayWorkout.isRestDay;

  bool get isAdapted => todayWorkout.isAdapted;

  bool get hasNutrition => nutritionPlan != null;

  bool get hasRecovery => recoveryStatus != null;

  bool get hasProgress => progressSnapshot != null;

  bool get hasHealthPlatform => healthPlatformSnapshot != null;

  bool get hasHealthDecision => healthDecision != null;

  bool get shouldRefreshProgram =>
      programRefresh?.shouldRegenerate ?? false;

  @override
  String toString() {
    return '''
DailyPlan(
  date: ${context.now},
  adapted: $isAdapted,
  restDay: $isRestDay,
  nutrition: $hasNutrition,
  recovery: $hasRecovery,
  progress: $hasProgress,
  health: $hasHealthDecision,
  confidence: $confidence
)
''';
  }
}
