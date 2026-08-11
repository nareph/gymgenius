// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_checkin_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyCheckInHiveModelAdapter extends TypeAdapter<DailyCheckInHiveModel> {
  @override
  final int typeId = 14;

  @override
  DailyCheckInHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyCheckInHiveModel(
      userId: fields[0] as String,
      date: fields[1] as DateTime,
      weightKg: fields[2] as double,
      sleepHours: fields[3] as double,
      sorenessLevel: fields[4] as String,
      energyLevel: fields[5] as String,
      mood: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyCheckInHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.sleepHours)
      ..writeByte(4)
      ..write(obj.sorenessLevel)
      ..writeByte(5)
      ..write(obj.energyLevel)
      ..writeByte(6)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyCheckInHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
