import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/domain/entities/exercise.dart';

/// Domain Entity representing a multi‑week training program.
class TrainingProgram {
  final String id;
  final String userId;
  final String name;
  final FitnessGoal goal;
  final SplitType split;
  final ExperienceLevel experience;
  final int durationWeeks;
  final Map<String, List<Exercise>> weeklySchedule;
  final GeneratorType generatorType;
  final String generatorVersion;
  final DateTime createdAt;
  final DateTime expiresAt;

  const TrainingProgram({
    required this.id,
    required this.userId,
    required this.name,
    required this.goal,
    required this.split,
    required this.experience,
    required this.durationWeeks,
    required this.weeklySchedule,
    required this.generatorType,
    required this.generatorVersion,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  TrainingProgram copyWith({
    String? id,
    String? userId,
    String? name,
    FitnessGoal? goal,
    SplitType? split,
    ExperienceLevel? experience,
    int? durationWeeks,
    Map<String, List<Exercise>>? weeklySchedule,
    GeneratorType? generatorType,
    String? generatorVersion,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      split: split ?? this.split,
      experience: experience ?? this.experience,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      generatorType: generatorType ?? this.generatorType,
      generatorVersion: generatorVersion ?? this.generatorVersion,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'goal': goal.name,
      'split': split.name,
      'experience': experience.name,
      'durationWeeks': durationWeeks,
      'weeklySchedule': weeklySchedule.map(
          (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList())),
      'generatorType': generatorType.name,
      'generatorVersion': generatorVersion,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() => 'TrainingProgram($name, $durationWeeks weeks)';
}
