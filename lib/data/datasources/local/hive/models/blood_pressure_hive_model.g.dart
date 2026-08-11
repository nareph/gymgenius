// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_pressure_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodPressureHiveModelAdapter
    extends TypeAdapter<BloodPressureHiveModel> {
  @override
  final int typeId = 18;

  @override
  BloodPressureHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodPressureHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      systolic: fields[2] as int,
      diastolic: fields[3] as int,
      heartRateBpm: fields[4] as int?,
      measuredAt: fields[5] as DateTime,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BloodPressureHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.systolic)
      ..writeByte(3)
      ..write(obj.diastolic)
      ..writeByte(4)
      ..write(obj.heartRateBpm)
      ..writeByte(5)
      ..write(obj.measuredAt)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodPressureHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
