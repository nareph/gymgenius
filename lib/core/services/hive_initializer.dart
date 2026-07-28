// lib/core/services/hive_initializer.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymgenius/data/datasources/local/hive/models/user_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/health_profile_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/training_program_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/weekly_workout_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/workout_log_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/exercise_hive_model.dart';

class HiveInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    Hive.registerAdapter(UserHiveModelAdapter());
    Hive.registerAdapter(HealthProfileHiveModelAdapter());
    Hive.registerAdapter(TrainingProgramHiveModelAdapter());
    Hive.registerAdapter(WeeklyWorkoutHiveModelAdapter());
    Hive.registerAdapter(WorkoutLogHiveModelAdapter());
    Hive.registerAdapter(ExerciseHiveModelAdapter());
    Hive.registerAdapter(TempoHiveModelAdapter());

    // Ouvrir les boxes (cela peut être fait dans HiveDatasource)
    // Mais on peut aussi les ouvrir ici.
    await Hive.openBox<UserHiveModel>('users');
    await Hive.openBox<HealthProfileHiveModel>('health_profiles');
    await Hive.openBox<TrainingProgramHiveModel>('training_programs');
    await Hive.openBox<WeeklyWorkoutHiveModel>('weekly_workouts');
    await Hive.openBox<WorkoutLogHiveModel>('workout_logs');
    await Hive.openBox('current_user');
  }
}
