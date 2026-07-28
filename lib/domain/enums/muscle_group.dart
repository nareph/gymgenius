// lib/domain/enums/muscle_group.dart

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  absCore,
  forearms,
  traps,
  adductors, // Added for side lunges
}

extension MuscleGroupExtension on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.quadriceps:
        return 'Quadriceps';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.absCore:
        return 'Abs / Core';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.traps:
        return 'Traps';
      case MuscleGroup.adductors:
        return 'Adductors';
    }
  }

  String get value {
    switch (this) {
      case MuscleGroup.chest:
        return 'chest';
      case MuscleGroup.back:
        return 'back';
      case MuscleGroup.shoulders:
        return 'shoulders';
      case MuscleGroup.biceps:
        return 'biceps';
      case MuscleGroup.triceps:
        return 'triceps';
      case MuscleGroup.quadriceps:
        return 'quadriceps';
      case MuscleGroup.hamstrings:
        return 'hamstrings';
      case MuscleGroup.glutes:
        return 'glutes';
      case MuscleGroup.calves:
        return 'calves';
      case MuscleGroup.absCore:
        return 'abs_core';
      case MuscleGroup.forearms:
        return 'forearms';
      case MuscleGroup.traps:
        return 'traps';
      case MuscleGroup.adductors:
        return 'adductors';
    }
  }

  static MuscleGroup fromValue(String value) {
    return MuscleGroup.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MuscleGroup.chest,
    );
  }
}
