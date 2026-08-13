import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';

class WorkoutPreferences {
  final FitnessGoal goal;
  final ExperienceLevel experience;
  final ActivityLevel activityLevel;
  final WorkoutFrequency frequency; // ← ajouté
  final SessionDuration sessionDuration;
  final List<WorkoutDay> preferredDays;
  final List<EquipmentType> equipment;
  final List<MuscleGroup> focusAreas;

  /// Muscle groups the user wants to avoid (injury, pain, medical restriction).
  /// Empty means no restriction. Optional at onboarding.
  final List<MuscleGroup> avoidedMuscles;

  const WorkoutPreferences({
    required this.goal,
    required this.experience,
    required this.activityLevel,
    required this.frequency, // ← requis
    required this.sessionDuration,
    required this.preferredDays,
    required this.equipment,
    required this.focusAreas,
    this.avoidedMuscles = const [],
  });

  WorkoutPreferences copyWith({
    FitnessGoal? goal,
    ExperienceLevel? experience,
    ActivityLevel? activityLevel,
    WorkoutFrequency? frequency,
    SessionDuration? sessionDuration,
    List<WorkoutDay>? preferredDays,
    List<EquipmentType>? equipment,
    List<MuscleGroup>? focusAreas,
    List<MuscleGroup>? avoidedMuscles,
  }) {
    return WorkoutPreferences(
      goal: goal ?? this.goal,
      experience: experience ?? this.experience,
      activityLevel: activityLevel ?? this.activityLevel,
      frequency: frequency ?? this.frequency,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      preferredDays: preferredDays ?? this.preferredDays,
      equipment: equipment ?? this.equipment,
      focusAreas: focusAreas ?? this.focusAreas,
      avoidedMuscles: avoidedMuscles ?? this.avoidedMuscles,
    );
  }

  @override
  String toString() {
    return 'WorkoutPreferences(goal: ${goal.value}, frequency: ${frequency.value})';
  }
}
