// ============================================================
// FILE: lib/data/mappers/workout_mapper.dart
// ============================================================

import 'package:gymgenius/data/datasources/local/hive/models/exercise_hive_model.dart';
import 'package:gymgenius/domain/entities/logged_exercise.dart';
import 'package:gymgenius/domain/entities/logged_set.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/data/datasources/local/hive/models/training_program_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/workout_log_hive_model.dart';
import 'exercise_mapper.dart';

/// Converts between Hive workout models and Domain workout entities.
class WorkoutMapper {
  const WorkoutMapper._();

  // ============================================================
  // Training Program
  // ============================================================

  static TrainingProgram toTrainingProgram(TrainingProgramHiveModel model) {
    final schedule = <String, List<Exercise>>{};
    for (final entry in model.weeklySchedule.entries) {
      final exercises = (entry.value as List).map((e) {
        return ExerciseMapper.toDomain(ExerciseHiveModel.fromMap(e));
      }).toList();
      schedule[entry.key] = exercises;
    }

    return TrainingProgram(
      id: model.id,
      userId: model.userId,
      name: model.name,
      goal: _mapFitnessGoal(model.goal),
      split: _mapSplitType(model.split),
      experience: _mapExperienceLevel(model.experience),
      durationWeeks: model.durationWeeks,
      weeklySchedule: schedule,
      generatorType: _mapGeneratorType(model.generatorType),
      generatorVersion: model.generatorVersion,
      createdAt: model.createdAt,
      expiresAt: model.expiresAt,
    );
  }

  static TrainingProgramHiveModel fromTrainingProgram(TrainingProgram entity) {
    final schedule = <String, dynamic>{};
    for (final entry in entity.weeklySchedule.entries) {
      schedule[entry.key] =
          entry.value.map((e) => ExerciseMapper.toHive(e).toMap()).toList();
    }

    return TrainingProgramHiveModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      goal: entity.goal.name,
      split: entity.split.name,
      experience: entity.experience.name,
      durationWeeks: entity.durationWeeks,
      weeklySchedule: schedule,
      generatorType: entity.generatorType.name,
      generatorVersion: entity.generatorVersion,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
    );
  }
  // ============================================================
  // Workout Log
  // ============================================================

  static WorkoutLog toWorkoutLog(WorkoutLogHiveModel model) {
    final exercises = model.exercises.map((e) {
      final data = Map<String, dynamic>.from(e);
      final sets = (data['sets'] as List)
          .map((s) => LoggedSet(
                setNumber: s['setNumber'] as int,
                reps: s['reps'] as int,
                weightKg: (s['weightKg'] as num).toDouble(),
                loggedAt:
                    DateTime.fromMillisecondsSinceEpoch(s['loggedAt'] as int),
              ))
          .toList();

      return LoggedExercise(
        exerciseId: data['exerciseId'] as String,
        name: data['name'] as String,
        targetSets: data['targetSets'] as int,
        targetReps: data['targetReps'] as String,
        targetRestSeconds: data['targetRestSeconds'] as int,
        isTimed: data['isTimed'] as bool,
        sets: sets,
        completed: data['completed'] as bool,
        rpe: data['rpe'] as int?,
      );
    }).toList();

    return WorkoutLog(
      id: model.id,
      userId: model.userId,
      programId: model.programId,
      week: model.week,
      day: model.day,
      startedAt: model.startedAt,
      endedAt: model.endedAt,
      durationSeconds: model.durationSeconds,
      caloriesEstimate: model.caloriesEstimate,
      volume: model.volume,
      averageRPE: model.averageRPE,
      completionScore: model.completionScore,
      exercises: exercises,
      savedAt: model.savedAt,
    );
  }

  static WorkoutLogHiveModel fromWorkoutLog(WorkoutLog entity) {
    final exercises = entity.exercises.map((e) {
      return {
        'exerciseId': e.exerciseId,
        'name': e.name,
        'targetSets': e.targetSets,
        'targetReps': e.targetReps,
        'targetRestSeconds': e.targetRestSeconds,
        'isTimed': e.isTimed,
        'sets': e.sets
            .map((s) => {
                  'setNumber': s.setNumber,
                  'reps': s.reps,
                  'weightKg': s.weightKg,
                  'loggedAt': s.loggedAt.millisecondsSinceEpoch,
                })
            .toList(),
        'completed': e.completed,
        'rpe': e.rpe,
      };
    }).toList();

    return WorkoutLogHiveModel(
      id: entity.id,
      userId: entity.userId,
      programId: entity.programId,
      week: entity.week,
      day: entity.day,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
      durationSeconds: entity.durationSeconds,
      caloriesEstimate: entity.caloriesEstimate,
      volume: entity.volume,
      averageRPE: entity.averageRPE,
      completionScore: entity.completionScore,
      exercises: exercises,
      savedAt: entity.savedAt,
    );
  }

  // ============================================================
  // Mapping helpers
  // ============================================================

  static FitnessGoal _mapFitnessGoal(String value) {
    return FitnessGoal.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FitnessGoal.generalFitness,
    );
  }

  static SplitType _mapSplitType(String value) {
    return SplitType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SplitType.custom,
    );
  }

  static ExperienceLevel _mapExperienceLevel(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExperienceLevel.beginner,
    );
  }

  static GeneratorType _mapGeneratorType(String value) {
    return GeneratorType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GeneratorType.local,
    );
  }
}
