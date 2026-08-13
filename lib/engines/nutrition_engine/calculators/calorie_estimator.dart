import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';

/// Result of daily energy need estimation.
class CalorieEstimate {
  final int bmr;
  final int maintenanceCalories;
  final int targetCalories;
  final int trainingDayBonus;
  final List<String> reasons;

  const CalorieEstimate({
    required this.bmr,
    required this.maintenanceCalories,
    required this.targetCalories,
    required this.trainingDayBonus,
    this.reasons = const [],
  });
}

/// Computes BMR / TDEE / goal-adjusted calorie targets.
///
/// Uses Mifflin-St Jeor for BMR. Deterministic and offline.
class CalorieEstimator {
  const CalorieEstimator();

  CalorieEstimate estimate({
    required HealthProfile profile,
    required bool isTrainingDay,
    double trainingLoad = 1.0,
  }) {
    final bmr = calculateBmr(profile);
    final maintenance = (bmr * _activityMultiplier(profile)).round();
    final goalAdjusted = _applyGoalAdjustment(maintenance, profile.goal);
    final load = trainingLoad.clamp(0.0, 1.0);
    final fullBonus = _trainingBonus(profile);
    final trainingBonus =
        isTrainingDay ? (fullBonus * load).round() : 0;
    final target = goalAdjusted + trainingBonus;

    final reasons = <String>[
      'BMR estimated with Mifflin-St Jeor ($bmr kcal).',
      'Maintenance calories: $maintenance kcal '
          '(activity: ${profile.training.activityLevel.value}).',
      _goalReason(profile.goal, maintenance, goalAdjusted),
      if (isTrainingDay && load >= 0.99)
        'Training day: +$trainingBonus kcal to support workout expenditure.',
      if (isTrainingDay && load < 0.99)
        'Training load ${(load * 100).round()}%: +$trainingBonus kcal '
            '(scaled from +$fullBonus kcal full session).',
      if (!isTrainingDay) 'Rest day: no training calorie bonus.',
    ];

    return CalorieEstimate(
      bmr: bmr,
      maintenanceCalories: maintenance,
      targetCalories: target.clamp(1200, 6000),
      trainingDayBonus: trainingBonus,
      reasons: reasons,
    );
  }

  /// Mifflin-St Jeor BMR.
  int calculateBmr(HealthProfile profile) {
    final weight = profile.currentWeightKg;
    final height = profile.heightCm;
    final age = profile.age;

    // Prefer-not-to-say uses the average of male/female formulas.
    switch (profile.gender) {
      case Gender.male:
        return (10 * weight + 6.25 * height - 5 * age + 5).round();
      case Gender.female:
        return (10 * weight + 6.25 * height - 5 * age - 161).round();
      case Gender.preferNotToSay:
        final male = 10 * weight + 6.25 * height - 5 * age + 5;
        final female = 10 * weight + 6.25 * height - 5 * age - 161;
        return ((male + female) / 2).round();
    }
  }

  double _activityMultiplier(HealthProfile profile) {
    switch (profile.training.activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  int _applyGoalAdjustment(int maintenance, FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.buildMuscle:
        return (maintenance * 1.10).round();
      case FitnessGoal.increaseStrength:
        return (maintenance * 1.05).round();
      case FitnessGoal.loseFat:
        return (maintenance * 0.80).round();
      case FitnessGoal.improveEndurance:
        return (maintenance * 1.00).round();
      case FitnessGoal.generalFitness:
        return maintenance;
    }
  }

  int _trainingBonus(HealthProfile profile) {
    final minutes = profile.sessionDuration.minutes;
    // Roughly 6–8 kcal/min for resistance training; clamp for safety.
    final bonus = (minutes * 7).round();
    return bonus.clamp(150, 500);
  }

  String _goalReason(FitnessGoal goal, int maintenance, int adjusted) {
    final delta = adjusted - maintenance;
    switch (goal) {
      case FitnessGoal.buildMuscle:
        return 'Muscle gain: +$delta kcal surplus (~10%).';
      case FitnessGoal.increaseStrength:
        return 'Strength focus: +$delta kcal mild surplus (~5%).';
      case FitnessGoal.loseFat:
        return 'Fat loss: $delta kcal deficit (~20%).';
      case FitnessGoal.improveEndurance:
        return 'Endurance: calories held near maintenance.';
      case FitnessGoal.generalFitness:
        return 'General fitness: calories set at maintenance.';
    }
  }
}
