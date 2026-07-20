import 'package:gymgenius/engines/decision_engine/models/health_decision.dart';

/// Orchestrates domain engines to produce a single daily recommendation.
///
/// Sprint 1 skeleton — full cross-engine orchestration arrives in Phase 2.
class DecisionEngine {
  const DecisionEngine();

  /// Placeholder until Recovery, Nutrition, and Progress engines are integrated.
  HealthDecision getDefaultDecision({DateTime? now}) {
    return HealthDecision(
      primaryAction: 'complete_scheduled_workout',
      reason: 'No recovery or nutrition data available yet.',
      confidence: 0.5,
      generatedAt: now ?? DateTime.now(),
    );
  }
}
