// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogHiveModelAdapter extends TypeAdapter<WorkoutLogHiveModel> {
  @override
  final int typeId = 7;

  @override
  WorkoutLogHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLogHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      programId: fields[2] as String,
      week: fields[3] as int,
      day: fields[4] as String,
      startedAt: fields[5] as DateTime,
      endedAt: fields[6] as DateTime,
      durationSeconds: fields[7] as int,
      caloriesEstimate: fields[8] as int?,
      volume: fields[9] as double?,
      averageRPE: fields[10] as double?,
      completionScore: fields[11] as int,
      exercises: (fields[12] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      savedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLogHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.programId)
      ..writeByte(3)
      ..write(obj.week)
      ..writeByte(4)
      ..write(obj.day)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.endedAt)
      ..writeByte(7)
      ..write(obj.durationSeconds)
      ..writeByte(8)
      ..write(obj.caloriesEstimate)
      ..writeByte(9)
      ..write(obj.volume)
      ..writeByte(10)
      ..write(obj.averageRPE)
      ..writeByte(11)
      ..write(obj.completionScore)
      ..writeByte(12)
      ..write(obj.exercises)
      ..writeByte(13)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
