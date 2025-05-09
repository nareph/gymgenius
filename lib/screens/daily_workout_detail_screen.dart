// lib/screens/daily_workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart'; // To start a workout session
import 'package:gymgenius/screens/active_workout_session_screen.dart'; // To navigate to when workout starts
import 'package:provider/provider.dart'; // To access WorkoutSessionManager

class DailyWorkoutDetailScreen extends StatelessWidget {
  final String dayTitle; // e.g., "Monday Workout"
  final List<RoutineExercise> exercises;
  // final String? routineName; // Optional: Could be passed to WorkoutSessionManager if needed for naming the session.

  const DailyWorkoutDetailScreen({
    super.key,
    required this.dayTitle,
    required this.exercises,
    // this.routineName, // If you decide to use the overall routine name for the session
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // Access WorkoutSessionManager without listening, as we only dispatch actions.
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(dayTitle),
        // Consider using theme's appBarTheme for consistent background or elevation.
        // backgroundColor: colorScheme.surfaceContainerHighest, // Or from theme
        elevation: 1.0, // Subtle elevation
      ),
      body: Column(
        children: [
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                    // For better centering and icon
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
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
                    padding: const EdgeInsets.all(12.0), // Consistent padding
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        elevation: 1.5, // Subtle elevation for cards
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 4.0),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)), // Rounded corners
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
                            style: textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    FontWeight.w600), // Using titleSmall
                          ),
                          subtitle: Text(
                            "${exercise.sets} sets of ${exercise.reps}"
                            "${exercise.weightSuggestionKg.isNotEmpty && exercise.weightSuggestionKg != 'N/A' ? ' @ ${exercise.weightSuggestionKg}' : ''}"
                            "\nRest: ${exercise.restBetweenSetsSeconds}s between sets", // Added "between sets"
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.3), // Using bodySmall
                          ),
                          isThreeLine: true,
                          // onTap: () {
                          //   // Potentially show more details about the exercise if clicked
                          //   // e.g., show a dialog with exercise.description or a video link
                          // },
                        ),
                      );
                    },
                  ),
          ),
          if (exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 24.0), // Added bottom padding
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                label: const Text("Start This Workout"),
                onPressed: () {
                  if (workoutManager.isWorkoutActive) {
                    // Handle the case where a workout is already active
                    showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                              title: const Text("Workout Already in Progress"),
                              content: const Text(
                                  "Another workout session is currently active. Would you like to end it and start this new one?"),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogCtx).pop(),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogCtx)
                                          .pop(); // Close the dialog
                                      // Force start the new workout.
                                      // WorkoutSessionManager.forceStartNewWorkout will handle ending the previous session.
                                      // The log for the old session should be saved by the manager's endWorkout logic if implemented.
                                      workoutManager.forceStartNewWorkout(
                                          exercises,
                                          workoutName: dayTitle);

                                      // Navigate to the active session screen, replacing the current screen
                                      // to prevent going back to the detail view of the now-replaced workout.
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ActiveWorkoutSessionScreen()));
                                    },
                                    child: Text("End & Start New",
                                        style: TextStyle(
                                            color: theme.colorScheme.error))),
                              ],
                            ));
                  } else {
                    // Start a new workout session
                    // The workout name is the day's title (e.g., "Monday Workout")
                    workoutManager.startWorkout(exercises,
                        workoutName: dayTitle);
                    // Navigate to the active session screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ActiveWorkoutSessionScreen()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 52), // Taller button
                  textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight:
                          FontWeight.bold), // Use labelLarge for button text
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
