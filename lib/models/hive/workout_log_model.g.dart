// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogModelAdapter extends TypeAdapter<WorkoutLogModel> {
  @override
  final int typeId = 2;

  @override
  WorkoutLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      savedAt: fields[2] as DateTime,
      workoutData: (fields[3] as Map).cast<String, dynamic>(),
      synced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.savedAt)
      ..writeByte(3)
      ..write(obj.workoutData)
      ..writeByte(4)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
