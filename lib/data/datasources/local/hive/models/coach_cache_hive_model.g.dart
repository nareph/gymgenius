// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_cache_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoachCacheHiveModelAdapter extends TypeAdapter<CoachCacheHiveModel> {
  @override
  final int typeId = 17;

  @override
  CoachCacheHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoachCacheHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      kind: fields[2] as String,
      periodStart: fields[3] as DateTime,
      generatedAt: fields[4] as DateTime,
      responseJson: fields[5] as String,
      providerId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CoachCacheHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.kind)
      ..writeByte(3)
      ..write(obj.periodStart)
      ..writeByte(4)
      ..write(obj.generatedAt)
      ..writeByte(5)
      ..write(obj.responseJson)
      ..writeByte(6)
      ..write(obj.providerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachCacheHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
