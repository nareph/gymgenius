// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseHiveModelAdapter extends TypeAdapter<ExerciseHiveModel> {
  @override
  final int typeId = 8;

  @override
  ExerciseHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      movementPattern: fields[4] as String,
      primaryMuscles: (fields[5] as List).cast<String>(),
      secondaryMuscles: (fields[6] as List).cast<String>(),
      equipment: fields[7] as String,
      difficulty: fields[8] as String,
      mechanics: fields[9] as String,
      forceType: fields[10] as String,
      laterality: fields[11] as String,
      planeOfMotion: fields[12] as String,
      sets: fields[13] as int,
      reps: fields[14] as String,
      restSeconds: fields[15] as int,
      weightSuggestion: fields[16] as String?,
      isBodyweight: fields[17] as bool,
      isTimed: fields[18] as bool,
      targetDurationSeconds: fields[19] as int?,
      instructions: fields[20] as String,
      tips: (fields[21] as List).cast<String>(),
      commonMistakes: (fields[22] as List).cast<String>(),
      rpe: fields[23] as int?,
      rir: fields[24] as int?,
      tempo: fields[25] as TempoHiveModel?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseHiveModel obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.movementPattern)
      ..writeByte(5)
      ..write(obj.primaryMuscles)
      ..writeByte(6)
      ..write(obj.secondaryMuscles)
      ..writeByte(7)
      ..write(obj.equipment)
      ..writeByte(8)
      ..write(obj.difficulty)
      ..writeByte(9)
      ..write(obj.mechanics)
      ..writeByte(10)
      ..write(obj.forceType)
      ..writeByte(11)
      ..write(obj.laterality)
      ..writeByte(12)
      ..write(obj.planeOfMotion)
      ..writeByte(13)
      ..write(obj.sets)
      ..writeByte(14)
      ..write(obj.reps)
      ..writeByte(15)
      ..write(obj.restSeconds)
      ..writeByte(16)
      ..write(obj.weightSuggestion)
      ..writeByte(17)
      ..write(obj.isBodyweight)
      ..writeByte(18)
      ..write(obj.isTimed)
      ..writeByte(19)
      ..write(obj.targetDurationSeconds)
      ..writeByte(20)
      ..write(obj.instructions)
      ..writeByte(21)
      ..write(obj.tips)
      ..writeByte(22)
      ..write(obj.commonMistakes)
      ..writeByte(23)
      ..write(obj.rpe)
      ..writeByte(24)
      ..write(obj.rir)
      ..writeByte(25)
      ..write(obj.tempo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TempoHiveModelAdapter extends TypeAdapter<TempoHiveModel> {
  @override
  final int typeId = 9;

  @override
  TempoHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempoHiveModel(
      eccentric: fields[0] as int,
      pause: fields[1] as int,
      concentric: fields[2] as int,
      pauseAfter: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TempoHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.eccentric)
      ..writeByte(1)
      ..write(obj.pause)
      ..writeByte(2)
      ..write(obj.concentric)
      ..writeByte(3)
      ..write(obj.pauseAfter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempoHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
