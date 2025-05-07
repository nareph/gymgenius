// lib/data/static_routine.dart
import 'package:gymgenius/models/routine.dart'; // Pour RoutineExercise
// import 'package:uuid/uuid.dart'; // uuid est déjà global dans routine.dart si vous le gardez là

// var uuid = Uuid(); // Inutile si déjà global dans routine.dart

// L'IA retourne maintenant un Map avec les parties qu'elle génère
Map<String, dynamic> createStaticAiGeneratedParts({
  required String userId,
  required Map<String, dynamic> onboardingData,
  Map<String, dynamic>?
      previousRoutineData, // L'ancienne routine complète (en Map)
}) {
  // Logique pour utiliser onboardingData et previousRoutineData pour varier la routine
  // Par exemple, si l'ancienne routine était "Beginner", la nouvelle pourrait être "Intermediate"
  bool makeIntermediate = previousRoutineData != null &&
      (previousRoutineData['name'] as String? ?? '')
          .toLowerCase()
          .contains("beginner");

  String routineName =
      makeIntermediate ? "Intermediate Strength Focus" : "Beginner Full Body";
  int duration = 4; // L'IA pourrait aussi déterminer cela

  // Construire les dailyWorkouts comme Map<String, List<Map<String, dynamic>>>
  // Chaque RoutineExercise est converti en Map via .toMap()
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
    'dailyWorkouts':
        dailyWorkouts, // Déjà une Map<String, List<Map<String, dynamic>>>
  };
}


// L'ancienne fonction createStaticWeeklyRoutine n'est plus directement utilisée par HomeTabScreen
// mais peut être conservée pour des tests ou d'autres usages si elle construit un objet WeeklyRoutine.
// WeeklyRoutine createStaticWeeklyRoutine(String userId, {Map<String, dynamic>? onboardingData}) {
//   final aiParts = createStaticAiGeneratedParts(userId: userId, onboardingData: onboardingData ?? {});
//   final now = Timestamp.now();
//   final duration = aiParts['durationInWeeks'] as int;

//   Map<String, List<RoutineExercise>> parsedWorkouts = {};
//    if (aiParts['dailyWorkouts'] is Map) {
//     (aiParts['dailyWorkouts'] as Map).forEach((day, exercisesDynamic) {
//       if (exercisesDynamic is List) {
//         parsedWorkouts[day as String] = exercisesDynamic
//             .map((exMap) => RoutineExercise.fromMap(exMap as Map<String, dynamic>)) // fromMap ici
//             .toList();
//       }
//     });
//   }

//   return WeeklyRoutine(
//     id: uuid.v4(), // Génère un ID pour cette instance
//     name: aiParts['name'] as String,
//     dailyWorkouts: parsedWorkouts,
//     durationInWeeks: duration,
//     generatedAt: now,
//     expiresAt: Timestamp.fromDate(now.toDate().add(Duration(days: duration * 7))),
//   );
// }