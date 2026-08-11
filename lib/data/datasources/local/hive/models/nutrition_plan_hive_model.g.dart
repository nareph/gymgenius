// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_plan_hive_model.dart';

class NutritionPlanHiveModelAdapter extends TypeAdapter<NutritionPlanHiveModel> {
  @override
  final int typeId = 11;

  @override
  NutritionPlanHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionPlanHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      calories: fields[3] as int,
      proteinG: fields[4] as int,
      carbsG: fields[5] as int,
      fatG: fields[6] as int,
      waterMl: fields[7] as int?,
      maintenanceCalories: fields[8] as double,
      status: fields[9] as String,
      meals: (fields[10] as List).cast<MealHiveModel>(),
      country: fields[11] as String,
      isTrainingDay: fields[12] as bool,
      reasons: (fields[13] as List).cast<String>(),
      generatedBy: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionPlanHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.proteinG)
      ..writeByte(5)
      ..write(obj.carbsG)
      ..writeByte(6)
      ..write(obj.fatG)
      ..writeByte(7)
      ..write(obj.waterMl)
      ..writeByte(8)
      ..write(obj.maintenanceCalories)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.meals)
      ..writeByte(11)
      ..write(obj.country)
      ..writeByte(12)
      ..write(obj.isTrainingDay)
      ..writeByte(13)
      ..write(obj.reasons)
      ..writeByte(14)
      ..write(obj.generatedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionPlanHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
