// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_workout_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyWorkoutModelAdapter extends TypeAdapter<WeeklyWorkoutModel> {
  @override
  final int typeId = 3;

  @override
  WeeklyWorkoutModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyWorkoutModel(
      id: fields[0] as String,
      programId: fields[1] as String,
      weekNumber: fields[2] as int,
      schedule: (fields[3] as Map).cast<String, dynamic>(),
      createdAt: fields[4] as DateTime,
      isActive: fields[5] as bool,
      progressionData: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyWorkoutModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programId)
      ..writeByte(2)
      ..write(obj.weekNumber)
      ..writeByte(3)
      ..write(obj.schedule)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.progressionData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyWorkoutModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
