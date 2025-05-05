// Exemple de routine statique (à placer idéalement dans un fichier séparé plus tard,
// ex: lib/data/static_routine.dart)

import 'package:cloud_firestore/cloud_firestore.dart'; // Pour Timestamp
import 'package:gymgenius/models/routine.dart'; // Assurez-vous que le chemin est correct

// Exemple pour un objectif "Build Muscle", niveau "Intermediate"
final Map<String, List<RoutineExercise>?> staticSampleRoutineData = {
  "monday": [
    // Full Body ou Push
    RoutineExercise(
        name: "Bench Press",
        sets: 3,
        reps: "8-10",
        weightSuggestionKg: "60kg",
        restBetweenSetsSeconds: 90,
        description: "Lie on the bench...",
        gifUrl: "url_to_bench_press.gif",
        targetMuscles: ['chest', 'triceps', 'shoulders']),
    RoutineExercise(
        name: "Overhead Press",
        sets: 3,
        reps: "8-10",
        weightSuggestionKg: "40kg",
        restBetweenSetsSeconds: 75,
        description: "Stand and press...",
        gifUrl: "url_to_ohp.gif",
        targetMuscles: ['shoulders', 'triceps']),
    RoutineExercise(
        name: "Barbell Rows",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "50kg",
        restBetweenSetsSeconds: 75,
        description: "Bend over and pull...",
        gifUrl: "url_to_rows.gif",
        targetMuscles: ['back', 'biceps']),
    RoutineExercise(
        name: "Squats",
        sets: 4,
        reps: "8-10",
        weightSuggestionKg: "80kg",
        restBetweenSetsSeconds: 100,
        description: "Keep your back straight...",
        gifUrl: "url_to_squats.gif",
        targetMuscles: ['quads', 'glutes', 'hamstrings']),
    RoutineExercise(
        name: "Plank",
        sets: 3,
        reps: "60sec",
        weightSuggestionKg: "Bodyweight",
        restBetweenSetsSeconds: 60,
        description: "Hold the position...",
        gifUrl: "url_to_plank.gif",
        targetMuscles: ['core', 'abs']),
  ],
  "tuesday": null, // Repos
  "wednesday": [
    // Full Body ou Pull
    RoutineExercise(
        name: "Deadlifts",
        sets: 3,
        reps: "5",
        weightSuggestionKg: "100kg",
        restBetweenSetsSeconds: 120,
        description: "Lift with your legs...",
        gifUrl: "url_to_deadlift.gif",
        targetMuscles: ['back', 'glutes', 'hamstrings', 'quads']),
    RoutineExercise(
        name: "Pull-ups",
        sets: 3,
        reps: "AMRAP",
        weightSuggestionKg: "Bodyweight",
        restBetweenSetsSeconds: 90,
        description: "Pull your chin over...",
        gifUrl: "url_to_pullup.gif",
        targetMuscles: ['back', 'biceps']),
    RoutineExercise(
        name: "Dumbbell Bench Press",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "20kg each",
        restBetweenSetsSeconds: 75,
        description: "Lie on bench...",
        gifUrl: "url_to_db_bench.gif",
        targetMuscles: ['chest', 'triceps', 'shoulders']),
    RoutineExercise(
        name: "Leg Press",
        sets: 3,
        reps: "12-15",
        weightSuggestionKg: "120kg",
        restBetweenSetsSeconds: 75,
        description: "Push the platform...",
        gifUrl: "url_to_legpress.gif",
        targetMuscles: ['quads', 'glutes']),
    RoutineExercise(
        name: "Bicep Curls",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "12kg",
        restBetweenSetsSeconds: 60,
        description: "Curl the weight...",
        gifUrl: "url_to_curls.gif",
        targetMuscles: ['biceps']),
  ],
  "thursday": null, // Repos
  "friday": [
    // Full Body ou Legs/Push
    RoutineExercise(
        name: "Squats",
        sets: 4,
        reps: "10-12",
        weightSuggestionKg: "75kg",
        restBetweenSetsSeconds: 90,
        description: "Keep your back straight...",
        gifUrl: "url_to_squats.gif",
        targetMuscles: ['quads', 'glutes', 'hamstrings']),
    RoutineExercise(
        name: "Incline Dumbbell Press",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "18kg each",
        restBetweenSetsSeconds: 75,
        description: "On an incline bench...",
        gifUrl: "url_to_incline_db.gif",
        targetMuscles: ['upper chest', 'shoulders', 'triceps']),
    RoutineExercise(
        name: "Romanian Deadlifts",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "60kg",
        restBetweenSetsSeconds: 75,
        description: "Hinge at the hips...",
        gifUrl: "url_to_rdl.gif",
        targetMuscles: ['hamstrings', 'glutes', 'back']),
    RoutineExercise(
        name: "Lateral Raises",
        sets: 3,
        reps: "12-15",
        weightSuggestionKg: "8kg",
        restBetweenSetsSeconds: 60,
        description: "Raise arms to the side...",
        gifUrl: "url_to_lateral.gif",
        targetMuscles: ['shoulders']),
    RoutineExercise(
        name: "Tricep Pushdowns",
        sets: 3,
        reps: "12-15",
        weightSuggestionKg: "Cable Machine",
        restBetweenSetsSeconds: 60,
        description: "Push the bar down...",
        gifUrl: "url_to_pushdown.gif",
        targetMuscles: ['triceps']),
  ],
  "saturday": null, // Repos
  "sunday": null, // Repos
};

// Fonction pour créer l'objet WeeklyRoutine à partir des données statiques
WeeklyRoutine createStaticWeeklyRoutine(String userId) {
  return WeeklyRoutine(
    userId: userId,
    generatedAt: Timestamp.now(),
    dailyWorkouts: staticSampleRoutineData,
  );
}
