import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// Computes daily macronutrient targets from calorie needs and body weight.
class MacroCalculator {
  const MacroCalculator();

  MacroTargets calculate({
    required HealthProfile profile,
    required int targetCalories,
    required bool isTrainingDay,
  }) {
    final weight = profile.currentWeightKg;
    final proteinPerKg = _proteinPerKg(profile.goal);
    final fatPerKg = _fatPerKg(profile.goal);

    var proteinG = (weight * proteinPerKg).round();
    var fatG = (weight * fatPerKg).round();

    // Ensure fat never drops below ~0.6 g/kg for hormonal health.
    fatG = fatG.clamp((weight * 0.6).round(), 200);

    final proteinKcal = proteinG * 4;
    final fatKcal = fatG * 9;
    var remaining = targetCalories - proteinKcal - fatKcal;

    // If remaining carbs would be negative, reduce fat slightly then protein.
    if (remaining < 50 * 4) {
      fatG = (weight * 0.7).round().clamp(30, fatG);
      remaining = targetCalories - (proteinG * 4) - (fatG * 9);
    }
    if (remaining < 0) {
      proteinG = (weight * 1.6).round();
      fatG = (weight * 0.7).round();
      remaining = targetCalories - (proteinG * 4) - (fatG * 9);
    }

    var carbsG = (remaining / 4).round().clamp(50, 800);

    // Training days bias slightly more carbs from fat when surplus available.
    if (isTrainingDay && carbsG < 350) {
      final shift = (fatG * 0.1).round().clamp(0, 15);
      fatG = (fatG - shift).clamp(20, 200);
      carbsG = ((targetCalories - proteinG * 4 - fatG * 9) / 4).round();
    }

    final waterMl = _hydrationMl(weight, isTrainingDay);

    return MacroTargets(
      calories: targetCalories,
      proteinG: proteinG,
      carbsG: carbsG.clamp(50, 800),
      fatG: fatG,
      waterMl: waterMl,
    );
  }

  double _proteinPerKg(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.buildMuscle:
        return 2.0;
      case FitnessGoal.increaseStrength:
        return 1.8;
      case FitnessGoal.loseFat:
        return 2.2;
      case FitnessGoal.improveEndurance:
        return 1.6;
      case FitnessGoal.generalFitness:
        return 1.6;
    }
  }

  double _fatPerKg(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.buildMuscle:
        return 0.9;
      case FitnessGoal.increaseStrength:
        return 0.9;
      case FitnessGoal.loseFat:
        return 0.8;
      case FitnessGoal.improveEndurance:
        return 0.8;
      case FitnessGoal.generalFitness:
        return 0.9;
    }
  }

  int _hydrationMl(double weightKg, bool isTrainingDay) {
    final base = (weightKg * 35).round();
    final bonus = isTrainingDay ? 500 : 0;
    return (base + bonus).clamp(2000, 5000);
  }
}
