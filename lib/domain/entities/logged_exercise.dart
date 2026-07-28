import 'logged_set.dart';

/// A logged exercise within a workout session.
/// Contains both the planned parameters and the actual performed sets.
class LoggedExercise {
  final String exerciseId;
  final String name;
  final int targetSets;
  final String targetReps; // e.g. '8-12' or '45s'
  final int targetRestSeconds;
  final bool isTimed;
  final List<LoggedSet> sets;
  final bool completed;
  final int? rpe; // Rate of Perceived Exertion (0-10)

  const LoggedExercise({
    required this.exerciseId,
    required this.name,
    required this.targetSets,
    required this.targetReps,
    required this.targetRestSeconds,
    required this.isTimed,
    required this.sets,
    required this.completed,
    this.rpe,
  });

  int get completedSets => sets.length;

  double get completionRate => targetSets > 0 ? completedSets / targetSets : 0;

  double get totalVolumeKg =>
      sets.fold(0.0, (sum, set) => sum + (set.reps * set.weightKg));

  LoggedExercise copyWith({
    String? exerciseId,
    String? name,
    int? targetSets,
    String? targetReps,
    int? targetRestSeconds,
    bool? isTimed,
    List<LoggedSet>? sets,
    bool? completed,
    int? rpe,
  }) {
    return LoggedExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
      isTimed: isTimed ?? this.isTimed,
      sets: sets ?? this.sets,
      completed: completed ?? this.completed,
      rpe: rpe ?? this.rpe,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LoggedExercise && other.exerciseId == exerciseId;
  }

  @override
  int get hashCode => exerciseId.hashCode;

  @override
  String toString() => 'LoggedExercise($name, ${sets.length}/$targetSets sets)';
}
