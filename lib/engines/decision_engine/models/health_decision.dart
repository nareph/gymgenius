import 'package:gymgenius/domain/enums/decision_reason.dart';

/// A single daily health recommendation produced by the Decision Engine.
class HealthDecision {
  final String primaryAction;
  final String reason;
  final double confidence;
  final DateTime generatedAt;
  final List<DecisionReason> reasons;

  const HealthDecision({
    required this.primaryAction,
    required this.reason,
    required this.confidence,
    required this.generatedAt,
    this.reasons = const [],
  });

  String get displayAction {
    switch (primaryAction) {
      case 'rest_and_recover':
        return 'Rest and recover';
      case 'recovery_session':
        return 'Recovery session';
      case 'train_with_reduced_volume':
        return 'Train with reduced volume';
      case 'monitor_plateau':
        return 'Monitor plateau';
      case 'follow_adapted_workout':
        return 'Follow adapted workout';
      case 'complete_scheduled_workout':
      default:
        return 'Complete scheduled workout';
    }
  }
}
