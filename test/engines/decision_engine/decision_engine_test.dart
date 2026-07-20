import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecisionEngine', () {
    test('returns default decision when no domain data available', () {
      const engine = DecisionEngine();
      final decision = engine.getDefaultDecision(
        now: DateTime(2026, 7, 16),
      );

      expect(decision.primaryAction, 'complete_scheduled_workout');
      expect(decision.confidence, 0.5);
      expect(decision.generatedAt, DateTime(2026, 7, 16));
    });
  });
}
