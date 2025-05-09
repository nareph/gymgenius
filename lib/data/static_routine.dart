// lib/data/static_routine.dart
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise
// import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp, if used in the commented out function
// import 'package:uuid/uuid.dart'; // For Uuid, if used in the commented out function

// The AI now returns a Map with the parts it generates.
Map<String, dynamic> createStaticAiGeneratedParts({
  required String userId,
  required Map<String, dynamic> onboardingData,
  Map<String, dynamic>?
      previousRoutineData, // The complete old routine (as a Map)
}) {
  // Logic to use onboardingData and previousRoutineData to vary the routine.
  // For example, if the old routine was "Beginner", the new one could be "Intermediate".
  bool makeIntermediate = previousRoutineData != null &&
      (previousRoutineData['name'] as String? ?? '')
          .toLowerCase()
          .contains("beginner");

  String routineName =
      makeIntermediate ? "Intermediate Strength Focus" : "Beginner Full Body";
  int duration = 4; // The AI could also determine this.

  Map<String, List<Map<String, dynamic>>> dailyWorkouts = {
    'monday': [
      RoutineExercise(
              name: makeIntermediate ? "Barbell Squats" : "Goblet Squats",
              sets: 3,
              reps: makeIntermediate ? "5-8" : "8-12",
              weightSuggestionKg: makeIntermediate ? "Moderate" : "Light")
          .toMap(),
      RoutineExercise(
              name: makeIntermediate ? "Bench Press" : "Push-ups",
              sets: 3,
              reps: makeIntermediate ? "5-8" : "AMRAP")
          .toMap(),
      RoutineExercise(
              name: makeIntermediate ? "Barbell Rows" : "Dumbbell Rows",
              sets: 3,
              reps: makeIntermediate ? "5-8" : "10-15 per side")
          .toMap(),
    ],
    'tuesday': [], // Rest day
    'wednesday': [
      RoutineExercise(
              name: makeIntermediate
                  ? "Overhead Press"
                  : "Dumbbell Shoulder Press",
              sets: 3,
              reps: makeIntermediate ? "6-10" : "10-15")
          .toMap(),
      RoutineExercise(
              name: makeIntermediate ? "Pull-ups / Assisted" : "Lat Pulldowns",
              sets: 3,
              reps: makeIntermediate ? "AMRAP" : "8-12")
          .toMap(),
      RoutineExercise(name: "Plank", sets: 3, reps: "30-60s hold").toMap(),
    ],
    'thursday': [], // Rest day
    'friday': [
      RoutineExercise(
              name:
                  makeIntermediate ? "Romanian Deadlifts" : "Bodyweight Lunges",
              sets: 3,
              reps: makeIntermediate ? "8-12" : "10-15 per leg")
          .toMap(),
      RoutineExercise(
              name: makeIntermediate
                  ? "Incline Dumbbell Press"
                  : "Dumbbell Bench Press (if available)",
              sets: 3,
              reps: "8-12")
          .toMap(),
      RoutineExercise(name: "Bicep Curls", sets: 3, reps: "10-15").toMap(),
      RoutineExercise(name: "Tricep Extensions", sets: 3, reps: "10-15")
          .toMap(),
    ],
    'saturday': [], // Optional: Light activity or full rest
    'sunday': [], // Rest day
  };

  return {
    'name': routineName,
    'durationInWeeks': duration,
    'dailyWorkouts': dailyWorkouts,
  };
}


// The old createStaticWeeklyRoutine function is no longer directly used by HomeTabScreen
// but can be kept for testing or other uses if it constructs a WeeklyRoutine object.
// If you intend to use this function, ensure 'Timestamp' from 'cloud_firestore' and 'Uuid' are correctly imported and initialized.
// For example:
// final _uuid = Uuid(); // Needs to be initialized
//
// WeeklyRoutine createStaticWeeklyRoutine(String userId, {Map<String, dynamic>? onboardingData}) {
//   final aiParts = createStaticAiGeneratedParts(userId: userId, onboardingData: onboardingData ?? {});
//   final now = Timestamp.now(); // Requires cloud_firestore import
//   final duration = aiParts['durationInWeeks'] as int;
//   // final _uuid = Uuid(); // Initialize Uuid if not global or already initialized

//   Map<String, List<RoutineExercise>> parsedWorkouts = {};
//    if (aiParts['dailyWorkouts'] is Map) {
//     (aiParts['dailyWorkouts'] as Map).forEach((day, exercisesDynamic) {
//       if (exercisesDynamic is List) {
//         parsedWorkouts[day as String] = exercisesDynamic
//             .map((exMap) => RoutineExercise.fromMap(exMap as Map<String, dynamic>)) // fromMap here
//             .toList();
//       }
//     });
//   }

//   return WeeklyRoutine(
//     id: _uuid.v4(), // Generates an ID for this instance; ensure _uuid is initialized
//     name: aiParts['name'] as String,
//     dailyWorkouts: parsedWorkouts,
//     durationInWeeks: duration,
//     generatedAt: now,
//     expiresAt: Timestamp.fromDate(now.toDate().add(Duration(days: duration * 7))), // Requires cloud_firestore import
//   );
// }