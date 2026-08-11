import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/meal.dart';
import 'package:gymgenius/domain/enums/meal_objective.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import 'package:gymgenius/engines/nutrition_engine/food_knowledge_base/cameroon_dataset.dart';
import 'package:gymgenius/engines/nutrition_engine/food_knowledge_base/food_knowledge_base.dart';

/// Builds a daily meal structure from macro targets and local foods.
class MealPlanner {
  final FoodKnowledgeBase _foodKnowledgeBase;

  const MealPlanner({
    FoodKnowledgeBase foodKnowledgeBase = const FoodKnowledgeBase(),
  }) : _foodKnowledgeBase = foodKnowledgeBase;

  List<Meal> plan({
    required HealthProfile profile,
    required MacroTargets targets,
    required bool isTrainingDay,
  }) {
    final slots = _mealSlots(
      isTrainingDay: isTrainingDay,
      trainingHour: profile.lifestyle.trainingTime,
    );

    final templates = _foodKnowledgeBase.filterTemplates(
      country: profile.country,
      budget: profile.lifestyle.budget,
      restrictions: profile.lifestyle.foodRestrictions,
      preferredFoods: profile.lifestyle.foodPreferences,
    );

    if (templates.isEmpty) {
      return _fallbackMeals(targets, slots);
    }

    final meals = <Meal>[];
    final calorieShares = _calorieShares(slots.length, isTrainingDay);
    var usedIds = <String>{};

    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final share = calorieShares[i];
      final slotCalories = (targets.calories * share).round();

      final template = _pickTemplate(
        templates: templates,
        slot: slot,
        isTrainingDay: isTrainingDay,
        usedIds: usedIds,
      );
      usedIds.add(template.id);

      final scaled = _scaleMacros(template.baseMacros, slotCalories);
      meals.add(
        Meal(
          id: '${template.id}_${slot.value}',
          name: template.name,
          type: slot,
          objective: template.objective,
          ingredients: List<String>.from(template.ingredientNames),
          macros: scaled,
          timingNote: _timingNote(slot, profile.lifestyle.trainingTime),
          reason: _mealReason(slot, template.objective, isTrainingDay),
        ),
      );
    }

    return meals;
  }

  List<MealType> _mealSlots({
    required bool isTrainingDay,
    int? trainingHour,
  }) {
    if (!isTrainingDay) {
      return const [
        MealType.breakfast,
        MealType.lunch,
        MealType.snack,
        MealType.dinner,
      ];
    }

    final hour = trainingHour ?? 17;
    if (hour <= 10) {
      return const [
        MealType.preWorkout,
        MealType.postWorkout,
        MealType.lunch,
        MealType.snack,
        MealType.dinner,
      ];
    }
    if (hour >= 18) {
      return const [
        MealType.breakfast,
        MealType.lunch,
        MealType.snack,
        MealType.preWorkout,
        MealType.postWorkout,
      ];
    }
    return const [
      MealType.breakfast,
      MealType.lunch,
      MealType.preWorkout,
      MealType.postWorkout,
      MealType.dinner,
    ];
  }

  List<double> _calorieShares(int count, bool isTrainingDay) {
    switch (count) {
      case 3:
        return const [0.30, 0.40, 0.30];
      case 4:
        return isTrainingDay
            ? const [0.25, 0.30, 0.15, 0.30]
            : const [0.25, 0.35, 0.10, 0.30];
      case 5:
        return const [0.20, 0.25, 0.15, 0.20, 0.20];
      default:
        return List.filled(count, 1 / count);
    }
  }

  MealTemplate _pickTemplate({
    required List<MealTemplate> templates,
    required MealType slot,
    required bool isTrainingDay,
    required Set<String> usedIds,
  }) {
    final objective = _objectiveForSlot(slot, isTrainingDay);
    final preferred = templates.where((t) {
      if (usedIds.contains(t.id)) return false;
      if (t.objective == objective) return true;
      if (slot == MealType.breakfast && t.tags.contains('breakfast')) {
        return true;
      }
      if (slot == MealType.snack && t.objective == MealObjective.light) {
        return true;
      }
      return false;
    }).toList();

    final pool = preferred.isNotEmpty
        ? preferred
        : templates.where((t) => !usedIds.contains(t.id)).toList();

    if (pool.isEmpty) return templates.first;

    // Deterministic selection based on slot hash.
    final index = (slot.index + usedIds.length) % pool.length;
    return pool[index];
  }

  MealObjective _objectiveForSlot(MealType slot, bool isTrainingDay) {
    switch (slot) {
      case MealType.breakfast:
        return MealObjective.highProtein;
      case MealType.lunch:
        return isTrainingDay
            ? MealObjective.highEnergy
            : MealObjective.highProtein;
      case MealType.snack:
        return MealObjective.light;
      case MealType.preWorkout:
        return MealObjective.highEnergy;
      case MealType.postWorkout:
        return MealObjective.recovery;
      case MealType.dinner:
        return isTrainingDay
            ? MealObjective.recovery
            : MealObjective.light;
    }
  }

  MacroTargets _scaleMacros(MacroTargets base, int targetCalories) {
    if (base.calories <= 0) {
      return MacroTargets(
        calories: targetCalories,
        proteinG: (targetCalories * 0.3 / 4).round(),
        carbsG: (targetCalories * 0.4 / 4).round(),
        fatG: (targetCalories * 0.3 / 9).round(),
      );
    }
    final factor = targetCalories / base.calories;
    return MacroTargets(
      calories: targetCalories,
      proteinG: (base.proteinG * factor).round().clamp(5, 200),
      carbsG: (base.carbsG * factor).round().clamp(5, 300),
      fatG: (base.fatG * factor).round().clamp(2, 120),
    );
  }

  String? _timingNote(MealType slot, int? trainingHour) {
    switch (slot) {
      case MealType.preWorkout:
        return trainingHour == null
            ? 'Eat 60–90 minutes before training'
            : 'Around ${(trainingHour - 1).clamp(5, 22)}:00 before training';
      case MealType.postWorkout:
        return 'Within 60 minutes after training';
      case MealType.breakfast:
        return 'Morning meal';
      case MealType.lunch:
        return 'Midday meal';
      case MealType.dinner:
        return 'Evening meal';
      case MealType.snack:
        return 'Between meals';
    }
  }

  String _mealReason(
    MealType slot,
    MealObjective objective,
    bool isTrainingDay,
  ) {
    final day = isTrainingDay ? 'training day' : 'rest day';
    return '${slot.displayName} supports $day needs '
        '(${objective.displayName.toLowerCase()}).';
  }

  List<Meal> _fallbackMeals(MacroTargets targets, List<MealType> slots) {
    final shares = _calorieShares(slots.length, false);
    return [
      for (var i = 0; i < slots.length; i++)
        Meal(
          id: 'fallback_${slots[i].value}',
          name: 'Balanced local meal',
          type: slots[i],
          objective: MealObjective.highEnergy,
          ingredients: const ['Rice', 'Beans', 'Vegetables'],
          macros: MacroTargets(
            calories: (targets.calories * shares[i]).round(),
            proteinG: (targets.proteinG * shares[i]).round(),
            carbsG: (targets.carbsG * shares[i]).round(),
            fatG: (targets.fatG * shares[i]).round(),
          ),
          reason: 'Fallback meal — no matching local templates after filters.',
        ),
    ];
  }
}
