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
///
/// The SplitPlanner selects the most appropriate collection of
/// MuscleSplits according to:
///
/// • training frequency
/// • experience
/// • focus muscles
/// • recovery
/// • future specialization rules
class MuscleSplit {
  /// Unique split name.
  ///
  /// Examples:
  ///
  /// • Push
  /// • Pull
  /// • Legs
  /// • Upper Body
  /// • Lower Body
  /// • Shoulders & Core
  final String name;

  /// Muscles trained by this split.
  final List<MuscleGroup> muscles;

  /// Display theme.
  final String theme;

  /// Estimated recovery cost.
  ///
  /// Higher values mean the split is more demanding.
  final int recoveryCost;

  /// Whether this split mainly targets the upper body.
  final bool isUpperBody;

  /// Whether this split mainly targets the lower body.
  final bool isLowerBody;

  /// Whether this split trains the whole body.
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

  /// True if this split trains the given muscle.
  bool targets(MuscleGroup muscle) {
    return muscles.contains(muscle);
  }

  /// Number of focus muscles matched by this split.
  int scoreAgainst(
    List<MuscleGroup> focusMuscles,
  ) {
    if (focusMuscles.isEmpty) {
      return 0;
    }

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
