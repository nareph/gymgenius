// lib/screens/daily_workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:provider/provider.dart';

class DailyWorkoutDetailScreen extends StatelessWidget {
  final String dayTitle;
  final List<RoutineExercise> exercises;
  final String? routineIdForLog;
  final String dayKeyForLog;

  const DailyWorkoutDetailScreen({
    super.key,
    required this.dayTitle,
    required this.exercises,
    this.routineIdForLog,
    required this.dayKeyForLog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);
    final String sessionName = dayTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(dayTitle),
        elevation: 1.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant
                              .withAlpha((0.6 * 255).round())),
                      const SizedBox(height: 16),
                      Text(
                        "No exercises scheduled for this day.",
                        style: textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 4.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(
                            exercise.name,
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "${exercise.sets} sets of ${exercise.reps}"
                            "${exercise.weightSuggestionKg.isNotEmpty && exercise.weightSuggestionKg.toLowerCase() != 'n/a' && exercise.weightSuggestionKg.toLowerCase() != 'bodyweight' ? ' @ ${exercise.weightSuggestionKg}kg' : (exercise.weightSuggestionKg.toLowerCase() == 'bodyweight' ? ' (Bodyweight)' : '')}"
                            "\nRest: ${exercise.restBetweenSetsSeconds}s between sets",
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.3),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                label: const Text("Start This Workout"),
                onPressed: () {
                  if (workoutManager.isWorkoutActive) {
                    showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                              title: const Text("Workout in Progress"),
                              content: const Text(
                                  "A workout session is currently active. What would you like to do?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ActiveWorkoutSessionScreen()),
                                    );
                                  },
                                  child: Text("Resume Current",
                                      style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop();
                                    workoutManager.forceStartNewWorkout(
                                      exercises,
                                      workoutName: sessionName,
                                      routineId: routineIdForLog,
                                      dayKey: dayKeyForLog,
                                    );
                                    if (workoutManager.isWorkoutActive) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ActiveWorkoutSessionScreen()));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: const Text(
                                                  "Failed to start the new workout."),
                                              backgroundColor:
                                                  theme.colorScheme.error));
                                    }
                                  },
                                  child: Text("End & Start New",
                                      style: TextStyle(
                                          color: theme.colorScheme.error)),
                                ),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogCtx).pop(),
                                    child: const Text("Cancel")),
                              ],
                            ));
                  } else {
                    bool started = workoutManager.startWorkoutIfNoSession(
                      exercises,
                      workoutName: sessionName,
                      routineId: routineIdForLog,
                      dayKey: dayKeyForLog,
                    );
                    if (started) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ActiveWorkoutSessionScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              "Failed to start workout. An unexpected error occurred."),
                          backgroundColor: theme.colorScheme.error));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  textStyle: textTheme.labelLarge
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
