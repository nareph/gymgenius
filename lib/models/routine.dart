// lib/models/routine.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class RoutineExercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final String weightSuggestionKg;
  final int restBetweenSetsSeconds;
  final String description; // Utilisé pour les instructions de réalisation
  final bool usesWeight;
  final bool isTimed;
  final int? targetDurationSeconds;

  RoutineExercise({
    String? id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weightSuggestionKg = 'N/A',
    this.restBetweenSetsSeconds = 60,
    this.description = '', // Default à une chaîne vide
    this.usesWeight = true,
    this.isTimed = false,
    this.targetDurationSeconds,
  }) : id = id ?? _uuid.v4();

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'] as String? ?? _uuid.v4(),
      name: map['name'] as String? ?? 'Unknown Exercise',
      sets: map['sets'] as int? ?? 3,
      reps: map['reps'] as String? ?? '8-12',
      weightSuggestionKg: map['weightSuggestionKg'] as String? ?? 'N/A',
      restBetweenSetsSeconds: map['restBetweenSetsSeconds'] as int? ?? 60,
      description:
          map['description'] as String? ?? '', // Default à une chaîne vide
      usesWeight: map['usesWeight'] as bool? ?? true,
      isTimed: map['isTimed'] as bool? ?? false,
      targetDurationSeconds: map['targetDurationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': weightSuggestionKg,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'description': description,
      'usesWeight': usesWeight,
      'isTimed': isTimed,
      if (targetDurationSeconds != null)
        'targetDurationSeconds': targetDurationSeconds,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutineExercise &&
        other.id == id &&
        other.name == name &&
        other.sets == sets &&
        other.reps == reps &&
        other.weightSuggestionKg == weightSuggestionKg &&
        other.restBetweenSetsSeconds == restBetweenSetsSeconds &&
        other.description == description &&
        other.usesWeight == usesWeight &&
        other.isTimed == isTimed &&
        other.targetDurationSeconds == targetDurationSeconds;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        sets.hashCode ^
        reps.hashCode ^
        weightSuggestionKg.hashCode ^
        restBetweenSetsSeconds.hashCode ^
        description.hashCode ^
        usesWeight.hashCode ^
        isTimed.hashCode ^
        targetDurationSeconds.hashCode;
  }
}

class WeeklyRoutine {
  final String id;
  final String name;
  final Map<String, List<RoutineExercise>> dailyWorkouts;
  final int durationInWeeks;
  final Timestamp generatedAt;
  final Timestamp expiresAt;

  WeeklyRoutine({
    required this.id,
    required this.name,
    required this.dailyWorkouts,
    required this.durationInWeeks,
    required this.generatedAt,
    required this.expiresAt,
  });

  factory WeeklyRoutine.fromMap(Map<String, dynamic> map) {
    Map<String, List<RoutineExercise>> parsedWorkouts = {};
    if (map['dailyWorkouts'] is Map) {
      (map['dailyWorkouts'] as Map).forEach((day, exercisesDynamic) {
        if (exercisesDynamic is List) {
          parsedWorkouts[day as String] = exercisesDynamic
              .map((exJson) =>
                  RoutineExercise.fromMap(exJson as Map<String, dynamic>))
              .toList();
        }
      });
    }

    int duration = map['durationInWeeks'] as int? ?? 4;

    Timestamp parseTimestamp(dynamic value, {required bool isExpiry}) {
      if (value is Timestamp) {
        return value;
      } else if (value is String) {
        try {
          return Timestamp.fromDate(DateTime.parse(value));
        } catch (e) {
          print("Error parsing timestamp string '$value': $e");
          return isExpiry
              ? Timestamp.fromDate(
                  DateTime.now().add(Duration(days: duration * 7)))
              : Timestamp.now();
        }
      }
      return isExpiry
          ? Timestamp.fromDate(DateTime.now().add(Duration(days: duration * 7)))
          : Timestamp.now();
    }

    return WeeklyRoutine(
      id: map['id'] as String? ?? _uuid.v4(),
      name: map['name'] as String? ?? 'Unnamed Routine',
      dailyWorkouts: parsedWorkouts,
      durationInWeeks: duration,
      generatedAt: parseTimestamp(map['generatedAt'], isExpiry: false),
      expiresAt: parseTimestamp(map['expiresAt'], isExpiry: true),
    );
  }

  // Pour l'enregistrement dans Firestore (avec des vrais Timestamps)
  Map<String, dynamic> toMapForFirestore() {
    return {
      'id': id,
      'name': name,
      'dailyWorkouts': dailyWorkouts.map(
        (key, value) => MapEntry(key, value.map((ex) => ex.toMap()).toList()),
      ),
      'durationInWeeks': durationInWeeks,
      'generatedAt': generatedAt,
      'expiresAt': expiresAt,
    };
  }

  // Pour l'appel à la Cloud Function (Timestamps convertis en String)
  Map<String, dynamic> toMapForCloudFunction() {
    return {
      'id': id,
      'name': name,
      'dailyWorkouts': dailyWorkouts.map(
        (key, value) => MapEntry(key, value.map((ex) => ex.toMap()).toList()),
      ),
      'durationInWeeks': durationInWeeks,
      'generatedAt': generatedAt.toDate().toIso8601String(),
      'expiresAt': expiresAt.toDate().toIso8601String(),
    };
  }

  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  bool isExpired() {
    return expiresAt.toDate().isBefore(DateTime.now());
  }
}
