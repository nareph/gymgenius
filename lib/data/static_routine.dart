// lib/data/static_routine.dart

// Pas besoin d'importer Timestamp ici car il n'est plus défini directement
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymgenius/models/routine.dart'; // Assurez-vous que le chemin est correct

// Définition des données statiques en utilisant le modèle RoutineExercise
// Cette structure de données reste la même que celle que vous aviez.
final Map<String, List<RoutineExercise>?> staticSampleRoutineData = {
  "monday": [
    RoutineExercise(
        name: "Bench Press",
        sets: 3,
        reps: "8-10",
        weightSuggestionKg: "60kg",
        restBetweenSetsSeconds: 90,
        description:
            "Lie flat on a bench, lower the barbell to your chest, and push it back up."),
    RoutineExercise(
        name: "Overhead Press",
        sets: 3,
        reps: "8-10",
        weightSuggestionKg: "40kg",
        restBetweenSetsSeconds: 75,
        description: "Stand tall, press the barbell straight up overhead."),
    RoutineExercise(
        name: "Barbell Rows",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "50kg",
        restBetweenSetsSeconds: 75,
        description:
            "Bend over with a straight back, pull the barbell towards your lower chest."),
    RoutineExercise(
        name: "Squats",
        sets: 4,
        reps: "8-10",
        weightSuggestionKg: "80kg",
        restBetweenSetsSeconds: 100,
        description:
            "Keep your back straight, lower your hips as if sitting in a chair."),
    RoutineExercise(
        name: "Plank",
        sets: 3,
        reps: "60sec",
        weightSuggestionKg: "Bodyweight",
        restBetweenSetsSeconds: 60,
        description:
            "Hold a straight line from head to heels, engaging your core."),
  ],
  "tuesday": null, // Repos
  "wednesday": [
    RoutineExercise(
        name: "Deadlifts",
        sets: 1,
        reps: "5",
        weightSuggestionKg: "100kg",
        restBetweenSetsSeconds: 120,
        description:
            "Keep back straight, lift the bar by extending hips and knees."),
    RoutineExercise(
        name: "Pull-ups/Lat Pulldowns",
        sets: 3,
        reps: "AMRAP/10-12",
        weightSuggestionKg: "Bodyweight/Machine",
        restBetweenSetsSeconds: 90,
        description:
            "Pull your body up (pull-up) or pull the bar down (lat pulldown)."),
    RoutineExercise(
        name: "Dumbbell Bench Press",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "20kg each",
        restBetweenSetsSeconds: 75,
        description: "Lie on bench, lower dumbbells, press up."),
    RoutineExercise(
        name: "Leg Press",
        sets: 3,
        reps: "12-15",
        weightSuggestionKg: "120kg",
        restBetweenSetsSeconds: 75,
        description:
            "Sit in the machine, push the platform away with your feet."),
    RoutineExercise(
        name: "Bicep Curls",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "12kg",
        restBetweenSetsSeconds: 60,
        description:
            "Curl the weight up towards your shoulders, keeping elbows stable."),
  ],
  "thursday": null, // Repos
  "friday": [
    RoutineExercise(
        name: "Squats",
        sets: 4,
        reps: "10-12",
        weightSuggestionKg: "75kg",
        restBetweenSetsSeconds: 90,
        description: "Keep your back straight, lower your hips."),
    RoutineExercise(
        name: "Incline Dumbbell Press",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "18kg each",
        restBetweenSetsSeconds: 75,
        description: "Lie on an incline bench, press dumbbells up."),
    RoutineExercise(
        name: "Romanian Deadlifts",
        sets: 3,
        reps: "10-12",
        weightSuggestionKg: "60kg",
        restBetweenSetsSeconds: 75,
        description:
            "Hinge at the hips, keeping legs mostly straight, lower the bar."),
    RoutineExercise(
        name: "Lateral Raises",
        sets: 3,
        reps: "12-15",
        weightSuggestionKg: "8kg",
        restBetweenSetsSeconds: 60,
        description:
            "Raise dumbbells out to the sides until parallel to the floor."),
    RoutineExercise(
        name: "Tricep Pushdowns",
        sets: 3,
        reps: "12-15",
        weightSuggestionKg: "Machine Setting 4",
        restBetweenSetsSeconds: 60,
        description: "Use a cable machine, push the bar/rope down."),
  ],
  "saturday": null, // Repos
  "sunday": null, // Repos
};

// Fonction pour créer l'objet WeeklyRoutine à partir des données statiques.
// Notez que 'createdAt' n'est pas défini ici. Il sera ajouté par
// FieldValue.serverTimestamp() lors de la sauvegarde dans Firestore.
WeeklyRoutine createStaticWeeklyRoutine(String userId) {
  return WeeklyRoutine(
    userId: userId,
    name:
        "Starter Strength Plan", // Vous pouvez changer le nom ici si vous le souhaitez
    durationInWeeks: 8, // Durée par défaut pour cette routine statique
    // createdAt est omis, car il sera géré par FieldValue.serverTimestamp()
    // lors de la sauvegarde initiale dans Firestore.
    dailyWorkouts: staticSampleRoutineData,
  );
}
