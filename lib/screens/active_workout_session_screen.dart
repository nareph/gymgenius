// lib/screens/active_workout_session_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart'; // For WorkoutSessionManager, LoggedExerciseData
import 'package:gymgenius/screens/exercise_logging_screen.dart'; // Screen to log sets for an exercise
import 'package:gymgenius/services/logger_service.dart'; // Import the logger service
import 'package:provider/provider.dart'; // For consuming WorkoutSessionManager

class ActiveWorkoutSessionScreen extends StatelessWidget {
  const ActiveWorkoutSessionScreen({super.key});

  Future<void> _handleEndWorkout(
      BuildContext context, WorkoutSessionManager manager) async {
    Log.debug(
        "ActiveWorkoutScreen: Initiating end workout process. Manager active before endWorkout(): ${manager.isWorkoutActive}");
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Map<String, dynamic>? workoutLogPayload = manager.endWorkout();

    if (workoutLogPayload == null) {
      Log.debug(
          "ActiveWorkoutScreen: manager.endWorkout() returned null. No log to save. Session is ended.");
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Log.error(
          "ActiveWorkoutScreen Error: Current user is null. Workout log cannot be saved.");
      if (scaffoldMessenger.context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text("Error: Not logged in. Workout not saved."),
            backgroundColor:
                Theme.of(scaffoldMessenger.context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    workoutLogPayload['userId'] = currentUser.uid;
    workoutLogPayload['savedAt'] = FieldValue.serverTimestamp();

    Log.debug(
        "ActiveWorkoutScreen: Workout log data prepared: $workoutLogPayload");

    try {
      await FirebaseFirestore.instance
          .collection('workout_logs')
          .add(workoutLogPayload);
      Log.debug(
          "ActiveWorkoutScreen: Workout log saved successfully to Firestore.");

      if (scaffoldMessenger.context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text("Workout session saved successfully!"),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, s) {
      Log.error(
          "ActiveWorkoutScreen: Error saving workout log to Firestore: $e",
          error: e,
          stackTrace: s);
      if (scaffoldMessenger.context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Failed to save workout: ${e.toString()}"),
            backgroundColor:
                Theme.of(scaffoldMessenger.context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToExerciseLogging(BuildContext context,
      WorkoutSessionManager manager, int exerciseIndexInList) {
    final currentContext = context;

    bool success = manager.selectExercise(exerciseIndexInList);
    if (!success) {
      Log.error(
          "ActiveWorkoutScreen Error: manager.selectExercise failed for index $exerciseIndexInList.");
      return;
    }

    final RoutineExercise? exerciseToLog = manager.currentExercise;
    if (exerciseToLog == null) {
      Log.error(
          "ActiveWorkoutScreen Error: manager.currentExercise is null after select for index $exerciseIndexInList.");
      return;
    }

    Log.debug(
        "ActiveWorkoutScreen: Navigating to ELS for ${exerciseToLog.name} (index $exerciseIndexInList). Sets to log for it: ${manager.currentSetIndexForLogging}");

    Navigator.push(
      currentContext,
      MaterialPageRoute(
        settings: const RouteSettings(name: "/exercise_logging"),
        builder: (_) => ExerciseLoggingScreen(
          exercise: exerciseToLog,
          onExerciseCompleted: () {
            Log.debug(
                "ActiveWorkoutScreen: ExerciseLoggingScreen's onExerciseCompleted callback for ${exerciseToLog.name}.");
          },
        ),
      ),
    ).then((_) {
      Log.debug(
          "ActiveWorkoutScreen .then() after ELS pop. Manager state - isWorkoutActive: ${manager.isWorkoutActive}, currentExIndex: ${manager.currentExerciseIndex}");

      if (manager.isWorkoutActive) {
        bool moved = manager.moveToNextExercise();

        if (allExercisesEffectivelyCompleted(manager)) {
          Log.debug(
              "ActiveWorkoutScreen .then(): All exercises are now marked as completed.");
        } else if (moved) {
          Log.debug(
              "ActiveWorkoutScreen .then(): Successfully moved to next exercise: ${manager.currentExercise?.name ?? 'N/A'}.");
        } else {
          Log.debug(
              "ActiveWorkoutScreen .then(): Did not move to a new exercise.");
        }
      } else {
        Log.debug(
            "ActiveWorkoutScreen .then(): Workout is NO LONGER active. Navigation will be handled by Consumer.");
      }
    });
  }

  bool allExercisesEffectivelyCompleted(WorkoutSessionManager manager) {
    if (!manager.isWorkoutActive || manager.plannedExercises.isEmpty) {
      return false;
    }
    if (manager.loggedExercisesData.length != manager.plannedExercises.length) {
      return false;
    }
    return manager.loggedExercisesData.every((exData) => exData.isCompleted);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<WorkoutSessionManager>(
      builder: (consumerContext, manager, child) {
        final currentRoute = ModalRoute.of(consumerContext);
        final bool isThisScreenCurrentlyVisible =
            currentRoute?.isCurrent ?? false;

        Log.debug(
            "ActiveWorkoutScreen Consumer BUILD - Route: ${currentRoute?.settings.name}, isCurrent: $isThisScreenCurrentlyVisible, isWorkoutActive: ${manager.isWorkoutActive}");

        if (!manager.isWorkoutActive) {
          Log.debug(
              "ActiveWorkoutScreen Consumer: Workout is NOT active. Last workout name: '${manager.currentWorkoutName}'.");
          if (isThisScreenCurrentlyVisible) {
            Log.debug(
                "ActiveWorkoutScreen Consumer: This screen IS current. Scheduling navigation to main app via '/main_app'.");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (consumerContext.mounted) {
                Navigator.of(consumerContext).pushNamedAndRemoveUntil(
                    '/main_app', (Route<dynamic> route) => false);
                Log.debug(
                    "ActiveWorkoutScreen Consumer (callback): Navigated to '/main_app'.");
              }
            });
          }
          return Scaffold(
              appBar: AppBar(
                  title: Text(manager.currentWorkoutName.isNotEmpty
                      ? "${manager.currentWorkoutName} Ended"
                      : "Workout Ended"),
                  automaticallyImplyLeading: false),
              body: const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Finalizing workout session...")
                  ])));
        }

        if (manager.plannedExercises.isEmpty) {
          return Scaffold(
              appBar: AppBar(
                title: Text(manager.currentWorkoutName.isNotEmpty
                    ? manager.currentWorkoutName
                    : "Empty Workout"),
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                        child: Text(
                            _formatDuration(manager.currentWorkoutDuration),
                            style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary))),
                  ),
                ],
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.playlist_remove_rounded,
                            size: 60, color: Colors.orangeAccent),
                        const SizedBox(height: 20),
                        Text("This workout plan is empty.",
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text("End Empty Session"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.onErrorContainer,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15)),
                          onPressed: () async =>
                              await _handleEndWorkout(consumerContext, manager),
                        )
                      ]),
                ),
              ));
        }

        final String currentWorkoutTitle = manager.currentWorkoutName.isNotEmpty
            ? manager.currentWorkoutName
            : "Workout Session";

        int visuallyHighlightedIndex =
            manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);
        if (visuallyHighlightedIndex == -1 &&
            manager.loggedExercisesData.length <
                manager.plannedExercises.length) {
          visuallyHighlightedIndex = manager.loggedExercisesData.length;
        } else if (visuallyHighlightedIndex == -1) {
          visuallyHighlightedIndex = manager.plannedExercises.length;
        }

        bool allDone = allExercisesEffectivelyCompleted(manager);
        String currentNextUpText;
        if (allDone) {
          currentNextUpText = "Workout Complete! Press Finish.";
        } else if (visuallyHighlightedIndex >= 0 &&
            visuallyHighlightedIndex < manager.plannedExercises.length) {
          currentNextUpText =
              "Next Up: ${manager.plannedExercises[visuallyHighlightedIndex].name}";
        } else {
          currentNextUpText = "Ready to log!";
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentWorkoutTitle,
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                    child: Text(_formatDuration(manager.currentWorkoutDuration),
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary))),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                color:
                    colorScheme.surfaceContainerHighest.withAlpha((77).round()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Text(currentNextUpText,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
                    const SizedBox(width: 10),
                    Text(
                        "${manager.completedExercisesCount} / ${manager.totalExercises} done",
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: manager.plannedExercises.length,
                  itemBuilder: (listContext, index) {
                    final RoutineExercise plannedExerciseDetails =
                        manager.plannedExercises[index];
                    final LoggedExerciseData loggedDataForThisExercise =
                        (index < manager.loggedExercisesData.length)
                            ? manager.loggedExercisesData[index]
                            : LoggedExerciseData(
                                originalExercise: plannedExerciseDetails);

                    final bool isCompleted =
                        loggedDataForThisExercise.isCompleted;
                    final bool isVisuallyCurrentExercise =
                        (index == visuallyHighlightedIndex) && !allDone;

                    String setsRepsInfo =
                        "${plannedExerciseDetails.sets} sets × ${plannedExerciseDetails.reps} reps";
                    if (plannedExerciseDetails.weightSuggestionKg.isNotEmpty &&
                        plannedExerciseDetails.weightSuggestionKg
                                .toLowerCase() !=
                            'n/a' &&
                        plannedExerciseDetails.weightSuggestionKg
                                .toLowerCase() !=
                            'bodyweight') {
                      setsRepsInfo +=
                          " @ ${plannedExerciseDetails.weightSuggestionKg}kg";
                    } else if (plannedExerciseDetails.weightSuggestionKg
                            .toLowerCase() ==
                        'bodyweight') {
                      setsRepsInfo += " (Bodyweight)";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 5.0),
                      elevation: isVisuallyCurrentExercise
                          ? 4.0
                          : (isCompleted ? 0.5 : 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: isCompleted
                              ? Colors.green.withAlpha((153).round())
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary.withAlpha((204).round())
                                  : colorScheme.outlineVariant
                                      .withAlpha((100).round())),
                          width: isVisuallyCurrentExercise ? 2.0 : 1.2,
                        ),
                      ),
                      color: isCompleted
                          ? colorScheme.surfaceContainer
                              .withAlpha((100).round())
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: isCompleted
                              ? Colors.green.shade600
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer),
                          child: isCompleted
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20)
                              : Text("${index + 1}",
                                  style: TextStyle(
                                      color: isVisuallyCurrentExercise
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                        ),
                        title: Text(
                          plannedExerciseDetails.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: isCompleted
                                ? colorScheme.onSurfaceVariant
                                    .withAlpha((153).round())
                                : null,
                            color: isCompleted
                                ? colorScheme.onSurfaceVariant
                                    .withAlpha((153).round())
                                : textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          setsRepsInfo,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withAlpha(
                                isCompleted ? (128).round() : (204).round()),
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: isCompleted
                            ? null
                            : Icon(
                                isVisuallyCurrentExercise
                                    ? Icons.edit_note_rounded
                                    : Icons.play_circle_outline_rounded,
                                color: colorScheme.primary,
                                size: 28),
                        onTap: isCompleted
                            ? null
                            : () => _navigateToExerciseLogging(
                                listContext, manager, index),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
                child: ElevatedButton.icon(
                  icon: Icon(
                      allDone
                          ? Icons.save_alt_rounded
                          : Icons.stop_circle_outlined,
                      size: 22),
                  label: Text(
                      allDone ? "FINISH & SAVE WORKOUT" : "END WORKOUT EARLY"),
                  onPressed: () {
                    showDialog<bool>(
                      context: consumerContext,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Confirm End Workout'),
                        content: Text(allDone
                            ? 'Well done! Ready to save this session?'
                            : 'Are you sure you want to end the workout early? Any completed exercises will be saved.'),
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
                      if (confirmed == true) {
                        await _handleEndWorkout(consumerContext, manager);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: allDone
                          ? Colors.green.shade600
                          : colorScheme.errorContainer,
                      foregroundColor:
                          allDone ? Colors.white : colorScheme.onErrorContainer,
                      minimumSize: const Size(double.infinity, 52),
                      textStyle: textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
