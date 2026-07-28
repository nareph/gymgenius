// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_workout_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyWorkoutHiveModelAdapter
    extends TypeAdapter<WeeklyWorkoutHiveModel> {
  @override
  final int typeId = 6;

  @override
  WeeklyWorkoutHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyWorkoutHiveModel(
      id: fields[0] as String,
      programId: fields[1] as String,
      weekNumber: fields[2] as int,
      weekType: fields[3] as String,
      volumeMultiplier: fields[4] as double,
      intensityMultiplier: fields[5] as double,
      schedule: (fields[6] as Map).cast<String, dynamic>(),
      isActive: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyWorkoutHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programId)
      ..writeByte(2)
      ..write(obj.weekNumber)
      ..writeByte(3)
      ..write(obj.weekType)
      ..writeByte(4)
      ..write(obj.volumeMultiplier)
      ..writeByte(5)
      ..write(obj.intensityMultiplier)
      ..writeByte(6)
      ..write(obj.schedule)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyWorkoutHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
