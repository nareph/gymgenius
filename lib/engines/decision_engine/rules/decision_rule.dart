import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';

/// Base contract implemented by every Decision Engine rule.
///
/// Each rule analyzes the current [DecisionContext] independently
/// and proposes a [WorkoutDecision].
///
/// The Decision Engine later combines every proposal using the
/// ConflictResolver to produce the final decision.
abstract class DecisionRule {
  const DecisionRule();

  WorkoutDecision evaluate(
    DecisionContext context,
  );
}
