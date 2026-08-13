// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_profile_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionProfileHiveModelAdapter
    extends TypeAdapter<NutritionProfileHiveModel> {
  @override
  final int typeId = 10;

  @override
  NutritionProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionProfileHiveModel(
      userId: fields[0] as String,
      date: fields[1] as DateTime,
      calories: fields[2] as int,
      proteinG: fields[3] as int,
      carbsG: fields[4] as int,
      fatG: fields[5] as int,
      waterMl: fields[6] as int?,
      country: fields[7] as String,
      preferredFoods: (fields[8] as List).cast<String>(),
      restrictedFoods: (fields[9] as List).cast<String>(),
      adherenceScore: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionProfileHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.proteinG)
      ..writeByte(4)
      ..write(obj.carbsG)
      ..writeByte(5)
      ..write(obj.fatG)
      ..writeByte(6)
      ..write(obj.waterMl)
      ..writeByte(7)
      ..write(obj.country)
      ..writeByte(8)
      ..write(obj.preferredFoods)
      ..writeByte(9)
      ..write(obj.restrictedFoods)
      ..writeByte(10)
      ..write(obj.adherenceScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionProfileHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
