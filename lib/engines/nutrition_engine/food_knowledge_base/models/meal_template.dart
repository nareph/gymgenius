import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/meal_objective.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// Template meal used by MealPlanner (before portion scaling).
///
/// Previously defined inline in cameroon_dataset.dart — extracted here
/// since it isn't Cameroon-specific; every country dataset uses it.
class MealTemplate {
  final String id;
  final String name;
  final MealObjective objective;
  final List<String> ingredientIds;
  final List<String> ingredientNames;
  final MacroTargets baseMacros;
  final BudgetLevel minBudget;
  final List<String> allergens;
  final List<String> tags;

  const MealTemplate({
    required this.id,
    required this.name,
    required this.objective,
    required this.ingredientIds,
    required this.ingredientNames,
    required this.baseMacros,
    this.minBudget = BudgetLevel.low,
    this.allergens = const [],
    this.tags = const [],
  });
}
