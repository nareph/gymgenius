import 'package:gymgenius/domain/entities/nutrition_log.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/enums/nutrition_log_source.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import 'package:gymgenius/engines/nutrition_engine/trackers/adherence_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

NutritionLog _log(int calories) => NutritionLog(
      id: 'log_$calories',
      userId: 'user1',
      name: 'Meal',
      source: NutritionLogSource.manual,
      mealType: MealType.lunch,
      macros: MacroTargets(
        calories: calories,
        proteinG: 20,
        carbsG: 30,
        fatG: 10,
      ),
      loggedAt: DateTime(2026, 8, 17, 12),
    );

void main() {
  const tracker = AdherenceTracker();

  group('AdherenceTracker', () {
    test('perfect adherence within 90-110%', () {
      expect(
        tracker.scoreFromCalories(
          targetCalories: 2000,
          loggedCalories: 2000,
        ),
        1.0,
      );
      expect(
        tracker.scoreFromCalories(
          targetCalories: 2000,
          loggedCalories: 1900,
        ),
        1.0,
      );
    });

    test('scoreFromLogs returns 0 when nothing logged', () {
      expect(
        tracker.scoreFromLogs(targetCalories: 2000, logs: const []),
        0,
      );
    });

    test('scoreFromLogs uses summed calories', () {
      final score = tracker.scoreFromLogs(
        targetCalories: 2000,
        logs: [_log(900), _log(1000)],
      );
      expect(score, 1.0);
    });

    test('loggedTotals sums macros across logs', () {
      final totals = tracker.loggedTotals([_log(500), _log(700)]);
      expect(totals.calories, 1200);
      expect(totals.proteinG, 40);
    });
  });
}
