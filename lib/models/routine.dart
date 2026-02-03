import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/utils/type_converter.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

/// Represents a single exercise in a workout routine
///
/// IMPORTANT: This model assumes data has been properly normalized
/// by RoutineValidator. It trusts the input values and does not
/// re-detect or re-parse any properties.
class RoutineExercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final String description;
  final String weightSuggestionKg;
  final int restBetweenSetsSeconds;
  final bool usesWeight;
  final bool isTimed;
  final int? targetDurationSeconds;

  RoutineExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.description,
    required this.weightSuggestionKg,
    required this.restBetweenSetsSeconds,
    required this.usesWeight,
    required this.isTimed,
    this.targetDurationSeconds,
  }) {
    // Validate data consistency (sanity checks only)
    _validateInvariants();
  }

  /// Validates internal invariants
  void _validateInvariants() {
    // If exercise is timed, it must have targetDurationSeconds
    if (isTimed && targetDurationSeconds == null) {
      throw ArgumentError(
        'Timed exercise "$name" must have targetDurationSeconds. '
        'This indicates invalid data that should have been caught by validator.',
      );
    }

    // If exercise is not timed, it should not have targetDurationSeconds
    if (!isTimed && targetDurationSeconds != null) {
      throw ArgumentError(
        'Non-timed exercise "$name" should not have targetDurationSeconds. '
        'This indicates invalid data that should have been caught by validator.',
      );
    }

    // Validate target duration range
    if (targetDurationSeconds != null &&
        (targetDurationSeconds! < 1 || targetDurationSeconds! > 3600)) {
      throw ArgumentError(
        'Invalid targetDurationSeconds: $targetDurationSeconds for "$name". '
        'Must be between 1 and 3600 seconds.',
      );
    }

    // Validate sets range
    if (sets < 1 || sets > 20) {
      throw ArgumentError(
        'Invalid sets: $sets for "$name". Must be between 1 and 20.',
      );
    }

    // Validate rest time
    if (restBetweenSetsSeconds < 0 || restBetweenSetsSeconds > 600) {
      throw ArgumentError(
        'Invalid restBetweenSetsSeconds: $restBetweenSetsSeconds for "$name". '
        'Must be between 0 and 600 seconds.',
      );
    }
  }

  /// Creates exercise from already-normalized map
  ///
  /// ASSUMES: Data has been validated by RoutineValidator
  /// TRUSTS: All properties are correct and consistent
  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String? ?? 'Unknown Exercise',
      sets: (map['sets'] as num?)?.toInt() ?? 3,
      reps: (map['reps'] ?? '8-12').toString(),
      description: map['description'] as String? ?? 'No description',
      weightSuggestionKg:
          (map['weightSuggestionKg'] ?? 'Bodyweight').toString(),
      restBetweenSetsSeconds:
          (map['restBetweenSetsSeconds'] as num?)?.toInt() ?? 60,
      usesWeight: map['usesWeight'] as bool? ?? false,
      isTimed: map['isTimed'] as bool? ?? false, // Trust validator's value
      targetDurationSeconds: map['isTimed'] as bool == true
          ? (map['targetDurationSeconds'] as num?)?.toInt()
          : null,
    );
  }

  /// Converts to map for storage
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
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
        'targetDurationSeconds': targetDurationSeconds!,
    };
  }

  /// Creates a copy with updated values
  RoutineExercise copyWith({
    String? id,
    String? name,
    int? sets,
    String? reps,
    String? description,
    String? weightSuggestionKg,
    int? restBetweenSetsSeconds,
    bool? usesWeight,
    bool? isTimed,
    int? targetDurationSeconds,
  }) {
    return RoutineExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      description: description ?? this.description,
      weightSuggestionKg: weightSuggestionKg ?? this.weightSuggestionKg,
      restBetweenSetsSeconds:
          restBetweenSetsSeconds ?? this.restBetweenSetsSeconds,
      usesWeight: usesWeight ?? this.usesWeight,
      isTimed: isTimed ?? this.isTimed,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
    );
  }

  /// Gets a human-readable description of the exercise
  String get displayDescription {
    if (isTimed) {
      return '$sets × ${targetDurationSeconds}s $name';
    } else if (usesWeight) {
      return '$sets × $reps $name (${weightSuggestionKg}kg)';
    } else {
      return '$sets × $reps $name';
    }
  }

  /// Checks if this is a bodyweight exercise
  bool get isBodyweight => !usesWeight;

  @override
  String toString() {
    return 'RoutineExercise('
        'name: "$name", '
        'sets: $sets, '
        'reps: "$reps", '
        'isTimed: $isTimed'
        '${isTimed ? ", duration: ${targetDurationSeconds}s" : ""}'
        ')';
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
  int get hashCode => Object.hash(
        id,
        name,
        sets,
        reps,
        weightSuggestionKg,
        restBetweenSetsSeconds,
        description,
        usesWeight,
        isTimed,
        targetDurationSeconds,
      );
}

/// Represents a complete weekly workout routine with daily workouts
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

  /// Factory constructor to create WeeklyRoutine from a map
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

  /// Convert WeeklyRoutine to a map for local storage
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

  /// Create a copy of the routine with updated values
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

  /// For Firestore compatibility (keep for future use)
  Map<String, dynamic> toMapForFirestore() {
    return toMap();
  }

  /// For AI service compatibility
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

  /// Days of the week constants
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  /// Check if the routine is expired
  bool isExpired() {
    return expiresAt.isBefore(DateTime.now());
  }

  /// Get exercises for a specific day
  List<RoutineExercise> getExercisesForDay(String day) {
    return dailyWorkouts[day.toLowerCase()] ?? [];
  }

  /// Check if a specific day has workouts
  bool hasWorkoutForDay(String day) {
    final exercises = getExercisesForDay(day);
    return exercises.isNotEmpty;
  }
}
