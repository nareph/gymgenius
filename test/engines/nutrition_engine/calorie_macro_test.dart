import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/engines/nutrition_engine/calculators/calorie_estimator.dart';
import 'package:gymgenius/engines/nutrition_engine/calculators/macro_calculator.dart';

HealthProfile buildTestProfile({
  FitnessGoal goal = FitnessGoal.buildMuscle,
  Gender gender = Gender.male,
  double weightKg = 75,
  double heightCm = 175,
  int age = 28,
  ActivityLevel activity = ActivityLevel.moderatelyActive,
  SessionDuration duration = SessionDuration.standard60,
  String country = 'Cameroon',
  List<String> restrictions = const [],
  BudgetLevel budget = BudgetLevel.medium,
}) {
  final now = DateTime(2026, 8, 11);
  return HealthProfile(
    userId: 'user-1',
    body: BodyMeasurements(
      age: age,
      heightCm: heightCm,
      currentWeightKg: weightKg,
      gender: gender,
    ),
    training: WorkoutPreferences(
      goal: goal,
      experience: ExperienceLevel.intermediate,
      activityLevel: activity,
      frequency: WorkoutFrequency.threeToFour,
      sessionDuration: duration,
      preferredDays: const [
        WorkoutDay.monday,
        WorkoutDay.tuesday,
        WorkoutDay.thursday,
        WorkoutDay.friday,
      ],
      equipment: const [EquipmentType.dumbbells],
      focusAreas: const [],
    ),
    lifestyle: LifestylePreferences(
      country: country,
      budget: budget,
      foodRestrictions: restrictions,
    ),
    createdAt: now,
    updatedAt: now,
    answeredQuestionIds: HealthProfile.requiredFieldIds,
  );
}

void main() {
  group('CalorieEstimator', () {
    const estimator = CalorieEstimator();

    test('calculates Mifflin-St Jeor BMR for male', () {
      final profile = buildTestProfile();
      // 10*75 + 6.25*175 - 5*28 + 5 = 750 + 1093.75 - 140 + 5 = 1708.75
      expect(estimator.calculateBmr(profile), 1709);
    });

    test('calculates Mifflin-St Jeor BMR for female', () {
      final profile = buildTestProfile(gender: Gender.female);
      // 10*75 + 6.25*175 - 5*28 - 161 = 1542.75
      expect(estimator.calculateBmr(profile), 1543);
    });

    test('buildMuscle applies surplus and training bonus', () {
      final profile = buildTestProfile(goal: FitnessGoal.buildMuscle);
      final estimate = estimator.estimate(profile: profile, isTrainingDay: true);

      expect(estimate.maintenanceCalories, greaterThan(estimate.bmr));
      expect(estimate.targetCalories, greaterThan(estimate.maintenanceCalories));
      expect(estimate.trainingDayBonus, greaterThan(0));
      expect(estimate.reasons, isNotEmpty);
    });

    test('loseFat applies deficit', () {
      final profile = buildTestProfile(goal: FitnessGoal.loseFat);
      final estimate =
          estimator.estimate(profile: profile, isTrainingDay: false);

      expect(estimate.targetCalories, lessThan(estimate.maintenanceCalories));
      expect(estimate.trainingDayBonus, 0);
    });

    test('rest day has no training bonus', () {
      final profile = buildTestProfile();
      final training =
          estimator.estimate(profile: profile, isTrainingDay: true);
      final rest = estimator.estimate(profile: profile, isTrainingDay: false);

      expect(training.targetCalories, greaterThan(rest.targetCalories));
      expect(rest.trainingDayBonus, 0);
    });
  });

  group('MacroCalculator', () {
    const calculator = MacroCalculator();

    test('protein is higher for loseFat than generalFitness', () {
      final cut = buildTestProfile(goal: FitnessGoal.loseFat);
      final general = buildTestProfile(goal: FitnessGoal.generalFitness);

      final cutMacros = calculator.calculate(
        profile: cut,
        targetCalories: 2200,
        isTrainingDay: false,
      );
      final generalMacros = calculator.calculate(
        profile: general,
        targetCalories: 2200,
        isTrainingDay: false,
      );

      expect(cutMacros.proteinG, greaterThan(generalMacros.proteinG));
    });

    test('macros roughly sum to target calories', () {
      final profile = buildTestProfile();
      const target = 2800;
      final macros = calculator.calculate(
        profile: profile,
        targetCalories: target,
        isTrainingDay: true,
      );

      final reconstructed =
          macros.proteinG * 4 + macros.carbsG * 4 + macros.fatG * 9;
      expect((reconstructed - target).abs(), lessThanOrEqualTo(50));
      expect(macros.waterMl, isNotNull);
      expect(macros.waterMl!, greaterThanOrEqualTo(2000));
    });

    test('buildMuscle uses ~2.0 g/kg protein', () {
      final profile = buildTestProfile(weightKg: 80, goal: FitnessGoal.buildMuscle);
      final macros = calculator.calculate(
        profile: profile,
        targetCalories: 3000,
        isTrainingDay: true,
      );
      expect(macros.proteinG, closeTo(160, 5));
    });
  });
}
