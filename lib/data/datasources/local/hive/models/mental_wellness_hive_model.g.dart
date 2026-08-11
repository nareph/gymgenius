// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mental_wellness_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MentalWellnessHiveModelAdapter
    extends TypeAdapter<MentalWellnessHiveModel> {
  @override
  final int typeId = 21;

  @override
  MentalWellnessHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentalWellnessHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      mood: fields[3] as int,
      stress: fields[4] as String,
      energy: fields[5] as String,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MentalWellnessHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.stress)
      ..writeByte(5)
      ..write(obj.energy)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentalWellnessHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
