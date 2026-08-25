// lib/engines/workout_engine/models/muscle_split.dart

import 'package:gymgenius/domain/enums/muscle_group.dart';

/// Describes a training split used by the Workout Engine.
///
/// A MuscleSplit is a reusable template representing one workout day.
///
/// It does NOT contain exercises.
///
/// It only defines:
///
/// • split name
/// • muscles trained
/// • human-readable theme
/// • estimated recovery cost
/// • whether it is upper/lower/full body
class MuscleSplit {
  final String name;
  final List<MuscleGroup> muscles;
  final String theme;
  final int recoveryCost;
  final bool isUpperBody;
  final bool isLowerBody;
  final bool isFullBody;

  const MuscleSplit({
    required this.name,
    required this.muscles,
    required this.theme,
    this.recoveryCost = 1,
    this.isUpperBody = false,
    this.isLowerBody = false,
    this.isFullBody = false,
  });

  // ============================================================
  // Primary muscles (visible identity of the session)
  // ============================================================

  /// Primary muscles that define the visible identity of this session.
  ///
  /// These are used for compatibility checks with user focus areas.
  List<MuscleGroup> get primaryMuscles {
    switch (name) {
      case 'Push':
        return const [MuscleGroup.chest];

      case 'Pull':
        return const [MuscleGroup.back];

      case 'Legs':
        return const [
          MuscleGroup.quadriceps,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
        ];

      case 'Chest':
        return const [MuscleGroup.chest];

      case 'Back':
        return const [MuscleGroup.back];

      case 'Arms':
        return const [
          MuscleGroup.biceps,
          MuscleGroup.triceps,
          MuscleGroup.forearms,
        ];

      case 'Chest & Triceps':
        return const [
          MuscleGroup.chest,
          MuscleGroup.triceps,
        ];

      case 'Back & Biceps':
        return const [
          MuscleGroup.back,
          MuscleGroup.biceps,
        ];

      case 'Shoulders & Core':
        return const [
          MuscleGroup.shoulders,
          MuscleGroup.absCore,
        ];

      case 'Upper Body':
        return const [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
        ];

      case 'Lower Body':
        return const [
          MuscleGroup.quadriceps,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
        ];

      case 'Full Body':
        return List<MuscleGroup>.unmodifiable(muscles);

      default:
        return List<MuscleGroup>.unmodifiable(muscles);
    }
  }

  // ============================================================
  // User-facing display names
  // ============================================================

  /// User-friendly name of the main focus of this session.
  String get displayName {
    switch (name) {
      case 'Push':
        return 'Chest';
      case 'Pull':
        return 'Back';
      case 'Legs':
        return 'Legs';
      case 'Chest':
        return 'Chest';
      case 'Back':
        return 'Back';
      case 'Arms':
        return 'Arms';
      case 'Chest & Triceps':
        return 'Chest & Triceps';
      case 'Back & Biceps':
        return 'Back & Biceps';
      case 'Shoulders & Core':
        return 'Shoulders & Core';
      case 'Upper Body':
        return 'Upper Body';
      case 'Lower Body':
        return 'Lower Body';
      case 'Full Body':
        return 'Full Body';
      default:
        return name;
    }
  }

  /// Full title for today's workout (e.g. "Today: Chest").
  String get todayTitle => 'Today: $displayName';

  // ============================================================
  // Helpers
  // ============================================================

  bool targets(MuscleGroup muscle) => muscles.contains(muscle);

  int scoreAgainst(List<MuscleGroup> focusMuscles) {
    if (focusMuscles.isEmpty) return 0;
    return muscles.where(focusMuscles.contains).length;
  }

  MuscleSplit copyWith({
    String? name,
    List<MuscleGroup>? muscles,
    String? theme,
    int? recoveryCost,
    bool? isUpperBody,
    bool? isLowerBody,
    bool? isFullBody,
  }) {
    return MuscleSplit(
      name: name ?? this.name,
      muscles: muscles ?? this.muscles,
      theme: theme ?? this.theme,
      recoveryCost: recoveryCost ?? this.recoveryCost,
      isUpperBody: isUpperBody ?? this.isUpperBody,
      isLowerBody: isLowerBody ?? this.isLowerBody,
      isFullBody: isFullBody ?? this.isFullBody,
    );
  }

  @override
  String toString() {
    return 'MuscleSplit('
        'name: $name, '
        'muscles: ${muscles.length}, '
        'recoveryCost: $recoveryCost'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MuscleSplit &&
            runtimeType == other.runtimeType &&
            name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}
