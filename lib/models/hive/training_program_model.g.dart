// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_program_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingProgramModelAdapter extends TypeAdapter<TrainingProgramModel> {
  @override
  final int typeId = 1;

  @override
  TrainingProgramModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingProgramModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      durationInWeeks: fields[3] as int,
      weeklySchedule: (fields[4] as Map).cast<String, dynamic>(),
      generatedAt: fields[5] as DateTime,
      expiresAt: fields[6] as DateTime,
      goal: fields[7] as String?,
      splitType: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrainingProgramModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.durationInWeeks)
      ..writeByte(4)
      ..write(obj.weeklySchedule)
      ..writeByte(5)
      ..write(obj.generatedAt)
      ..writeByte(6)
      ..write(obj.expiresAt)
      ..writeByte(7)
      ..write(obj.goal)
      ..writeByte(8)
      ..write(obj.splitType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingProgramModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
