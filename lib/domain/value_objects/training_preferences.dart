import '../enums/activity_level.dart';
import '../enums/equipment_type.dart';
import '../enums/experience_level.dart';
import '../enums/fitness_goal.dart';
import '../enums/muscle_group.dart';
import '../enums/session_duration.dart';
import '../enums/workout_day.dart';
import '../enums/workout_frequency.dart';

/// User's training preferences used by all engines.
class TrainingPreferences {
  final FitnessGoal goal;
  final ExperienceLevel experience;
  final ActivityLevel activityLevel;
  final WorkoutFrequency frequency;
  final SessionDuration sessionDuration;
  final List<WorkoutDay> preferredDays;
  final List<EquipmentType> equipment;
  final List<MuscleGroup> focusAreas;

  const TrainingPreferences({
    required this.goal,
    required this.experience,
    required this.activityLevel,
    required this.frequency,
    required this.sessionDuration,
    required this.preferredDays,
    required this.equipment,
    required this.focusAreas,
  });

  TrainingPreferences copyWith({
    FitnessGoal? goal,
    ExperienceLevel? experience,
    ActivityLevel? activityLevel,
    WorkoutFrequency? frequency,
    SessionDuration? sessionDuration,
    List<WorkoutDay>? preferredDays,
    List<EquipmentType>? equipment,
    List<MuscleGroup>? focusAreas,
  }) {
    return TrainingPreferences(
      goal: goal ?? this.goal,
      experience: experience ?? this.experience,
      activityLevel: activityLevel ?? this.activityLevel,
      frequency: frequency ?? this.frequency,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      preferredDays: preferredDays ?? this.preferredDays,
      equipment: equipment ?? this.equipment,
      focusAreas: focusAreas ?? this.focusAreas,
    );
  }
}
