// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_status_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecoveryStatusHiveModelAdapter
    extends TypeAdapter<RecoveryStatusHiveModel> {
  @override
  final int typeId = 13;

  @override
  RecoveryStatusHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecoveryStatusHiveModel(
      userId: fields[0] as String,
      date: fields[1] as DateTime,
      recoveryScore: fields[2] as int,
      fatigueScore: fields[3] as int,
      readinessScore: fields[4] as int,
      recommendedIntensity: fields[5] as String,
      volumeMultiplier: fields[6] as double,
      reasons: (fields[7] as List).cast<String>(),
      generatedBy: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecoveryStatusHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.recoveryScore)
      ..writeByte(3)
      ..write(obj.fatigueScore)
      ..writeByte(4)
      ..write(obj.readinessScore)
      ..writeByte(5)
      ..write(obj.recommendedIntensity)
      ..writeByte(6)
      ..write(obj.volumeMultiplier)
      ..writeByte(7)
      ..write(obj.reasons)
      ..writeByte(8)
      ..write(obj.generatedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryStatusHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
