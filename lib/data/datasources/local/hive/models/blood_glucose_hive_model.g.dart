// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_glucose_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodGlucoseHiveModelAdapter extends TypeAdapter<BloodGlucoseHiveModel> {
  @override
  final int typeId = 19;

  @override
  BloodGlucoseHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodGlucoseHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      valueMmolL: fields[2] as double,
      context: fields[3] as String,
      measuredAt: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BloodGlucoseHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.valueMmolL)
      ..writeByte(3)
      ..write(obj.context)
      ..writeByte(4)
      ..write(obj.measuredAt)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodGlucoseHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
