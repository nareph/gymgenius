import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/entities/nutrition_profile.dart';
import 'package:gymgenius/domain/enums/nutrition_status.dart';
import 'package:gymgenius/domain/repositories/nutrition_repository.dart';
import 'package:gymgenius/engines/nutrition_engine/calculators/calorie_estimator.dart';
import 'package:gymgenius/engines/nutrition_engine/calculators/macro_calculator.dart';
import 'package:gymgenius/engines/nutrition_engine/food_knowledge_base/food_knowledge_base.dart';
import 'package:gymgenius/engines/nutrition_engine/planners/meal_planner.dart';
import 'package:gymgenius/engines/nutrition_engine/trackers/adherence_tracker.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Public facade for the Nutrition Engine.
///
/// Deterministic, offline-first. AI must never replace these calculations.
class NutritionEngine {
  final CalorieEstimator _calorieEstimator;
  final MacroCalculator _macroCalculator;
  final MealPlanner _mealPlanner;
  final FoodKnowledgeBase _foodKnowledgeBase;
  final AdherenceTracker _adherenceTracker;
  final NutritionRepository? _nutritionRepository;

  NutritionEngine({
    CalorieEstimator? calorieEstimator,
    MacroCalculator? macroCalculator,
    MealPlanner? mealPlanner,
    FoodKnowledgeBase? foodKnowledgeBase,
    AdherenceTracker? adherenceTracker,
    NutritionRepository? nutritionRepository,
  })  : _calorieEstimator = calorieEstimator ?? const CalorieEstimator(),
        _macroCalculator = macroCalculator ?? const MacroCalculator(),
        _foodKnowledgeBase = foodKnowledgeBase ?? const FoodKnowledgeBase(),
        _mealPlanner = mealPlanner ??
            MealPlanner(
              foodKnowledgeBase: foodKnowledgeBase ?? const FoodKnowledgeBase(),
            ),
        _adherenceTracker = adherenceTracker ?? const AdherenceTracker(),
        _nutritionRepository = nutritionRepository;

  /// Computes today's structured nutrition plan.
  Future<NutritionPlan> computeDailyPlan({
    required HealthProfile profile,
    required bool isTrainingDay,
    DateTime? date,
    bool persist = true,
    double trainingLoad = 1.0,
  }) async {
    final planDate = date ?? DateTime.now();
    final day = DateTime(planDate.year, planDate.month, planDate.day);

    final plan = computeDailyPlanSync(
      profile: profile,
      isTrainingDay: isTrainingDay,
      date: day,
      trainingLoad: trainingLoad,
    );

    if (persist && _nutritionRepository != null) {
      await _nutritionRepository!.savePlan(plan);
      await _nutritionRepository!.saveNutritionProfile(
        NutritionProfile(
          userId: profile.userId,
          date: day,
          targets: plan.targets,
          country: plan.country,
          preferredFoods: profile.lifestyle.foodPreferences,
          restrictedFoods: profile.lifestyle.foodRestrictions,
          adherenceScore: _adherenceTracker.placeholderScore(),
        ),
      );
      Log.debug('NutritionEngine: final plan persisted for ${profile.userId}');
    }

    return plan;
  }

  /// Persists a previously computed plan and its matching profile snapshot.
  ///
  /// This is used when the Decision Engine enriches the base nutrition plan
  /// with cross-domain reasons (rest day, deload, recovery session) and the
  /// final version must be stored, not the intermediate one.
  Future<void> persistPlan({
    required NutritionPlan plan,
    required HealthProfile profile,
  }) async {
    if (_nutritionRepository == null) return;

    await _nutritionRepository!.savePlan(plan);
    await _nutritionRepository!.saveNutritionProfile(
      NutritionProfile(
        userId: profile.userId,
        date: plan.date,
        targets: plan.targets,
        country: plan.country,
        preferredFoods: profile.lifestyle.foodPreferences,
        restrictedFoods: profile.lifestyle.foodRestrictions,
        adherenceScore: _adherenceTracker.placeholderScore(),
      ),
    );
    Log.debug('NutritionEngine: final plan persisted for ${profile.userId}');
  }

  /// Synchronous compute helper for Decision Engine (no I/O).
  NutritionPlan computeDailyPlanSync({
    required HealthProfile profile,
    required bool isTrainingDay,
    DateTime? date,
    double trainingLoad = 1.0,
  }) {
    final planDate = date ?? DateTime.now();
    final day = DateTime(planDate.year, planDate.month, planDate.day);

    final calorieEstimate = _calorieEstimator.estimate(
      profile: profile,
      isTrainingDay: isTrainingDay,
      trainingLoad: trainingLoad,
    );

    final macros = _macroCalculator.calculate(
      profile: profile,
      targetCalories: calorieEstimate.targetCalories,
      isTrainingDay: isTrainingDay,
    );

    final meals = _mealPlanner.plan(
      profile: profile,
      targets: macros,
      isTrainingDay: isTrainingDay,
    );

    final country = _foodKnowledgeBase.resolvedCountry(profile.country);
    final status = _resolveStatus(
      profile: profile,
      isTrainingDay: isTrainingDay,
      target: calorieEstimate.targetCalories,
      maintenance: calorieEstimate.maintenanceCalories,
    );

    final reasons = <String>[
      ...calorieEstimate.reasons,
      'Macros set to P${macros.proteinG}g / C${macros.carbsG}g / F${macros.fatG}g.',
      if (macros.waterMl != null)
        'Hydration target: ${(macros.waterMl! / 1000).toStringAsFixed(1)} L.',
      'Meals selected from $country food knowledge base (${meals.length} meals).',
      'Status: ${status.displayName}.',
    ];

    return NutritionPlan(
      userId: profile.userId,
      date: day,
      targets: macros,
      maintenanceCalories: calorieEstimate.maintenanceCalories.toDouble(),
      status: status,
      meals: meals,
      country: country,
      isTrainingDay: isTrainingDay,
      reasons: reasons,
    );
  }

  NutritionStatus _resolveStatus({
    required HealthProfile profile,
    required bool isTrainingDay,
    required int target,
    required int maintenance,
  }) {
    if (isTrainingDay && target > maintenance) {
      return NutritionStatus.trainingDayBoost;
    }
    if (target < maintenance * 0.95) return NutritionStatus.deficit;
    if (target > maintenance * 1.05) return NutritionStatus.surplus;
    if (!isTrainingDay) return NutritionStatus.recoverySupport;
    return NutritionStatus.onTarget;
  }
}
