// lib/models/exercise.dart
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

/// Represents a single exercise in a workout session.
/// Used in UI and workout session management.
class Exercise {
  final String id;
  final String name;
  final int sets;
  final String reps; // e.g. "8-12" or "45s" for timed exercises
  final String description;
  final String weightSuggestionKg; // e.g. "60" or "Bodyweight"
  final int restBetweenSetsSeconds;
  final bool usesWeight;
  final bool isTimed;
  final int? targetDurationSeconds; // for timed exercises

  Exercise({
    String? id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.description,
    required this.weightSuggestionKg,
    required this.restBetweenSetsSeconds,
    required this.usesWeight,
    required this.isTimed,
    this.targetDurationSeconds,
  }) : id = id ?? _uuid.v4();

  /// Creates an Exercise from a Map (typically from a TrainingProgramModel)
  factory Exercise.fromMap(Map<String, dynamic> map) {
    final isTimed = map['isTimed'] as bool? ?? false;
    final targetDurationSeconds =
        isTimed ? (map['targetDurationSeconds'] as num?)?.toInt() : null;
    return Exercise(
      id: map['id'] as String? ?? _uuid.v4(),
      name: map['name'] as String? ?? 'Unknown Exercise',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: map['reps']?.toString() ?? '8-12',
      description: map['description'] as String? ?? '',
      weightSuggestionKg: map['weightSuggestionKg']?.toString() ?? 'Bodyweight',
      restBetweenSetsSeconds:
          (map['restBetweenSetsSeconds'] as num?)?.toInt() ?? 60,
      usesWeight: map['usesWeight'] as bool? ?? false,
      isTimed: isTimed,
      targetDurationSeconds: targetDurationSeconds,
    );
  }

  /// Converts to Map for storage or passing to managers
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'description': description,
      'weightSuggestionKg': weightSuggestionKg,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'usesWeight': usesWeight,
      'isTimed': isTimed,
      if (isTimed && targetDurationSeconds != null)
        'targetDurationSeconds': targetDurationSeconds,
    };
  }

  @override
  String toString() => 'Exercise($name, $sets×$reps)';
}
