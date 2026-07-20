import 'package:gymgenius/engines/workout_engine/shared/equipment_mapper.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

class WorkoutProfile {
  final String? goal;
  final String? gender;
  final String? experience;
  final String? frequency;
  final String? sessionDuration;
  final List<String>? workoutDays;
  final List<String>? equipment;
  final List<String>? focusAreas;

  const WorkoutProfile({
    this.goal,
    this.gender,
    this.experience,
    this.frequency,
    this.sessionDuration,
    this.workoutDays,
    this.equipment,
    this.focusAreas,
  });

  factory WorkoutProfile.fromMap(Map<String, dynamic> map) {
    return WorkoutProfile(
      goal: map['goal'] as String?,
      gender: map['gender'] as String?,
      experience: map['experience'] as String?,
      frequency: map['frequency'] as String?,
      sessionDuration: map['session_duration_minutes'] as String?,
      workoutDays: (map['workout_days'] as List<dynamic>?)?.cast<String>(),
      equipment: (map['equipment'] as List<dynamic>?)?.cast<String>(),
      focusAreas: (map['focus_areas'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goal': goal,
      'gender': gender,
      'experience': experience,
      'frequency': frequency,
      'session_duration_minutes': sessionDuration,
      'workout_days': workoutDays,
      'equipment': equipment,
      'focus_areas': focusAreas,
    };
  }

  List<EquipmentType> getEquipmentTypes() {
    if (equipment == null || equipment!.isEmpty) {
      return [EquipmentType.bodyweight];
    }
    return EquipmentMapper.fromList(equipment!);
  }
}
