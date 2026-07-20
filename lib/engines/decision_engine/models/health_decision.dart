/// A single daily health recommendation produced by the Decision Engine.
class HealthDecision {
  final String primaryAction;
  final String reason;
  final double confidence;
  final DateTime generatedAt;

  const HealthDecision({
    required this.primaryAction,
    required this.reason,
    required this.confidence,
    required this.generatedAt,
  });
}
