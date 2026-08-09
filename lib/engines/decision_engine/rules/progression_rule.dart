import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/program_phase.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Applies the progression strategy of the current program.
///
/// This rule is responsible for decisions driven solely by the
/// planned progression of the training program.
///
/// It does NOT consider:
///
/// • recovery
/// • fatigue
/// • injuries
/// • nutrition
/// • equipment
///
/// Those concerns belong to their dedicated rules.
class ProgressionRule implements DecisionRule {
  const ProgressionRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    final progression = context.programProgress.weekProgression;

    // ============================================================
    // Realization phase
    //
    // Reduce volume while maintaining high intensity.
    // ============================================================

    if (progression.phase == ProgramPhase.realization) {
      return WorkoutDecision(
        requiresAdaptation: true,
        adjustment: WorkoutAdjustment.reduceVolume,
        reasons: const [
          DecisionReason.realizationPhase,
        ],
        confidence: 0.90,
      );
    }

    // ============================================================
    // Intensification phase
    //
    // Increase training intensity.
    // ============================================================

    if (progression.intensityMultiplier > 1.0) {
      return WorkoutDecision(
        requiresAdaptation: true,
        adjustment: WorkoutAdjustment.increaseIntensity,
        reasons: const [
          DecisionReason.progressionWeek,
        ],
        confidence: 0.90,
      );
    }

    // ============================================================
    // Base phase
    // ============================================================

    return WorkoutDecision.keepPlannedWorkout();
  }
}
