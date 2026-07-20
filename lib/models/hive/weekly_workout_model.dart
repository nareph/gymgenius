import 'package:hive/hive.dart';
import 'package:gymgenius/models/hive/training_program_model.dart';

part 'weekly_workout_model.g.dart';

/// A single week of workouts within a Training Program.
///
/// WeeklyWorkout represents one week's schedule, including exercise selection
/// and progression parameters for that specific week.
@HiveType(typeId: 3)
class WeeklyWorkoutModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String programId;

  @HiveField(2)
  int weekNumber; // 1-based within the program

  @HiveField(3)
  Map<String, dynamic> schedule; // dayOfWeek → list of exercises

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  Map<String, dynamic>? progressionData; // overload, intensity, etc.

  WeeklyWorkoutModel({
    required this.id,
    required this.programId,
    required this.weekNumber,
    required this.schedule,
    required this.createdAt,
    this.isActive = true,
    this.progressionData,
  });

  factory WeeklyWorkoutModel.fromProgram(
    TrainingProgramModel program, {
    String? id,
    int weekNumber = 1,
  }) {
    return WeeklyWorkoutModel(
      id: id ?? 'weekly_${program.id}_1',
      programId: program.id,
      weekNumber: weekNumber,
      schedule: Map<String, dynamic>.from(program.weeklySchedule),
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  bool isWithinProgram(TrainingProgramModel program) {
    return weekNumber <= program.durationInWeeks && !program.isExpired();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'programId': programId,
      'weekNumber': weekNumber,
      'schedule': schedule,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'progressionData': progressionData,
    };
  }

  factory WeeklyWorkoutModel.fromMap(Map<String, dynamic> map) {
    return WeeklyWorkoutModel(
      id: map['id'] as String,
      programId: map['programId'] as String,
      weekNumber: map['weekNumber'] as int,
      schedule: map['schedule'] as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isActive: map['isActive'] as bool? ?? true,
      progressionData: map['progressionData'] as Map<String, dynamic>?,
    );
  }
}
