import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/engines/decision_engine/models/program_progress.dart';

/// Why a full program refresh should (or should not) run.
enum ProgramRefreshReason {
  none,
  expired,
  lowConsistency,
  plateau,
}

/// Verdict produced by the Decision Engine for replacing the TrainingProgram.
///
/// Independent from today's [WorkoutDecision]: rest/recovery still apply
/// to the session, while this says whether the *block* should be replaced.
/// The Workout Engine only executes regeneration — it does not decide.
class ProgramRefreshDecision {
  final bool shouldRegenerate;
  final ProgramRefreshReason reason;
  final String message;

  const ProgramRefreshDecision({
    required this.shouldRegenerate,
    required this.reason,
    required this.message,
  });

  const ProgramRefreshDecision.none()
      : shouldRegenerate = false,
        reason = ProgramRefreshReason.none,
        message = '';
}

/// Decision Engine policy: should we generate a new TrainingProgram?
///
/// Never an input to *initial* generation. Daily session tweaks stay in
/// [DecisionRule]s / ConflictResolver.
class ProgramRefreshPolicy {
  const ProgramRefreshPolicy._();

  /// Ignore plateau / consistency signals until the program has been
  /// followed long enough for the data to mean something.
  static const Duration minProgramAge = Duration(days: 14);

  /// Completion rate below this (with enough planned sessions) triggers
  /// a full-program refresh so the schedule can match real adherence.
  static const double lowCompletionThreshold = 0.50;

  /// Roughly two weeks at 3 sessions/week.
  static const int minPlannedWorkouts = 6;

  static ProgramRefreshDecision evaluate({
    required TrainingProgram program,
    required ProgramProgress progress,
    ProgressSnapshot? snapshot,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final expired = current.isAfter(program.expiresAt);
    if (expired) {
      return const ProgramRefreshDecision(
        shouldRegenerate: true,
        reason: ProgramRefreshReason.expired,
        message: 'This program has expired. A new block will be generated.',
      );
    }

    final age = current.difference(program.createdAt);
    if (age < minProgramAge || progress.isDeloadWeek) {
      return const ProgramRefreshDecision.none();
    }

    final consistency = snapshot?.consistency;
    if (consistency != null &&
        consistency.plannedWorkouts >= minPlannedWorkouts &&
        consistency.completionRate < lowCompletionThreshold) {
      return ProgramRefreshDecision(
        shouldRegenerate: true,
        reason: ProgramRefreshReason.lowConsistency,
        message:
            'Completion is ${(consistency.completionRate * 100).round()}% '
            'over the lookback window. A simpler program will be generated.',
      );
    }

    if ((snapshot?.anyPlateauDetected ?? false) &&
        (snapshot?.hasSufficientData ?? false)) {
      return const ProgramRefreshDecision(
        shouldRegenerate: true,
        reason: ProgramRefreshReason.plateau,
        message:
            'A plateau was detected with enough data. A fresh program will be generated.',
      );
    }

    return const ProgramRefreshDecision.none();
  }
}
