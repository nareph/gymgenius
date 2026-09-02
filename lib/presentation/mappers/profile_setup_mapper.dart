import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/presentation/mappers/profile_completeness.dart';

import '../../domain/enums/exports.dart';

class ProfileSetupMapper {
  const ProfileSetupMapper._();

  static HealthProfile toDomain(Map<String, dynamic> answers) {
    // --- Physical stats ---
    final stats = answers['physical_stats'] as Map<String, dynamic>? ?? {};
    final age = stats['age'] as int? ?? 0;
    final weightKg = stats['weight_kg'] as double? ?? 0.0;
    final heightM = stats['height_m'] as double? ?? 0.0;
    final targetWeightKg = stats['target_weight_kg'] as double?;

    final heightCm = heightM * 100.0;

    // --- Preferences ---
    final goalString = answers['goal'] as String? ?? 'general_fitness';
    final goal = FitnessGoalExtension.fromValue(goalString);

    final genderString = answers['gender'] as String? ?? 'prefer_not_to_say';
    final gender = GenderExtension.fromValue(genderString);

    final experienceString = answers['experience'] as String? ?? 'beginner';
    final experience = ExperienceLevelExtension.fromValue(experienceString);

    final freqString = answers['frequency'] as String? ?? '3-4';
    final frequency = WorkoutFrequencyExtension.fromValue(freqString);

    final durationString =
        answers['session_duration_minutes'] as String? ?? 'standard_60';
    final sessionDuration = SessionDurationExtension.fromValue(durationString);

    final activityString =
        answers['activity_level'] as String? ?? 'moderately_active';
    final activityLevel = ActivityLevelExtension.fromValue(activityString);

    final workoutDaysRaw =
        (answers['workout_days'] as List?)?.cast<String>() ?? [];
    // IMPORTANT: sort into calendar (Monday->Sunday) order. The raw list
    // comes from a Set built as the user taps checkboxes in QuestionView
    // — Set.toList() preserves INSERTION order, not weekday order. If
    // someone taps e.g. Friday before Thursday, `preferredDays` used to
    // stay in that tap order, and GenerationService zips it index-for-
    // index against the split template ([chest, back, legs, arms,
    // shouldersAndCore]) — so Friday silently got the "arms" split and
    // Thursday got "shoulders & core", the reverse of what the calendar
    // order would predict. Sorting once here fixes every downstream
    // consumer (WorkoutFrequencyPlanner, ProgramGenerator,
    // RegenerationService, etc.) without needing to remember to sort in
    // each of them separately.
    final preferredDays = workoutDaysRaw
        .map(WorkoutDayExtension.fromValue)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final equipmentRaw = (answers['equipment'] as List?)?.cast<String>() ?? [];
    final equipment =
        equipmentRaw.map(EquipmentTypeExtension.fromValue).toList();

    final focusRaw = (answers['focus_areas'] as List?)?.cast<String>() ?? [];
    final focusAreas = focusRaw.map(MuscleGroupExtension.fromValue).toList();

    final avoidedRaw =
        (answers['avoided_muscles'] as List?)?.cast<String>() ?? [];
    final avoidedMuscles =
        avoidedRaw.map(MuscleGroupExtension.fromValue).toList();

    final country = answers['country'] as String? ?? 'Unknown';

    // --- Nutrition ---
    final budgetString = answers['food_budget'] as String? ?? 'medium';
    final budget = BudgetLevelExtension.fromValue(budgetString);

    final foodRestrictions =
        (answers['food_restrictions'] as List?)?.cast<String>() ?? [];
    final foodPreferences =
        (answers['food_preferences'] as List?)?.cast<String>() ?? [];

    // --- Build value objects ---
    final body = BodyMeasurements(
      age: age,
      heightCm: heightCm,
      currentWeightKg: weightKg,
      targetWeightKg: targetWeightKg,
      gender: gender,
    );

    final training = WorkoutPreferences(
      goal: goal,
      experience: experience,
      activityLevel: activityLevel,
      frequency: frequency,
      sessionDuration: sessionDuration,
      preferredDays: preferredDays,
      equipment: equipment,
      focusAreas: focusAreas,
      avoidedMuscles: avoidedMuscles,
    );

    final lifestyle = LifestylePreferences(
      country: country,
      budget: budget,
      foodPreferences: foodPreferences,
      foodRestrictions: foodRestrictions,
    );

    final answeredQuestionIds =
        ProfileCompleteness.getAnsweredQuestionIds(answers);

    final now = DateTime.now();

    return HealthProfile(
      userId: '', // will be set later by the Bloc
      body: body,
      training: training,
      lifestyle: lifestyle,
      answeredQuestionIds: answeredQuestionIds,
      createdAt: now,
      updatedAt: now,
    );
  }
}
