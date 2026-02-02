// lib/models/routine.dart
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/utils/type_converter.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class RoutineExercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final String weightSuggestionKg;
  final int restBetweenSetsSeconds;
  final String description;
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
    this.description = '',
    this.usesWeight = true,
    this.isTimed = false,
    this.targetDurationSeconds,
  }) : id = id ?? _uuid.v4();

  // Factory constructor to create RoutineExercise from a map
  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    // Use TypeConverter to ensure type safety
    final safeMap = TypeConverter.toSafeMap(map);

    return RoutineExercise(
      id: safeMap['id'] is String ? safeMap['id'] as String : _uuid.v4(),
      name: safeMap['name'] is String
          ? safeMap['name'] as String
          : 'Unknown Exercise',
      sets: safeMap['sets'] is int ? safeMap['sets'] as int : 3,
      reps: safeMap['reps'] is String ? safeMap['reps'] as String : '8-12',
      weightSuggestionKg: safeMap['weightSuggestionKg'] is String
          ? safeMap['weightSuggestionKg'] as String
          : 'N/A',
      restBetweenSetsSeconds: safeMap['restBetweenSetsSeconds'] is int
          ? safeMap['restBetweenSetsSeconds'] as int
          : 60,
      description: safeMap['description'] is String
          ? safeMap['description'] as String
          : '',
      usesWeight:
          safeMap['usesWeight'] is bool ? safeMap['usesWeight'] as bool : true,
      isTimed: safeMap['isTimed'] is bool ? safeMap['isTimed'] as bool : false,
      targetDurationSeconds: safeMap['targetDurationSeconds'] is int
          ? safeMap['targetDurationSeconds'] as int
          : null,
    );
  }

  // Convert RoutineExercise to a map
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
  final DateTime generatedAt;
  final DateTime expiresAt;

  WeeklyRoutine({
    required this.id,
    required this.name,
    required this.dailyWorkouts,
    required this.durationInWeeks,
    required this.generatedAt,
    required this.expiresAt,
  });

  // Factory constructor to create WeeklyRoutine from a map
  factory WeeklyRoutine.fromMap(Map<String, dynamic> map) {
    // Convert the entire map to be type-safe using TypeConverter
    final safeMap = TypeConverter.toSafeMap(map);

    Map<String, List<RoutineExercise>> parsedWorkouts = {};

    if (safeMap['dailyWorkouts'] is Map) {
      // Iterate through each day in the workouts
      (safeMap['dailyWorkouts'] as Map).forEach((dayKey, exercisesDynamic) {
        if (exercisesDynamic is List) {
          // Convert day key to string safely
          final dayString = dayKey.toString();

          // Parse each exercise using TypeConverter
          final exercisesList = exercisesDynamic.map((exJson) {
            // Convert each exercise JSON to a safe map
            final safeExMap = TypeConverter.toSafeMap(exJson);
            return RoutineExercise.fromMap(safeExMap);
          }).toList();

          parsedWorkouts[dayString] = exercisesList.cast<RoutineExercise>();
        }
      });
    }

    // Parse duration safely
    int duration = 4;
    if (safeMap['durationInWeeks'] is int) {
      duration = safeMap['durationInWeeks'] as int;
    } else if (safeMap['durationInWeeks'] is String) {
      duration = int.tryParse(safeMap['durationInWeeks'] as String) ?? 4;
    }

    // Helper function to parse datetime safely
    DateTime parseDateTime(dynamic value, {required bool isExpiry}) {
      if (value is DateTime) {
        return value;
      } else if (value is int) {
        // Milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          Log.debug("Error parsing datetime string '$value': $e");
          return isExpiry
              ? DateTime.now().add(Duration(days: duration * 7))
              : DateTime.now();
        }
      }
      // Default fallback
      return isExpiry
          ? DateTime.now().add(Duration(days: duration * 7))
          : DateTime.now();
    }

    return WeeklyRoutine(
      id: safeMap['id'] is String ? safeMap['id'] as String : _uuid.v4(),
      name: safeMap['name'] is String
          ? safeMap['name'] as String
          : 'Unnamed Routine',
      dailyWorkouts: parsedWorkouts,
      durationInWeeks: duration,
      generatedAt: parseDateTime(safeMap['generatedAt'], isExpiry: false),
      expiresAt: parseDateTime(safeMap['expiresAt'], isExpiry: true),
    );
  }

  // Convert WeeklyRoutine to a map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dailyWorkouts': dailyWorkouts.map(
        (key, value) => MapEntry(key, value.map((ex) => ex.toMap()).toList()),
      ),
      'durationInWeeks': durationInWeeks,
      'generatedAt': generatedAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
  }

  WeeklyRoutine copyWith({
    String? id,
    String? name,
    Map<String, List<RoutineExercise>>? dailyWorkouts,
    int? durationInWeeks,
    DateTime? generatedAt,
    DateTime? expiresAt,
  }) {
    return WeeklyRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      dailyWorkouts: dailyWorkouts ?? Map.from(this.dailyWorkouts),
      durationInWeeks: durationInWeeks ?? this.durationInWeeks,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // For Firestore compatibility (keep for future use)
  Map<String, dynamic> toMapForFirestore() {
    return toMap();
  }

  // For AI service compatibility
  Map<String, dynamic> toMapForCloudFunction() {
    return {
      'id': id,
      'name': name,
      'dailyWorkouts': dailyWorkouts.map(
        (key, value) => MapEntry(key, value.map((ex) => ex.toMap()).toList()),
      ),
      'durationInWeeks': durationInWeeks,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  // Days of the week constants
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  // Check if the routine is expired
  bool isExpired() {
    return expiresAt.isBefore(DateTime.now());
  }
}
