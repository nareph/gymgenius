// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_food_portion_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoggedFoodPortionHiveModelAdapter
    extends TypeAdapter<LoggedFoodPortionHiveModel> {
  @override
  final int typeId = 24;

  @override
  LoggedFoodPortionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoggedFoodPortionHiveModel(
      foodId: fields[0] as String,
      foodName: fields[1] as String,
      grams: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LoggedFoodPortionHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.foodId)
      ..writeByte(1)
      ..write(obj.foodName)
      ..writeByte(2)
      ..write(obj.grams);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedFoodPortionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
