import 'package:gymgenius/domain/enums/muscle_group.dart';

/// Represents a muscle group split for a training day.
class MuscleSplit {
  final String name;
  final List<MuscleGroup> muscles;
  final String theme;

  const MuscleSplit({
    required this.name,
    required this.muscles,
    required this.theme,
  });
}
