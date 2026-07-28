// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_program_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingProgramHiveModelAdapter
    extends TypeAdapter<TrainingProgramHiveModel> {
  @override
  final int typeId = 5;

  @override
  TrainingProgramHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingProgramHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      goal: fields[3] as String,
      split: fields[4] as String,
      experience: fields[5] as String,
      phase: fields[6] as String,
      mesocycle: fields[7] as int,
      microcycle: fields[8] as int,
      durationWeeks: fields[9] as int,
      weeklySchedule: (fields[10] as Map).cast<String, dynamic>(),
      generatorType: fields[11] as String,
      generatorVersion: fields[12] as String,
      createdAt: fields[13] as DateTime,
      expiresAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingProgramHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.goal)
      ..writeByte(4)
      ..write(obj.split)
      ..writeByte(5)
      ..write(obj.experience)
      ..writeByte(6)
      ..write(obj.phase)
      ..writeByte(7)
      ..write(obj.mesocycle)
      ..writeByte(8)
      ..write(obj.microcycle)
      ..writeByte(9)
      ..write(obj.durationWeeks)
      ..writeByte(10)
      ..write(obj.weeklySchedule)
      ..writeByte(11)
      ..write(obj.generatorType)
      ..writeByte(12)
      ..write(obj.generatorVersion)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingProgramHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
