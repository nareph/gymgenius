// test/engines/decision_engine/decision_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
import 'package:gymgenius/engines/decision_engine/builders/today_workout_builder.dart';
import 'package:gymgenius/engines/decision_engine/rules/decision_rule.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';
import 'package:gymgenius/engines/decision_engine/services/deload_service.dart';
import 'package:gymgenius/engines/decision_engine/services/exercise_substitution_service.dart';
import 'package:gymgenius/engines/decision_engine/services/intensity_adjustment_service.dart';
import 'package:gymgenius/engines/decision_engine/services/recovery_session_service.dart';
import 'package:gymgenius/engines/decision_engine/services/volume_adjustment_service.dart';
import 'package:gymgenius/engines/decision_engine/services/workout_adaptation_service.dart';
import 'package:gymgenius/engines/workout_engine/providers/exercise_replacement_provider.dart';

void main() {
  group('DecisionEngine', () {
    late DecisionEngine engine;

    setUp(() {
      final replacementProvider = const ExerciseReplacementProvider();

      engine = DecisionEngine(
        programProgressService: const ProgramProgressService(),
        todayWorkoutBuilder: const TodayWorkoutBuilder(),
        workoutAdaptationService: WorkoutAdaptationService(
          volumeAdjustmentService: const VolumeAdjustmentService(),
          intensityAdjustmentService: const IntensityAdjustmentService(),
          exerciseSubstitutionService: ExerciseSubstitutionService(
            replacementProvider: replacementProvider,
          ),
          recoverySessionService: const RecoverySessionService(),
          deloadService: const DeloadService(),
        ),
        conflictResolver: const ConflictResolver(),
        rules: const <DecisionRule>[],
      );
    });

    test('returns default decision when no domain data available', () {
      final decision = engine.getDefaultDecision(
        now: DateTime(2026, 7, 16),
      );

      expect(decision.primaryAction, 'complete_scheduled_workout');
      expect(decision.reason, 'No recovery or nutrition data available yet.');
      expect(decision.confidence, 0.5);
      expect(decision.generatedAt, DateTime(2026, 7, 16));
    });
  });
}
