// lib/data/datasources/local/hive/models/training_program_hive_model.dart

import 'package:hive/hive.dart';

part 'training_program_hive_model.g.dart';

@HiveType(typeId: 5)
class TrainingProgramHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String goal;

  @HiveField(4)
  String split;

  @HiveField(5)
  String experience;

  @HiveField(6)
  String phase;

  @HiveField(7)
  int mesocycle;

  @HiveField(8)
  int microcycle;

  @HiveField(9)
  int durationWeeks;

  @HiveField(10)
  Map<String, dynamic> weeklySchedule;

  @HiveField(11)
  String generatorType;

  @HiveField(12)
  String generatorVersion;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime expiresAt;

  TrainingProgramHiveModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.goal,
    required this.split,
    required this.experience,
    required this.phase,
    required this.mesocycle,
    required this.microcycle,
    required this.durationWeeks,
    required this.weeklySchedule,
    required this.generatorType,
    required this.generatorVersion,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'goal': goal,
      'split': split,
      'experience': experience,
      'phase': phase,
      'mesocycle': mesocycle,
      'microcycle': microcycle,
      'durationWeeks': durationWeeks,
      'weeklySchedule': weeklySchedule,
      'generatorType': generatorType,
      'generatorVersion': generatorVersion,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
  }

  factory TrainingProgramHiveModel.fromMap(Map<String, dynamic> map) {
    return TrainingProgramHiveModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      goal: map['goal'] as String,
      split: map['split'] as String,
      experience: map['experience'] as String,
      phase: map['phase'] as String,
      mesocycle: map['mesocycle'] as int,
      microcycle: map['microcycle'] as int,
      durationWeeks: map['durationWeeks'] as int,
      weeklySchedule: map['weeklySchedule'] as Map<String, dynamic>,
      generatorType: map['generatorType'] as String,
      generatorVersion: map['generatorVersion'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int),
    );
  }
}
