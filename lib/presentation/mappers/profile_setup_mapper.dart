import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/presentation/mappers/profile_completeness.dart';

import '../../domain/enums/exports.dart';

class ProfileSetupMapper {
  const ProfileSetupMapper._();

  static HealthProfile toDomain(Map<String, dynamic> answers) {
    // Physical stats
    final stats = answers['physical_stats'] as Map<String, dynamic>? ?? {};
    final age = stats['age'] as int? ?? 0;
    final weightKg = stats['weight_kg'] as double? ?? 0.0;
    final heightM = stats['height_m'] as double? ?? 0.0;
    final targetWeightKg = stats['target_weight_kg'] as double?;

    final heightCm = heightM * 100.0;

    // Preferences
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
    final preferredDays =
        workoutDaysRaw.map(WorkoutDayExtension.fromValue).toList();

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
      budget: BudgetLevel.medium,
    );

    // The values above are ALWAYS populated (defaulted when unanswered) so
    // every engine gets a usable profile. `answeredQuestionIds` is the
    // only place that records which of those values are real user input
    // vs. a silent fallback — see HealthProfile.isComplete.
    final answeredQuestionIds =
        ProfileCompleteness.getAnsweredRequiredQuestionIds(answers);

    final now = DateTime.now();
    return HealthProfile(
      userId: '', // will be set later
      body: body,
      training: training,
      lifestyle: lifestyle,
      createdAt: now,
      updatedAt: now,
      answeredQuestionIds: answeredQuestionIds,
    );
  }
}
