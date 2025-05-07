// lib/screens/active_workout_session_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart'; // WorkoutSessionManager, LoggedExerciseData
import 'package:gymgenius/screens/exercise_logging_screen.dart';
import 'package:provider/provider.dart';

class ActiveWorkoutSessionScreen extends StatelessWidget {
  const ActiveWorkoutSessionScreen({super.key});

  Future<void> _handleEndWorkout(
      BuildContext context, WorkoutSessionManager manager) async {
    print(
        "AWS _handleEndWorkout: Initiating end workout process. Manager active before endWorkout(): ${manager.isWorkoutActive}");

    final scaffoldMessenger =
        ScaffoldMessenger.of(context); // Capturer avant que l'état ne change

    Map<String, dynamic>? workoutLogPayload = manager.endWorkout();
    // manager.isWorkoutActive est maintenant false. Le Consumer va réagir.

    if (workoutLogPayload == null) {
      print(
          "AWS _handleEndWorkout: manager.endWorkout() returned null. No log to save.");
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("AWS _handleEndWorkout: Error - Current user is null.");
      if (scaffoldMessenger.mounted) {
        // Vérifier la validité du messenger capturé
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text("Error: Not logged in. Workout not saved."),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    workoutLogPayload['userId'] = currentUser.uid;
    workoutLogPayload['savedAt'] = FieldValue.serverTimestamp();

    print(
        "AWS _handleEndWorkout: Workout log data prepared: $workoutLogPayload");

    try {
      await FirebaseFirestore.instance
          .collection('workout_logs')
          .add(workoutLogPayload);
      print(
          "AWS _handleEndWorkout: Workout log saved successfully to Firestore.");

      if (scaffoldMessenger.mounted) {
        // Vérifier APRÈS l'await
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text("Workout session saved successfully!"),
              backgroundColor: Colors.green),
        );
      } else {
        print(
            "AWS _handleEndWorkout: ScaffoldMessenger not mounted after successful save. SnackBar not shown.");
      }
    } catch (e, s) {
      print("AWS _handleEndWorkout: Error saving workout log: $e\n$s");
      if (scaffoldMessenger.mounted) {
        // Vérifier APRÈS l'await
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text("Failed to save workout: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      } else {
        print(
            "AWS _handleEndWorkout: ScaffoldMessenger not mounted after save error. SnackBar not shown.");
      }
    }
  }

  void _navigateToExerciseLogging(BuildContext context,
      WorkoutSessionManager manager, int exerciseIndexInList) {
    bool success = manager.selectExercise(exerciseIndexInList);
    if (!success) {
      print(
          "AWS _navigateToExerciseLogging Error: manager.selectExercise failed for index $exerciseIndexInList.");
      return;
    }

    final RoutineExercise? exerciseToLog = manager.currentExercise;

    if (exerciseToLog == null) {
      print(
          "AWS _navigateToExerciseLogging Error: manager.currentExercise is null after select for index $exerciseIndexInList.");
      return;
    }
    print(
        "AWS _navigateToExerciseLogging: Navigating to ELS for ${exerciseToLog.name} (index $exerciseIndexInList). Manager currentSetIndex for this ex: ${manager.currentSetIndexForLogging}");

    Navigator.push(
      context, // Ce context est valide au moment de l'appel.
      MaterialPageRoute(
        settings: const RouteSettings(name: "/exercise_logging"),
        builder: (_) => ExerciseLoggingScreen(
          exercise: exerciseToLog,
          onExerciseCompleted: () {
            print(
                "AWS: ELS onExerciseCompleted callback received for ${exerciseToLog.name}.");
          },
        ),
      ),
    ).then((_) {
      // Le 'context' original de cette méthode n'est pas utilisé ici.
      // On interagit principalement avec le 'manager'.
      print(
          "AWS: .then() after ELS pop. ELS was for (approx) ${manager.currentExercise?.name ?? manager.currentLoggedExerciseData?.originalExercise.name ?? 'unknown'}.");
      print(
          "AWS: Manager state - isWorkoutActive: ${manager.isWorkoutActive}, currentExIndex: ${manager.currentExerciseIndex}, currentExName: ${manager.currentExercise?.name}");

      if (manager.isWorkoutActive) {
        print(
            "AWS (.then): Attempting manager.moveToNextExercise() from index ${manager.currentExerciseIndex}");
        bool moved = manager.moveToNextExercise();

        if (allExercisesNowCompleted(manager)) {
          print(
              "AWS (.then): All exercises confirmed completed after ELS pop and moveToNext attempt.");
        } else if (moved) {
          print(
              "AWS (.then): Successfully moved to next exercise: ${manager.currentExercise?.name}");
        } else {
          if (manager.currentExercise != null &&
              (manager.currentLoggedExerciseData?.isCompleted ?? false)) {
            print(
                "AWS (.then): Did not move, current exercise ${manager.currentExercise?.name} is complete. Likely at end or all done.");
          } else if (manager.currentExercise != null) {
            print(
                "AWS (.then): Did not move, current exercise ${manager.currentExercise?.name} is NOT complete. Staying.");
          } else {
            print(
                "AWS (.then): Did not move, no current exercise. Workout might be finishing or all done.");
          }
        }
      } else {
        print(
            "AWS (.then): Workout is NO LONGER active after ELS pop. Consumer in build() should handle navigation.");
      }
    });
  }

  bool allExercisesNowCompleted(WorkoutSessionManager manager) {
    if (!manager.isWorkoutActive || manager.plannedExercises.isEmpty) {
      return false;
    }
    return manager.loggedExercisesData.every((exData) => exData.isCompleted);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<WorkoutSessionManager>(
      builder: (context, manager, child) {
        // Ce 'context' est celui du Consumer, valide pour ce build.
        final currentRoute = ModalRoute.of(context);
        final bool isThisScreenCurrent = currentRoute?.isCurrent ?? false;
        final String? currentRouteName = currentRoute?.settings.name;

        print(
            "AWS Consumer BUILD - Route: $currentRouteName, isCurrent: $isThisScreenCurrent, isWorkoutActive: ${manager.isWorkoutActive}, currentExIndex: ${manager.currentExerciseIndex}, currentExName: ${manager.currentExercise?.name}, currentLoggedExName: ${manager.currentLoggedExerciseData?.originalExercise.name}");

        if (!manager.isWorkoutActive) {
          print(
              "AWS Consumer: Workout NO LONGER active. Previous workout name was likely '${manager.currentWorkoutName}' (now reset by manager).");

          if (isThisScreenCurrent) {
            print(
                "AWS Consumer: This screen IS current. Scheduling pop to first route.");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Utiliser le 'context' du builder du Consumer, qui devrait être valide si le Consumer
              // n'a pas été retiré de l'arbre avant l'exécution de ce callback.
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                final currentModalRoute =
                    ModalRoute.of(context); // Re-obtenir dans le callback
                if (currentModalRoute != null &&
                    currentModalRoute
                        .isCurrent && // S'assurer que CET écran est toujours celui qui doit être poppé
                    !currentModalRoute.isFirst &&
                    (currentModalRoute.settings.name != '/main_dashboard' &&
                        currentModalRoute.settings.name != '/')) {
                  print(
                      "AWS Consumer (callback): Popping until first. Current route: ${currentModalRoute.settings.name}");
                  navigator.popUntil((route) => route.isFirst);
                } else {
                  print(
                      "AWS Consumer (callback): Conditions for popUntil not met. Route: ${currentModalRoute?.settings.name}, isCurrent: ${currentModalRoute?.isCurrent}, isFirst: ${currentModalRoute?.isFirst}");
                }
              } else {
                print(
                    "AWS Consumer (callback): Cannot pop. (canPop: ${navigator.canPop()})");
              }
            });
          } else {
            print(
                "AWS Consumer: Workout no longer active, but this screen is NOT current. Pop deferred or handled elsewhere.");
          }

          return Scaffold(
              appBar: AppBar(title: const Text("Workout Ended")),
              body: const Center(child: Text("Finalizing workout session...")));
        }

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
                        // Le 'context' ici est celui du builder du Consumer, valide.
                        await _handleEndWorkout(context, manager);
                      },
                      child: const Text("End Empty Session"),
                    )
                  ],
                ),
              ));
        }

        final String currentWorkoutTitle = manager.currentWorkoutName.isNotEmpty
            ? manager.currentWorkoutName
            : "Workout Session";

        int visuallyHighlightedIndex = manager.currentExerciseIndex;
        if (visuallyHighlightedIndex >= 0 &&
            visuallyHighlightedIndex < manager.loggedExercisesData.length &&
            manager.loggedExercisesData[visuallyHighlightedIndex].isCompleted) {
          int firstNonCompleted =
              manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);
          visuallyHighlightedIndex = (firstNonCompleted != -1)
              ? firstNonCompleted
              : manager.plannedExercises.length;
        }
        if (visuallyHighlightedIndex < 0 &&
            manager.plannedExercises.isNotEmpty) {
          int firstNonCompleted =
              manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);
          visuallyHighlightedIndex =
              (firstNonCompleted != -1) ? firstNonCompleted : 0;
        }
        if (visuallyHighlightedIndex >= manager.plannedExercises.length) {
          visuallyHighlightedIndex = manager.plannedExercises.length;
        }

        bool allExercisesEffectivelyCompleted =
            allExercisesNowCompleted(manager);
        String currentNextUpText;
        if (allExercisesEffectivelyCompleted) {
          currentNextUpText = "Workout Complete!";
        } else if (manager.currentExercise != null &&
            !(manager.currentLoggedExerciseData?.isCompleted ?? true)) {
          currentNextUpText = "Current: ${manager.currentExercise!.name}";
        } else {
          int nextUpcomingIndex = manager.loggedExercisesData
              .indexWhere((exData) => !exData.isCompleted);
          if (nextUpcomingIndex != -1 &&
              nextUpcomingIndex < manager.plannedExercises.length) {
            currentNextUpText =
                "Next Up: ${manager.plannedExercises[nextUpcomingIndex].name}";
          } else {
            currentNextUpText =
                "All exercises targeted"; // Ou un autre message si tous sont complétés mais le workout n'est pas "ended"
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentWorkoutTitle),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    _formatDuration(manager.currentWorkoutDuration),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentNextUpText,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${manager.completedExercisesCount}/${manager.totalExercises} completed",
                      style: theme.textTheme.bodySmall,
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: manager.plannedExercises.length,
                  itemBuilder: (context, index) {
                    // Ce 'context' est celui du ListView.builder
                    final RoutineExercise plannedExerciseDetails =
                        manager.plannedExercises[index];
                    final LoggedExerciseData loggedDataForThisExercise =
                        manager.loggedExercisesData[index];
                    final bool isCompleted =
                        loggedDataForThisExercise.isCompleted;
                    final bool isVisuallyCurrentExercise =
                        (index == visuallyHighlightedIndex) && !isCompleted;

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
                      elevation: isVisuallyCurrentExercise ? 4.0 : 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.5)
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                  : Colors.transparent),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: isCompleted
                              ? Colors.green
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer),
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white)
                              : Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                      color: isVisuallyCurrentExercise
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        title: Text(
                          plannedExerciseDetails.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.6)
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          setsRepsInfo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(isCompleted ? 0.5 : 0.8),
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: isCompleted
                            ? null
                            : Icon(Icons.play_circle_outline,
                                color: colorScheme.primary, size: 28),
                        onTap: isCompleted
                            ? null
                            : () {
                                // Le 'context' ici est celui du ListView.builder, valide pour ce scope.
                                _navigateToExerciseLogging(
                                    context, manager, index);
                              },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text("End Workout"),
                  onPressed: () {
                    // Le 'context' ici est celui du builder du Consumer, valide.
                    showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('End Workout?'),
                        content: const Text(
                            'Are you sure? This will end and save your current session.'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('End & Save')),
                        ],
                      ),
                    ).then((confirmed) async {
                      // Le 'context' ici est celui du builder du Consumer.
                      // On suppose qu'il est toujours valide car showDialog est une opération modale
                      // qui bloque l'UI en dessous.
                      if (confirmed ?? false) {
                        await _handleEndWorkout(context, manager);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: allExercisesEffectivelyCompleted
                          ? Colors.green
                          : colorScheme.errorContainer,
                      foregroundColor: allExercisesEffectivelyCompleted
                          ? Colors.white
                          : colorScheme.onErrorContainer,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
