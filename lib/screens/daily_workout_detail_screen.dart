// lib/screens/daily_workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:provider/provider.dart';

class DailyWorkoutDetailScreen extends StatelessWidget {
  final String dayTitle; // ex: "Monday Workout"
  final List<RoutineExercise> exercises;
  // final String? routineName; // Optionnel, pour passer au WorkoutSessionManager

  const DailyWorkoutDetailScreen({
    super.key,
    required this.dayTitle,
    required this.exercises,
    // this.routineName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(dayTitle),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      body: Column(
        children: [
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Text(
                    "No exercises scheduled for this day.",
                    style: theme.textTheme.titleMedium,
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(exercise.name,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            "${exercise.sets} sets of ${exercise.reps}"
                            "${exercise.weightSuggestionKg != 'N/A' && exercise.weightSuggestionKg.isNotEmpty ? ' @ ${exercise.weightSuggestionKg}' : ''}"
                            "\nRest: ${exercise.restBetweenSetsSeconds}s",
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                          isThreeLine: true,
                          // onTap: () {
                          //   // Potentiellement afficher plus de détails sur l'exercice si cliqué
                          // },
                        ),
                      );
                    },
                  ),
          ),
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text("Start Workout"),
                onPressed: () {
                  if (workoutManager.isWorkoutActive) {
                    // Gérer le cas où un workout est déjà actif
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: const Text("Workout in Progress"),
                              content: const Text(
                                  "Another workout session is already active. Do you want to end it and start this new one?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      // Forcer le démarrage du nouveau workout.
                                      // Le manager.endWorkout() est appelé implicitement par forceStartNewWorkout si une session était active.
                                      // Les logs de l'ancienne session seront sauvegardés (ou pas, selon la logique de endWorkout).
                                      workoutManager.forceStartNewWorkout(
                                          exercises,
                                          workoutName: dayTitle);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ActiveWorkoutSessionScreen()));
                                    },
                                    child: const Text("End & Start New")),
                              ],
                            ));
                  } else {
                    // Nom du workout = titre du jour (ex: "Monday Workout")
                    // Le nom de la routine globale (ex: "Beginner Strength") pourrait être passé aussi si besoin.
                    workoutManager.startWorkout(exercises,
                        workoutName: dayTitle);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ActiveWorkoutSessionScreen()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
