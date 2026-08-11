import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';

import 'decision_context.dart';
import 'program_progress.dart';

/// Complete execution plan produced by the Decision Engine.
///
/// This is the ONLY object that the UI should consume.
///
/// It centralizes everything required for today's experience.
///
/// Future versions will progressively include:
///
/// • RecoveryPlan
/// • HydrationPlan
/// • DailyAdvice
/// • Notifications
/// • Smart reminders
/// • AI explanations
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

  /// Deterministic nutrition recommendation for today.
  final NutritionPlan? nutritionPlan;

  /// Confidence of the final decision.
  final double confidence;

  /// Generation timestamp.
  final DateTime generatedAt;

  const DailyPlan({
    required this.context,
    required this.programProgress,
    required this.todayWorkout,
    this.nutritionPlan,
    required this.confidence,
    required this.generatedAt,
  });

  bool get hasWorkout => todayWorkout.hasExercises;

  bool get isRestDay => todayWorkout.isRestDay;

  bool get isAdapted => todayWorkout.isAdapted;

  bool get hasNutrition => nutritionPlan != null;

  @override
  String toString() {
    return '''
DailyPlan(
  date: ${context.now},
  adapted: $isAdapted,
  restDay: $isRestDay,
  nutrition: $hasNutrition,
  confidence: $confidence
)
''';
  }
}
