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

  Future<void> _handleEndWorkout(
      BuildContext context, WorkoutSessionManager manager) async {
    print(
        "ActiveWorkoutScreen _handleEndWorkout: Initiating end workout process. Manager active before endWorkout(): ${manager.isWorkoutActive}");

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Map<String, dynamic>? workoutLogPayload = manager.endWorkout();

    if (workoutLogPayload == null) {
      print(
          "ActiveWorkoutScreen _handleEndWorkout: manager.endWorkout() returned null. No log to save.");
      // Même si aucun log n'est à sauvegarder, la session est terminée.
      // Le prochain build du Consumer devrait gérer la navigation.
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print(
          "ActiveWorkoutScreen _handleEndWorkout: Error - Current user is null. Workout log cannot be saved.");
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
      return; // La session est terminée, le Consumer gérera la navigation.
    }

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
      print(
          "ActiveWorkoutScreen _handleEndWorkout: Error saving workout log to Firestore: $e\n$s");
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
    // Après avoir tenté de sauvegarder, la session est considérée comme terminée.
    // Le prochain build du Consumer gérera la navigation.
  }

  void _navigateToExerciseLogging(BuildContext context,
      WorkoutSessionManager manager, int exerciseIndexInList) {
    final currentContext = context;

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
        "ActiveWorkoutScreen _navigateToExerciseLogging: Navigating to ELS for ${exerciseToLog.name} (index $exerciseIndexInList). Manager's currentSetIndex for logging: ${manager.currentSetIndexForLogging}");

    Navigator.push(
      currentContext,
      MaterialPageRoute(
        // Il est bon de donner un nom de route pour le débogage et le test si nécessaire
        settings: const RouteSettings(name: "/exercise_logging"),
        builder: (_) => ExerciseLoggingScreen(
          exercise: exerciseToLog,
          onExerciseCompleted: () {
            print(
                "ActiveWorkoutScreen: ELS onExerciseCompleted callback for ${exerciseToLog.name}.");
            // La logique de déplacement vers le prochain exercice est gérée dans le .then() ci-dessous.
          },
        ),
      ),
    ).then((_) {
      // Ce code s'exécute APRÈS le pop de ExerciseLoggingScreen
      final String postPopExerciseName = manager.currentExercise?.name ??
          manager.currentLoggedExerciseData?.originalExercise.name ??
          'unknown (manager state after pop)';
      print(
          "ActiveWorkoutScreen .then() after ELS pop. ELS was for (approx): $postPopExerciseName.");
      print(
          "ActiveWorkoutScreen .then(): Manager state - isWorkoutActive: ${manager.isWorkoutActive}, currentExIndex: ${manager.currentExerciseIndex}, currentExName: ${manager.currentExercise?.name}");

      if (manager.isWorkoutActive) {
        print(
            "ActiveWorkoutScreen .then(): Attempting manager.moveToNextExercise() from index ${manager.currentExerciseIndex}");
        bool moved = manager
            .moveToNextExercise(); // Tente de passer à l'exercice suivant

        if (allExercisesEffectivelyCompleted(manager)) {
          print(
              "ActiveWorkoutScreen .then(): All exercises confirmed completed after ELS pop and moveToNext attempt.");
          // L'UI se mettra à jour pour montrer "Workout Complete! Press Finish."
        } else if (moved) {
          print(
              "ActiveWorkoutScreen .then(): Successfully moved to next exercise: ${manager.currentExercise?.name}");
        } else {
          // N'a pas bougé, raisons possibles :
          // - L'exercice actuel n'est pas encore terminé (ne devrait pas arriver si ELS a bien marqué complet)
          // - C'était le dernier exercice
          // - Le prochain exercice était déjà complété (rare, mais possible si l'utilisateur a navigué manuellement)
          final currentLoggedData = manager.currentLoggedExerciseData;
          if (manager.currentExercise != null &&
              (currentLoggedData?.isCompleted ?? false)) {
            print(
                "ActiveWorkoutScreen .then(): Did not move. Current exercise ${manager.currentExercise?.name} is complete. Likely at end or subsequent are complete.");
          } else if (manager.currentExercise != null) {
            print(
                "ActiveWorkoutScreen .then(): Did not move. Current exercise ${manager.currentExercise?.name} is NOT complete.");
          } else {
            print(
                "ActiveWorkoutScreen .then(): Did not move, and no current exercise. Workout might be finishing or all exercises are now marked complete.");
          }
        }
      } else {
        print(
            "ActiveWorkoutScreen .then(): Workout is NO LONGER active after ELS pop. Consumer should handle navigation.");
        // Le Consumer dans build() devrait détecter cela et naviguer.
      }
    });
  }

  bool allExercisesEffectivelyCompleted(WorkoutSessionManager manager) {
    if (!manager.isWorkoutActive || manager.loggedExercisesData.isEmpty) {
      return false;
    }
    // Vérifie si tous les exercices planifiés ont une entrée correspondante dans loggedExercisesData
    // et que cette entrée est marquée comme complétée.
    if (manager.plannedExercises.length != manager.loggedExercisesData.length)
      return false;
    return manager.loggedExercisesData.every((exData) => exData.isCompleted);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<WorkoutSessionManager>(
      builder: (consumerContext, manager, child) {
        final currentRoute = ModalRoute.of(consumerContext);
        // Il est important de vérifier si cet écran spécifique est la route actuelle.
        // settings.name peut être null si la route n'a pas été nommée via pushNamed.
        // Si vous naviguez toujours vers cet écran avec MaterialPageRoute sans settings,
        // alors isCurrent est la vérification la plus fiable.
        final bool isThisScreenCurrentlyVisible =
            currentRoute?.isCurrent ?? false;

        print(
            "ActiveWorkoutScreen Consumer BUILD - Route Name: ${currentRoute?.settings.name}, isCurrent: $isThisScreenCurrentlyVisible, isWorkoutActive: ${manager.isWorkoutActive}");

        if (!manager.isWorkoutActive) {
          print(
              "ActiveWorkoutScreen Consumer: Workout NO LONGER active. Last workout name was '${manager.currentWorkoutName}'.");

          // Pour éviter des navigations multiples si le widget est reconstruit plusieurs fois
          // après que la session soit devenue inactive.
          // On vérifie si cet écran est toujours celui au premier plan.
          if (isThisScreenCurrentlyVisible) {
            print(
                "ActiveWorkoutScreen Consumer: This screen IS current. Scheduling navigation to main app.");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              // S'assurer que le contexte est toujours valide avant de naviguer
              if (consumerContext.mounted) {
                // Naviguer vers l'écran principal et supprimer toutes les routes au-dessus.
                // Utiliser la route nommée '/main_app' que vous avez définie dans main.dart
                Navigator.of(consumerContext).pushNamedAndRemoveUntil(
                  '/main_app',
                  (Route<dynamic> route) =>
                      false, // Supprime toutes les routes précédentes
                );
                print(
                    "ActiveWorkoutScreen Consumer (callback): Navigated to '/main_app' and removed previous routes.");
              } else {
                print(
                    "ActiveWorkoutScreen Consumer (callback): Context not mounted, navigation skipped.");
              }
            });
          } else {
            print(
                "ActiveWorkoutScreen Consumer: This screen is NOT current. Navigation to main_app deferred or handled elsewhere.");
          }

          // Afficher un indicateur pendant que la navigation post-frame est programmée.
          return Scaffold(
              appBar: AppBar(
                  title: Text(manager.currentWorkoutName.isNotEmpty
                      ? "${manager.currentWorkoutName} Ended"
                      : "Workout Ended"),
                  automaticallyImplyLeading: false), // Pas de bouton retour ici
              body: const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Finalizing workout session...")
                  ])));
        }

        // Le reste du widget build pour quand la session est active
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
                            style: theme.textTheme.titleMedium?.copyWith(
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
                        const Icon(Icons.warning_amber_rounded,
                            size: 60, color: Colors.orangeAccent),
                        const SizedBox(height: 20),
                        const Text("This workout plan is empty.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text("End Empty Session"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.onErrorContainer,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15)),
                          onPressed: () async {
                            // _handleEndWorkout va mettre manager.isWorkoutActive à false
                            // ce qui déclenchera la logique de navigation au prochain build.
                            await _handleEndWorkout(consumerContext, manager);
                          },
                        )
                      ]),
                ),
              ));
        }

        final String currentWorkoutTitle = manager.currentWorkoutName.isNotEmpty
            ? manager.currentWorkoutName
            : "Workout Session";

        int visuallyHighlightedIndex = -1;
        final firstUncompletedIndex =
            manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);

        if (firstUncompletedIndex != -1) {
          visuallyHighlightedIndex = firstUncompletedIndex;
        } else if (manager.loggedExercisesData.length <
            manager.plannedExercises.length) {
          // Si tous les loggés sont complets, mais qu'il reste des exercices planifiés non loggés
          visuallyHighlightedIndex = manager.loggedExercisesData.length;
        } else {
          // Tous les planifiés ont été loggés et sont complets
          visuallyHighlightedIndex =
              manager.plannedExercises.length; // Indique que tout est fait
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
          // Ce cas ne devrait pas arriver si la logique de visuallyHighlightedIndex est correcte
          currentNextUpText = "Ready to start logging!";
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentWorkoutTitle,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                    child: Text(_formatDuration(manager.currentWorkoutDuration),
                        style: theme.textTheme.titleMedium?.copyWith(
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
                color: colorScheme.surfaceContainerHighest
                    .withAlpha((0.3 * 255).round()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Text(currentNextUpText,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
                    const SizedBox(width: 10),
                    Text(
                        "${manager.completedExercisesCount} / ${manager.totalExercises} done",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  itemCount: manager.plannedExercises.length,
                  itemBuilder: (listContext, index) {
                    final RoutineExercise plannedExerciseDetails =
                        manager.plannedExercises[index];
                    final LoggedExerciseData loggedDataForThisExercise = (index <
                            manager.loggedExercisesData.length)
                        ? manager.loggedExercisesData[index]
                        : LoggedExerciseData(
                            originalExercise:
                                plannedExerciseDetails); // Crée un LoggedExerciseData vide si pas encore loggé

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
                              ? Colors.green.withAlpha((0.6 * 255).round())
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                      .withAlpha((0.8 * 255).round())
                                  : Colors.grey.shade300
                                      .withAlpha((0.5 * 255).round())),
                          width: isVisuallyCurrentExercise ? 2.0 : 1.0,
                        ),
                      ),
                      color: isCompleted
                          ? Colors.grey.shade200.withAlpha((0.5 * 255).round())
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: isCompleted
                              ? Colors.green
                              : (isVisuallyCurrentExercise
                                  ? colorScheme.primary
                                  : colorScheme.secondaryContainer),
                          child: isCompleted
                              ? const Icon(Icons.check,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? theme.textTheme.bodySmall?.color
                                    ?.withAlpha((0.5 * 255).round())
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          setsRepsInfo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(
                                isCompleted
                                    ? (0.4 * 255).round()
                                    : (0.7 * 255).round()),
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: isCompleted
                            ? null // Ou une icône "Edit" si vous voulez permettre de modifier un exercice complété
                            : Icon(
                                isVisuallyCurrentExercise
                                    ? Icons
                                        .play_circle_fill // Ou edit si c'est l'exercice en cours de log
                                    : Icons.play_circle_outline,
                                color: colorScheme.primary,
                                size: 28),
                        onTap: isCompleted
                            ? null // Ou permettre de modifier si souhaité
                            : () {
                                _navigateToExerciseLogging(
                                    listContext, manager, index);
                              },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
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
                        // La session est maintenant inactive. Le prochain build du Consumer
                        // déclenchera la navigation vers '/main_app'.
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: allDone
                          ? Colors.green.shade600
                          : colorScheme.errorContainer,
                      foregroundColor:
                          allDone ? Colors.white : colorScheme.onErrorContainer,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: theme.textTheme.labelLarge
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
