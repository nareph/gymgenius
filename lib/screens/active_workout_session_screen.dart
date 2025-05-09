// lib/screens/active_workout_session_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart'; // For WorkoutSessionManager, LoggedExerciseData
import 'package:gymgenius/screens/exercise_logging_screen.dart'; // Screen to log sets for an exercise
import 'package:provider/provider.dart'; // For consuming WorkoutSessionManager

class ActiveWorkoutSessionScreen extends StatelessWidget {
  const ActiveWorkoutSessionScreen({super.key});

  // Handles the process of ending the current workout session and saving the log.
  Future<void> _handleEndWorkout(
      BuildContext context, WorkoutSessionManager manager) async {
    print(
        "ActiveWorkoutScreen _handleEndWorkout: Initiating end workout process. Manager active before endWorkout(): ${manager.isWorkoutActive}");

    final scaffoldMessenger = ScaffoldMessenger.of(
        context); // Capture ScaffoldMessenger before async operations
    final navigator = Navigator.of(context); // Capture Navigator

    Map<String, dynamic>? workoutLogPayload = manager.endWorkout();
    // After manager.endWorkout(), manager.isWorkoutActive is now false.
    // The Consumer<WorkoutSessionManager> in build() will react to this change.

    if (workoutLogPayload == null) {
      print(
          "ActiveWorkoutScreen _handleEndWorkout: manager.endWorkout() returned null. No log to save.");
      return; // Nothing to save
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(
          "ActiveWorkoutScreen _handleEndWorkout: Error - Current user is null. Workout log cannot be saved.");
      // Check if the captured ScaffoldMessenger's context is still valid (widget is mounted)
      if (scaffoldMessenger.context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text("Error: Not logged in. Workout not saved."),
            backgroundColor: Theme.of(scaffoldMessenger.context)
                .colorScheme
                .error, // Use theme color
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Enrich payload with user ID and server timestamp
    workoutLogPayload['userId'] = currentUser.uid;
    workoutLogPayload['savedAt'] = FieldValue.serverTimestamp();

    print(
        "ActiveWorkoutScreen _handleEndWorkout: Workout log data prepared: $workoutLogPayload");

    try {
      await FirebaseFirestore.instance
          .collection('workout_logs')
          .add(workoutLogPayload);
      print(
          "ActiveWorkoutScreen _handleEndWorkout: Workout log saved successfully to Firestore.");

      if (scaffoldMessenger.context.mounted) {
        // Check mount status AFTER await
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text("Workout session saved successfully!"),
            backgroundColor: Colors.green.shade700, // Consistent success color
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print(
            "ActiveWorkoutScreen _handleEndWorkout: ScaffoldMessenger not mounted after successful save. SnackBar not shown.");
      }
    } catch (e, s) {
      print(
          "ActiveWorkoutScreen _handleEndWorkout: Error saving workout log to Firestore: $e\n$s");
      if (scaffoldMessenger.context.mounted) {
        // Check mount status AFTER await
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Failed to save workout: ${e.toString()}"),
            backgroundColor:
                Theme.of(scaffoldMessenger.context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print(
            "ActiveWorkoutScreen _handleEndWorkout: ScaffoldMessenger not mounted after save error. SnackBar not shown.");
      }
    }
    // Navigation is handled by the Consumer reacting to !manager.isWorkoutActive
  }

  // Navigates to the ExerciseLoggingScreen for a specific exercise.
  void _navigateToExerciseLogging(BuildContext context,
      WorkoutSessionManager manager, int exerciseIndexInList) {
    // Select the exercise in the manager. This sets manager.currentExerciseIndex.
    bool success = manager.selectExercise(exerciseIndexInList);
    if (!success) {
      print(
          "ActiveWorkoutScreen _navigateToExerciseLogging: Error - manager.selectExercise failed for index $exerciseIndexInList.");
      return;
    }

    final RoutineExercise? exerciseToLog = manager.currentExercise;

    if (exerciseToLog == null) {
      print(
          "ActiveWorkoutScreen _navigateToExerciseLogging: Error - manager.currentExercise is null after select for index $exerciseIndexInList.");
      return;
    }
    print(
        "ActiveWorkoutScreen _navigateToExerciseLogging: Navigating to ELS for ${exerciseToLog.name} (index $exerciseIndexInList). Manager's currentSetIndex for this exercise: ${manager.currentSetIndexForLogging}");

    // This `context` is valid at the time of the call.
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
            name: "/exercise_logging"), // For route observation/debugging
        builder: (_) => ExerciseLoggingScreen(
          // ExerciseLoggingScreen will use the same WorkoutSessionManager instance via Provider
          exercise: exerciseToLog, // Pass the specific exercise to log
          onExerciseCompleted: () {
            // Callback (optional, ELS might directly update manager)
            print(
                "ActiveWorkoutScreen: ExerciseLoggingScreen onExerciseCompleted callback received for ${exerciseToLog.name}.");
            // The manager should be updated by ExerciseLoggingScreen itself.
            // This callback is mostly for logging or if AWS needs to react specifically.
          },
        ),
      ),
    ).then((_) {
      // This block executes after ExerciseLoggingScreen is popped.
      // The original `context` of this method is not directly used here.
      // We interact primarily with the `manager` which is a ChangeNotifier.
      final String currentExerciseNameForLog = manager.currentExercise?.name ??
          manager.currentLoggedExerciseData?.originalExercise.name ??
          'unknown (manager state after pop)';
      print(
          "ActiveWorkoutScreen .then() after ELS pop. ELS was for (approx): $currentExerciseNameForLog.");
      print(
          "ActiveWorkoutScreen .then(): Manager state - isWorkoutActive: ${manager.isWorkoutActive}, currentExIndex: ${manager.currentExerciseIndex}, currentExName: ${manager.currentExercise?.name}");

      if (manager.isWorkoutActive) {
        // ExerciseLoggingScreen should have updated the completion status of the exercise.
        // Now, try to move to the next available exercise.
        print(
            "ActiveWorkoutScreen .then(): Attempting manager.moveToNextExercise() from index ${manager.currentExerciseIndex}");
        bool moved = manager.moveToNextExercise();

        if (allExercisesNowEffectivelyCompleted(manager)) {
          print(
              "ActiveWorkoutScreen .then(): All exercises confirmed completed after ELS pop and moveToNext attempt.");
          // UI might update to show "Workout Complete" message or enable "End Workout" more prominently.
        } else if (moved) {
          print(
              "ActiveWorkoutScreen .then(): Successfully moved to next exercise: ${manager.currentExercise?.name}");
        } else {
          // Did not move. Could be on the last exercise, or the current one isn't fully logged.
          if (manager.currentExercise != null &&
              (manager.currentLoggedExerciseData?.isCompleted ?? false)) {
            print(
                "ActiveWorkoutScreen .then(): Did not move. Current exercise ${manager.currentExercise?.name} is complete. Likely at end of list or all subsequent are also complete.");
          } else if (manager.currentExercise != null) {
            print(
                "ActiveWorkoutScreen .then(): Did not move. Current exercise ${manager.currentExercise?.name} is NOT complete. Staying on it.");
          } else {
            print(
                "ActiveWorkoutScreen .then(): Did not move, and no current exercise. Workout might be finishing or all exercises are now marked complete.");
          }
        }
      } else {
        // If the workout became inactive (e.g., ended from within ELS or due to an error),
        // the Consumer in build() should handle navigation.
        print(
            "ActiveWorkoutScreen .then(): Workout is NO LONGER active after ELS pop. Consumer in build() should handle navigation/UI update.");
      }
      // The build method's Consumer will re-render based on manager's state.
    });
  }

  // Checks if all planned exercises in the session have been marked as completed.
  bool allExercisesNowEffectivelyCompleted(WorkoutSessionManager manager) {
    if (!manager.isWorkoutActive || manager.plannedExercises.isEmpty) {
      return false; // Not active or no exercises
    }
    return manager.loggedExercisesData.every((exData) => exData.isCompleted);
  }

  // Formats a Duration into a readable string (HH:MM:SS or MM:SS).
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "$hours:${minutes}:${seconds}";
    }
    return "$minutes:${seconds}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Consumer widget listens to changes in WorkoutSessionManager
    return Consumer<WorkoutSessionManager>(
      builder: (consumerContext, manager, child) {
        // `consumerContext` is the BuildContext for this Consumer's builder.
        final currentRoute = ModalRoute.of(consumerContext);
        final bool isThisScreenCurrentlyVisible =
            currentRoute?.isCurrent ?? false;
        final String? currentRouteName = currentRoute?.settings.name;

        print(
            "ActiveWorkoutScreen Consumer BUILD - Route: $currentRouteName, isCurrent: $isThisScreenCurrentlyVisible, isWorkoutActive: ${manager.isWorkoutActive}, currentExIndex: ${manager.currentExerciseIndex}, currentExName: ${manager.currentExercise?.name}, currentLoggedExName: ${manager.currentLoggedExerciseData?.originalExercise.name}");

        // --- Handle Workout Not Active (Ended or Interrupted) ---
        if (!manager.isWorkoutActive) {
          print(
              "ActiveWorkoutScreen Consumer: Workout NO LONGER active. Previous workout was likely '${manager.currentWorkoutName}' (now reset by manager).");

          // If this screen is still the current route, schedule a pop to the first route.
          if (isThisScreenCurrentlyVisible) {
            print(
                "ActiveWorkoutScreen Consumer: This screen IS current. Scheduling pop to first route.");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Use `consumerContext` if this callback depends on it.
              // However, for navigation, `Navigator.of(context)` from the method scope is fine.
              final navigator =
                  Navigator.of(context); // Use original context passed to build
              if (navigator.canPop()) {
                // Re-check current route status within the callback as state might have changed
                final routeAfterFrame = ModalRoute.of(context);
                if (routeAfterFrame != null &&
                    routeAfterFrame.isCurrent &&
                    !routeAfterFrame.isFirst &&
                    (routeAfterFrame.settings.name != '/main_dashboard' &&
                        routeAfterFrame.settings.name != '/')) {
                  // Avoid popping if already on root/main
                  print(
                      "ActiveWorkoutScreen Consumer (callback): Popping until first. Current route is ${routeAfterFrame.settings.name}.");
                  navigator.popUntil((route) => route.isFirst);
                } else {
                  print(
                      "ActiveWorkoutScreen Consumer (callback): Conditions for popUntil not met. Route: ${routeAfterFrame?.settings.name}, isCurrent: ${routeAfterFrame?.isCurrent}, isFirst: ${routeAfterFrame?.isFirst}");
                }
              } else {
                print(
                    "ActiveWorkoutScreen Consumer (callback): Cannot pop. (navigator.canPop: ${navigator.canPop()})");
              }
            });
          } else {
            print(
                "ActiveWorkoutScreen Consumer: Workout no longer active, but this screen is NOT current. Pop deferred or handled by another part of the UI.");
          }
          // Show a placeholder UI while navigating away
          return Scaffold(
              appBar: AppBar(title: const Text("Workout Ended")),
              body: const Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Finalizing workout session..."),
                ],
              )));
        }

        // --- Handle Empty Workout Plan ---
        if (manager.plannedExercises.isEmpty) {
          return Scaffold(
              appBar: AppBar(
                  title: Text(manager.currentWorkoutName.isNotEmpty
                      ? manager.currentWorkoutName
                      : "Empty Workout")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No exercises in this workout plan."),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // `consumerContext` is valid here.
                        await _handleEndWorkout(consumerContext, manager);
                      },
                      child: const Text("End Empty Session"),
                    )
                  ],
                ),
              ));
        }

        // --- Main UI for Active Workout ---
        final String currentWorkoutTitle = manager.currentWorkoutName.isNotEmpty
            ? manager.currentWorkoutName
            : "Workout Session";

        // Determine which exercise to highlight visually (usually the next non-completed one)
        int visuallyHighlightedIndex =
            manager.currentExerciseIndex; // Start with manager's current
        if (visuallyHighlightedIndex >= 0 &&
            visuallyHighlightedIndex < manager.loggedExercisesData.length &&
            manager.loggedExercisesData[visuallyHighlightedIndex].isCompleted) {
          // If current is completed, find the next non-completed
          int firstNonCompleted =
              manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);
          visuallyHighlightedIndex = (firstNonCompleted != -1)
              ? firstNonCompleted
              : manager.plannedExercises.length; // Default to end if all done
        }
        if (visuallyHighlightedIndex < 0 &&
            manager.plannedExercises.isNotEmpty) {
          // If no current index, find the first non-completed
          int firstNonCompleted =
              manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);
          visuallyHighlightedIndex = (firstNonCompleted != -1)
              ? firstNonCompleted
              : 0; // Default to first
        }
        // Ensure index is within bounds for highlighting
        if (visuallyHighlightedIndex >= manager.plannedExercises.length) {
          visuallyHighlightedIndex = manager.plannedExercises
              .length; // Can be equal to length if all done (highlights nothing)
        }

        bool allDone = allExercisesNowEffectivelyCompleted(manager);
        String currentNextUpText;
        if (allDone) {
          currentNextUpText = "Workout Complete! Press End.";
        } else if (manager.currentExercise != null &&
            !(manager.currentLoggedExerciseData?.isCompleted ?? true)) {
          // If there's an active current exercise that is not yet completed
          currentNextUpText = "Current: ${manager.currentExercise!.name}";
        } else {
          // Find the next upcoming non-completed exercise
          int nextUpcomingIndex = manager.loggedExercisesData
              .indexWhere((exData) => !exData.isCompleted);
          if (nextUpcomingIndex != -1 &&
              nextUpcomingIndex < manager.plannedExercises.length) {
            currentNextUpText =
                "Next Up: ${manager.plannedExercises[nextUpcomingIndex].name}";
          } else {
            currentNextUpText =
                "All exercises targeted. Press End."; // All marked, but workout not formally ended
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentWorkoutTitle,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            automaticallyImplyLeading:
                false, // No back button if this is a dedicated session screen
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    _formatDuration(manager.currentWorkoutDuration),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, // Use primary color for timer
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        currentNextUpText,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${manager.completedExercisesCount} / ${manager.totalExercises} completed",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: manager.plannedExercises.length,
                  itemBuilder: (listContext, index) {
                    // `listContext` from ListView.builder
                    final RoutineExercise plannedExerciseDetails =
                        manager.plannedExercises[index];
                    final LoggedExerciseData loggedDataForThisExercise =
                        manager.loggedExercisesData[index];
                    final bool isCompleted =
                        loggedDataForThisExercise.isCompleted;
                    // Determine if this item should be visually highlighted as the "current" one to do
                    final bool isVisuallyCurrentExercise =
                        (index == visuallyHighlightedIndex) &&
                            !isCompleted &&
                            !allDone;

                    String setsRepsInfo =
                        "${plannedExerciseDetails.sets} sets of ${plannedExerciseDetails.reps}";
                    if (plannedExerciseDetails.weightSuggestionKg.isNotEmpty &&
                        plannedExerciseDetails.weightSuggestionKg != 'N/A') {
                      setsRepsInfo +=
                          " @ ${plannedExerciseDetails.weightSuggestionKg}";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6.0),
                      elevation: isVisuallyCurrentExercise
                          ? 4.5
                          : 1.5, // More elevation for current
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: isCompleted
                              ? Colors.green.shade400.withOpacity(0.7)
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                  : Colors.transparent),
                          width: isVisuallyCurrentExercise ? 2.0 : 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: isCompleted
                              ? Colors.green.shade600
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer),
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                      color: isVisuallyCurrentExercise
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                        ),
                        title: Text(
                          plannedExerciseDetails.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.6)
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          setsRepsInfo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(isCompleted ? 0.5 : 0.8),
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: isCompleted
                            ? null // No trailing icon if completed
                            : Icon(Icons.play_circle_fill_outlined,
                                color: colorScheme.primary, size: 30),
                        onTap: isCompleted
                            ? null
                            : () {
                                // `listContext` is valid here.
                                _navigateToExerciseLogging(
                                    listContext, manager, index);
                              },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined, size: 22),
                  label: Text(
                      allDone ? "FINISH & SAVE WORKOUT" : "END WORKOUT EARLY"),
                  onPressed: () {
                    // `consumerContext` is valid here for showDialog.
                    showDialog<bool>(
                      context:
                          consumerContext, // Use context from Consumer builder
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('End Workout?'),
                        content: Text(allDone
                            ? 'Well done! Ready to save this session?'
                            : 'Are you sure you want to end the workout early? Progress will be saved.'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text(
                                  allDone ? 'Finish & Save' : 'End Early',
                                  style: TextStyle(
                                      color: allDone
                                          ? Colors.green.shade700
                                          : theme.colorScheme.error))),
                        ],
                      ),
                    ).then((confirmed) async {
                      if (confirmed ?? false) {
                        // `consumerContext` for _handleEndWorkout.
                        await _handleEndWorkout(consumerContext, manager);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allDone
                        ? Colors.green.shade700
                        : colorScheme.errorContainer,
                    foregroundColor:
                        allDone ? Colors.white : colorScheme.onErrorContainer,
                    minimumSize:
                        const Size(double.infinity, 52), // Taller button
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold), // Use labelLarge
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
