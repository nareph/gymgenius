import 'package:gymgenius/domain/entities/nutrition_log.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import 'package:gymgenius/engines/nutrition_engine/builders/meal_log_builder.dart';

/// Tracks nutritional adherence from logged meals vs daily targets.
class AdherenceTracker {
  final MealLogBuilder _logBuilder;

  const AdherenceTracker({
    MealLogBuilder logBuilder = const MealLogBuilder(),
  }) : _logBuilder = logBuilder;

  /// Estimates adherence from logged vs target calories when available.
  double scoreFromCalories({
    required int targetCalories,
    required int loggedCalories,
  }) {
    if (targetCalories <= 0) return 0;
    final ratio = loggedCalories / targetCalories;
    if (ratio >= 0.9 && ratio <= 1.1) return 1.0;
    if (ratio >= 0.8 && ratio <= 1.2) return 0.7;
    if (ratio >= 0.7 && ratio <= 1.3) return 0.4;
    return 0.2;
  }

  /// Computes adherence from a day's nutrition logs.
  double scoreFromLogs({
    required int targetCalories,
    required List<NutritionLog> logs,
  }) {
    if (logs.isEmpty) return 0;
    final logged = _logBuilder.sumLoggedMacros(logs).calories;
    return scoreFromCalories(
      targetCalories: targetCalories,
      loggedCalories: logged,
    );
  }

  /// Total macros logged for a day.
  MacroTargets loggedTotals(List<NutritionLog> logs) =>
      _logBuilder.sumLoggedMacros(logs);
}
