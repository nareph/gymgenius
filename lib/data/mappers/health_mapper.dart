import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/data/datasources/local/hive/models/health_profile_hive_model.dart';

/// Converts between Hive HealthProfileHiveModel and Domain HealthProfile.
class HealthMapper {
  const HealthMapper._();

  static HealthProfile toDomain(HealthProfileHiveModel model) {
    return HealthProfile(
      userId: model.userId,
      body: BodyMeasurements(
        age: model.age,
        heightCm: model.heightCm,
        currentWeightKg: model.currentWeightKg,
        targetWeightKg: model.targetWeightKg,
        gender: _mapGender(model.gender),
      ),
      training: WorkoutPreferences(
        goal: _mapFitnessGoal(model.goal),
        experience: _mapExperienceLevel(model.experience),
        activityLevel: _mapActivityLevel(model.activityLevel),
        frequency: _mapWorkoutFrequency(model.workoutDaysPerWeek),
        sessionDuration: _mapSessionDuration(model.workoutDurationMinutes),
        preferredDays: model.preferredWorkoutDays.map(_mapWorkoutDay).toList(),
        equipment: model.availableEquipment.map(_mapEquipmentType).toList(),
        focusAreas: model.focusAreas.map(_mapMuscleGroup).toList(),
        avoidedMuscles: (model.avoidedMuscles ?? const [])
            .map(_mapMuscleGroup)
            .toList(),
      ),
      lifestyle: LifestylePreferences(
        country: model.country,
        budget: BudgetLevel.medium,
        foodPreferences: const [],
        foodRestrictions: const [],
      ),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      // `model.answeredQuestionIds` is null for profiles saved before this
      // field existed. Falling back to `const []` means a legacy profile
      // is treated as "nothing confirmed yet" -> HealthProfile.isComplete
      // returns false -> AuthBloc routes the user back into ProfileSetup.
      // That's the safe default: we genuinely don't know which of the
      // legacy profile's values were real answers vs. mapper defaults, so
      // we can't claim it's complete. The full questionnaire will show
      // (missingFieldIds falls back to HealthProfile.requiredFieldIds),
      // and re-answering will populate answeredQuestionIds going forward.
      answeredQuestionIds: model.answeredQuestionIds ?? const [],
    );
  }

  static HealthProfileHiveModel toHive(HealthProfile entity) {
    return HealthProfileHiveModel(
      userId: entity.userId,
      age: entity.body.age,
      gender: entity.body.gender.name,
      heightCm: entity.body.heightCm,
      currentWeightKg: entity.body.currentWeightKg,
      targetWeightKg: entity.body.targetWeightKg,
      goal: entity.training.goal.name,
      experience: entity.training.experience.name,
      activityLevel: entity.training.activityLevel.name,
      workoutDaysPerWeek: entity.training.frequency.toDays(),
      // ✅ Utilisation du getter 'minutes' au lieu de 'toMinutes()'
      workoutDurationMinutes: entity.training.sessionDuration.minutes,
      preferredWorkoutDays:
          entity.training.preferredDays.map((d) => d.name).toList(),
      availableEquipment: entity.training.equipment.map((e) => e.name).toList(),
      focusAreas: entity.training.focusAreas.map((m) => m.name).toList(),
      avoidedMuscles:
          entity.training.avoidedMuscles.map((m) => m.name).toList(),
      country: entity.lifestyle.country,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      answeredQuestionIds: entity.answeredQuestionIds,
    );
  }

  // ============================================================
  // Mapping helpers
  // ============================================================

  static Gender _mapGender(String value) {
    return Gender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Gender.preferNotToSay,
    );
  }

  static FitnessGoal _mapFitnessGoal(String value) {
    return FitnessGoal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FitnessGoal.generalFitness,
    );
  }

  static ExperienceLevel _mapExperienceLevel(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExperienceLevel.beginner,
    );
  }

  static ActivityLevel _mapActivityLevel(String value) {
    return ActivityLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActivityLevel.moderatelyActive,
    );
  }

  static WorkoutFrequency _mapWorkoutFrequency(int days) {
    if (days <= 2) return WorkoutFrequency.oneToTwo;
    if (days <= 4) return WorkoutFrequency.threeToFour;
    return WorkoutFrequency.fivePlus;
  }

  static SessionDuration _mapSessionDuration(int minutes) {
    if (minutes <= 30) return SessionDuration.short30;
    if (minutes <= 45) return SessionDuration.medium45;
    if (minutes <= 60) return SessionDuration.standard60;
    if (minutes <= 75) return SessionDuration.long75;
    return SessionDuration.veryLong90;
  }

  static WorkoutDay _mapWorkoutDay(String value) {
    return WorkoutDay.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkoutDay.monday,
    );
  }

  static EquipmentType _mapEquipmentType(String value) {
    return EquipmentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EquipmentType.bodyweight,
    );
  }

  static MuscleGroup _mapMuscleGroup(String value) {
    return MuscleGroup.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MuscleGroup.chest,
    );
  }
}
