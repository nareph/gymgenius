// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_profile_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthProfileHiveModelAdapter
    extends TypeAdapter<HealthProfileHiveModel> {
  @override
  final int typeId = 4;

  @override
  HealthProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthProfileHiveModel(
      userId: fields[0] as String,
      age: fields[1] as int,
      gender: fields[2] as String,
      heightCm: fields[3] as double,
      currentWeightKg: fields[4] as double,
      targetWeightKg: fields[5] as double?,
      goal: fields[6] as String,
      experience: fields[7] as String,
      activityLevel: fields[8] as String,
      workoutDaysPerWeek: fields[9] as int,
      workoutDurationMinutes: fields[10] as int,
      preferredWorkoutDays: (fields[11] as List).cast<String>(),
      availableEquipment: (fields[12] as List).cast<String>(),
      focusAreas: (fields[13] as List).cast<String>(),
      country: fields[14] as String,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      answeredQuestionIds: (fields[17] as List?)?.cast<String>(),
      avoidedMuscles: (fields[18] as List?)?.cast<String>(),
      budget: fields[19] as String?,
      foodPreferences: (fields[20] as List?)?.cast<String>(),
      foodRestrictions: (fields[21] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HealthProfileHiveModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.heightCm)
      ..writeByte(4)
      ..write(obj.currentWeightKg)
      ..writeByte(5)
      ..write(obj.targetWeightKg)
      ..writeByte(6)
      ..write(obj.goal)
      ..writeByte(7)
      ..write(obj.experience)
      ..writeByte(8)
      ..write(obj.activityLevel)
      ..writeByte(9)
      ..write(obj.workoutDaysPerWeek)
      ..writeByte(10)
      ..write(obj.workoutDurationMinutes)
      ..writeByte(11)
      ..write(obj.preferredWorkoutDays)
      ..writeByte(12)
      ..write(obj.availableEquipment)
      ..writeByte(13)
      ..write(obj.focusAreas)
      ..writeByte(14)
      ..write(obj.country)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.answeredQuestionIds)
      ..writeByte(18)
      ..write(obj.avoidedMuscles)
      ..writeByte(19)
      ..write(obj.budget)
      ..writeByte(20)
      ..write(obj.foodPreferences)
      ..writeByte(21)
      ..write(obj.foodRestrictions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthProfileHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
