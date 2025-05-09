// lib/models/routine.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Instance of Uuid for generating unique IDs.
// Consider making it a top-level private final variable (e.g., final _uuid = Uuid();)
// or instantiating Uuid() directly where needed if preferred.
var uuid = Uuid();

class RoutineExercise {
  final String
      id; // Unique ID for the exercise WITHIN this specific routine instance
  final String name;
  final int sets;
  final String
      reps; // Can be a range (e.g., "8-12") or specific (e.g., "AMRAP")
  final String weightSuggestionKg;
  final int restBetweenSetsSeconds;
  final String description;

  RoutineExercise({
    String? id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weightSuggestionKg = 'N/A', // Default value if not provided
    this.restBetweenSetsSeconds = 60, // Default value if not provided
    this.description = '', // Default value if not provided
  }) : id = id ?? uuid.v4(); // Generates an ID if one is not provided

  // Factory constructor to create a RoutineExercise from a map (e.g., from Firestore)
  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'] as String? ??
          uuid.v4(), // Ensures an ID exists, generates if null
      name: map['name'] as String? ?? 'Unknown Exercise',
      sets: map['sets'] as int? ?? 3,
      reps: map['reps'] as String? ?? '8-12',
      weightSuggestionKg: map['weightSuggestionKg'] as String? ?? 'N/A',
      restBetweenSetsSeconds: map['restBetweenSetsSeconds'] as int? ?? 60,
      description: map['description'] as String? ?? '',
    );
  }

  // Converts the RoutineExercise object to a map, suitable for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': weightSuggestionKg,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'description': description,
    };
  }

  // Override for object comparison, useful in collections, state management (e.g., Provider, Set)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutineExercise &&
        other.id == id && // Primary comparison by ID if it's reliably unique
        other.name == name &&
        other.sets == sets &&
        other.reps == reps &&
        other.weightSuggestionKg == weightSuggestionKg &&
        other.restBetweenSetsSeconds == restBetweenSetsSeconds &&
        other.description == description;
  }

  @override
  int get hashCode {
    // Using the ID for the hashcode is often sufficient if the ID is unique and immutable.
    // Combining with other fields if ID might not be unique initially or for more distribution.
    return id.hashCode ^
        name.hashCode ^
        sets.hashCode ^
        reps.hashCode ^
        weightSuggestionKg.hashCode ^
        restBetweenSetsSeconds.hashCode ^
        description.hashCode;
  }
}

class WeeklyRoutine {
  final String id; // Unique ID for this specific routine instance
  final String name;
  final Map<String, List<RoutineExercise>>
      dailyWorkouts; // Key: day (e.g., "monday"), Value: list of exercises
  final int durationInWeeks;
  final Timestamp
      generatedAt; // Firestore Timestamp: when the routine was generated
  final Timestamp
      expiresAt; // Firestore Timestamp: when the routine is considered ended or needs refresh
  // final Map<String, dynamic>? onboardingSnapshot; // Optional: snapshot of onboarding data for audit/reference (currently commented out)

  WeeklyRoutine({
    required this.id,
    required this.name,
    required this.dailyWorkouts,
    required this.durationInWeeks,
    required this.generatedAt,
    required this.expiresAt,
    // this.onboardingSnapshot,
  });

  // Factory constructor to create a WeeklyRoutine from a map (e.g., from Firestore)
  factory WeeklyRoutine.fromMap(Map<String, dynamic> map) {
    Map<String, List<RoutineExercise>> parsedWorkouts = {};
    if (map['dailyWorkouts'] is Map) {
      (map['dailyWorkouts'] as Map).forEach((day, exercisesDynamic) {
        if (exercisesDynamic is List) {
          // Ensure day is a String, though keys in Firestore maps are always Strings
          parsedWorkouts[day as String] = exercisesDynamic
              .map((exJson) =>
                  RoutineExercise.fromMap(exJson as Map<String, dynamic>))
              .toList();
        }
      });
    }

    int duration =
        map['durationInWeeks'] as int? ?? 4; // Default duration if null

    return WeeklyRoutine(
      id: map['id'] as String? ??
          uuid.v4(), // Ensures an ID exists, generates if null
      name: map['name'] as String? ?? 'Unnamed Routine',
      dailyWorkouts: parsedWorkouts,
      durationInWeeks: duration,
      generatedAt: map['generatedAt'] as Timestamp? ??
          Timestamp.now(), // Fallback to current time
      expiresAt: map['expiresAt'] as Timestamp? ??
          Timestamp.fromDate(DateTime.now()
              .add(Duration(days: duration * 7))), // Fallback calculation
      // onboardingSnapshot: map['onboardingSnapshot'] as Map<String, dynamic>?,
    );
  }

  // Method to convert the WeeklyRoutine object to a map, suitable for storing in Firestore.
  // This might not be directly used if constructing the map manually for saving,
  // but it's a good utility to have.
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
      // 'onboardingSnapshot': onboardingSnapshot, // Include if re-enabled
    };
  }

  // Static list of day names, useful for iteration or ordered display.
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  // Note on Timestamps:
  // Fields like 'generatedAt' and 'expiresAt' are stored as Timestamps in Firestore.
  // When fetched, they are received as Timestamp objects.
  // In the UI layer, these Timestamps will typically be converted to DateTime objects
  // for display or other date-time manipulations (e.g., using timestamp.toDate()).
}
