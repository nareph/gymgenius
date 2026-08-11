import 'package:gymgenius/domain/enums/meal_objective.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// A suggested meal in a daily nutrition plan.
class Meal {
  final String id;
  final String name;
  final MealType type;
  final MealObjective objective;
  final List<String> ingredients;
  final MacroTargets macros;
  final String? timingNote;
  final String? reason;

  const Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.objective,
    required this.ingredients,
    required this.macros,
    this.timingNote,
    this.reason,
  });

  @override
  String toString() => 'Meal($name, ${type.value}, ${macros.calories} kcal)';
}
