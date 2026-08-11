import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/engines/decision_engine/models/program_progress.dart';

/// Complete snapshot of everything the Decision Engine knows
/// about the user at the moment a decision is made.
///
/// This is intentionally the single input of every decision rule.
///
/// As GymGenius evolves, new engines will enrich this context
/// without changing the Decision Engine API.
///
/// Future additions:
///
/// • RecoveryStatus
/// • DailyCheckIn
/// • NutritionStatus
/// • ProgressAnalysis
/// • InjuryStatus
/// • Weather
/// • Calendar events
/// • Wearable metrics
/// • Heart Rate Variability
/// • Sleep analysis
/// • Coach preferences
class DecisionContext {
  /// Current timestamp used by every rule.
  final DateTime now;

  /// User health profile.
  final HealthProfile healthProfile;

  /// Current active training program.
  final TrainingProgram trainingProgram;

  /// Current progression inside the training program.
  final ProgramProgress programProgress;

  /// Workout planned for today before adaptations.
  final TodayWorkout todayWorkout;

  /// Recovery status computed from today's check-in (null if no check-in yet).
  final RecoveryStatus? recoveryStatus;

  /// Progress snapshot computed from historical data (null if insufficient data).
  final ProgressSnapshot? progressSnapshot;

  const DecisionContext({
    required this.now,
    required this.healthProfile,
    required this.trainingProgram,
    required this.programProgress,
    required this.todayWorkout,
    this.recoveryStatus,
    this.progressSnapshot,
  });

  DecisionContext copyWith({
    DateTime? now,
    HealthProfile? healthProfile,
    TrainingProgram? trainingProgram,
    ProgramProgress? programProgress,
    TodayWorkout? todayWorkout,
    RecoveryStatus? recoveryStatus,
    ProgressSnapshot? progressSnapshot,
  }) {
    return DecisionContext(
      now: now ?? this.now,
      healthProfile: healthProfile ?? this.healthProfile,
      trainingProgram: trainingProgram ?? this.trainingProgram,
      programProgress: programProgress ?? this.programProgress,
      todayWorkout: todayWorkout ?? this.todayWorkout,
      recoveryStatus: recoveryStatus ?? this.recoveryStatus,
      progressSnapshot: progressSnapshot ?? this.progressSnapshot,
    );
  }

  @override
  String toString() {
    return '''
DecisionContext(
  now: $now,
  currentWeek: ${programProgress.currentWeek},
  phase: ${programProgress.currentPhase},
  completion: ${(programProgress.completion * 100).toStringAsFixed(1)}%,
  plannedExercises: ${todayWorkout.plannedExerciseCount},
  finalExercises: ${todayWorkout.finalExerciseCount},
  adapted: ${todayWorkout.isAdapted}
)
''';
  }
}
