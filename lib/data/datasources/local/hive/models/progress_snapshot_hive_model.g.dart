// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_snapshot_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressSnapshotHiveModelAdapter
    extends TypeAdapter<ProgressSnapshotHiveModel> {
  @override
  final int typeId = 15;

  @override
  ProgressSnapshotHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressSnapshotHiveModel(
      userId: fields[0] as String,
      computedAt: fields[1] as DateTime,
      period: fields[2] as String,
      currentWeightKg: fields[3] as double?,
      weeklyAverageWeightKg: fields[4] as double?,
      weightChangeKg: fields[5] as double?,
      weightDirection: fields[6] as String?,
      distanceToTargetKg: fields[7] as double?,
      weightDataPointCount: fields[8] as int,
      trackedExerciseCount: fields[9] as int,
      strengthOverallTrend: fields[10] as String?,
      strengthChangePercent: fields[11] as double,
      strengthPlateauDetected: fields[12] as bool,
      plannedWorkouts: fields[13] as int,
      completedWorkouts: fields[14] as int,
      consistencyScore: fields[15] as int,
      weeklyFrequency: fields[16] as double,
      consecutiveTrainingDays: fields[17] as int,
      consistencyTrend: fields[18] as String?,
      weightPlateauDetected: fields[19] as bool,
      reasons: (fields[20] as List).cast<String>(),
      generatedBy: fields[21] as String,
      topExercisesJson: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressSnapshotHiveModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.computedAt)
      ..writeByte(2)
      ..write(obj.period)
      ..writeByte(3)
      ..write(obj.currentWeightKg)
      ..writeByte(4)
      ..write(obj.weeklyAverageWeightKg)
      ..writeByte(5)
      ..write(obj.weightChangeKg)
      ..writeByte(6)
      ..write(obj.weightDirection)
      ..writeByte(7)
      ..write(obj.distanceToTargetKg)
      ..writeByte(8)
      ..write(obj.weightDataPointCount)
      ..writeByte(9)
      ..write(obj.trackedExerciseCount)
      ..writeByte(10)
      ..write(obj.strengthOverallTrend)
      ..writeByte(11)
      ..write(obj.strengthChangePercent)
      ..writeByte(12)
      ..write(obj.strengthPlateauDetected)
      ..writeByte(13)
      ..write(obj.plannedWorkouts)
      ..writeByte(14)
      ..write(obj.completedWorkouts)
      ..writeByte(15)
      ..write(obj.consistencyScore)
      ..writeByte(16)
      ..write(obj.weeklyFrequency)
      ..writeByte(17)
      ..write(obj.consecutiveTrainingDays)
      ..writeByte(18)
      ..write(obj.consistencyTrend)
      ..writeByte(19)
      ..write(obj.weightPlateauDetected)
      ..writeByte(20)
      ..write(obj.reasons)
      ..writeByte(21)
      ..write(obj.generatedBy)
      ..writeByte(22)
      ..write(obj.topExercisesJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressSnapshotHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
