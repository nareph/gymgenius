// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealHiveModelAdapter extends TypeAdapter<MealHiveModel> {
  @override
  final int typeId = 12;

  @override
  MealHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      objective: fields[3] as String,
      ingredients: (fields[4] as List).cast<String>(),
      calories: fields[5] as int,
      proteinG: fields[6] as int,
      carbsG: fields[7] as int,
      fatG: fields[8] as int,
      timingNote: fields[9] as String?,
      reason: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.objective)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.proteinG)
      ..writeByte(7)
      ..write(obj.carbsG)
      ..writeByte(8)
      ..write(obj.fatG)
      ..writeByte(9)
      ..write(obj.timingNote)
      ..writeByte(10)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
