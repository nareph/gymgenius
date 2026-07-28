import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/enums/week_type.dart';

/// Domain Entity representing one week of a training program.
class WeeklyWorkout {
  final String id;
  final String programId;
  final int weekNumber;
  final WeekType weekType;
  final double volumeMultiplier;
  final double intensityMultiplier;
  final Map<String, List<Exercise>> schedule;
  final bool isActive;
  final DateTime createdAt;

  const WeeklyWorkout({
    required this.id,
    required this.programId,
    required this.weekNumber,
    required this.weekType,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
    required this.schedule,
    required this.isActive,
    required this.createdAt,
  });

  bool get isDeload => weekType == WeekType.deload;
  bool get isPeak => weekType == WeekType.peak;
  bool get isTest => weekType == WeekType.test;

  WeeklyWorkout copyWith({
    String? id,
    String? programId,
    int? weekNumber,
    WeekType? weekType,
    double? volumeMultiplier,
    double? intensityMultiplier,
    Map<String, List<Exercise>>? schedule,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return WeeklyWorkout(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      weekNumber: weekNumber ?? this.weekNumber,
      weekType: weekType ?? this.weekType,
      volumeMultiplier: volumeMultiplier ?? this.volumeMultiplier,
      intensityMultiplier: intensityMultiplier ?? this.intensityMultiplier,
      schedule: schedule ?? this.schedule,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'WeeklyWorkout(week $weekNumber, $weekType)';
}
