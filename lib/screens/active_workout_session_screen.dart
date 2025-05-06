// lib/screens/active_workout_session_screen.dart
import 'dart:async'; // Ajout de l'import pour Timer si vous l'activez

import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/screens/exercise_logging_screen.dart';

// Modèle factice pour les données d'exercice DANS LA SESSION ACTIVE
class ActiveExerciseDisplayData {
  final String name;
  final String setsAndRepsInfo;
  bool isCompleted;
  final RoutineExercise originalExercise; // Garder une référence à l'original

  ActiveExerciseDisplayData({
    required this.name,
    required this.setsAndRepsInfo,
    required this.originalExercise,
    this.isCompleted = false,
  });
}

class ActiveWorkoutSessionScreen extends StatefulWidget {
  final String workoutTitle;
  final List<RoutineExercise> exercises;

  const ActiveWorkoutSessionScreen({
    super.key,
    required this.workoutTitle,
    required this.exercises,
  });

  @override
  State<ActiveWorkoutSessionScreen> createState() =>
      _ActiveWorkoutSessionScreenState();
}

class _ActiveWorkoutSessionScreenState
    extends State<ActiveWorkoutSessionScreen> {
  Duration _currentWorkoutDuration = Duration.zero;
  Timer? _sessionTimer; // Pour le timer de la session
  int _currentExerciseIndexForNavigation =
      0; // Pour savoir quel exercice est "actif" pour la navigation
  late List<ActiveExerciseDisplayData> _sessionExercisesDisplayData;

  @override
  void initState() {
    super.initState();
    _startSessionTimer(); // Démarrer le timer de la session

    _sessionExercisesDisplayData = widget.exercises.map((re) {
      String setsRepsInfo = "${re.sets} sets of ${re.reps}";
      if (re.weightSuggestionKg.isNotEmpty && re.weightSuggestionKg != 'N/A') {
        setsRepsInfo += " @ ${re.weightSuggestionKg}";
      }
      return ActiveExerciseDisplayData(
        name: re.name,
        setsAndRepsInfo: setsRepsInfo,
        originalExercise: re, // Stocker l'objet RoutineExercise original
      );
    }).toList();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel(); // S'assurer qu'il n'y a pas de timer existant
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentWorkoutDuration += const Duration(seconds: 1);
      });
    });
  }

  void _navigateToExerciseLogging(BuildContext context,
      RoutineExercise exerciseToLog, int exerciseIndexInList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseLoggingScreen(
          exercise: exerciseToLog,
          onExerciseCompleted: () {
            if (mounted) {
              setState(() {
                _sessionExercisesDisplayData[exerciseIndexInList].isCompleted =
                    true;
                // Essayer de passer à l'exercice suivant non complété
                _moveToNextIncompleteExercise(exerciseIndexInList + 1);
              });
            }
          },
        ),
      ),
    ).then((_) {
      // Ceci est appelé quand on revient de ExerciseLoggingScreen
      // Mettre à jour l'index pour la navigation si un exercice a été complété
      // et que nous ne sommes pas déjà sur le dernier
      if (_sessionExercisesDisplayData[exerciseIndexInList].isCompleted &&
          _currentExerciseIndexForNavigation <
              _sessionExercisesDisplayData.length - 1 &&
          _currentExerciseIndexForNavigation == exerciseIndexInList) {
        _moveToNextIncompleteExercise(exerciseIndexInList + 1);
      }
    });
  }

  void _moveToNextIncompleteExercise(int startIndex) {
    bool foundNext = false;
    for (int i = startIndex; i < _sessionExercisesDisplayData.length; i++) {
      if (!_sessionExercisesDisplayData[i].isCompleted) {
        setState(() {
          _currentExerciseIndexForNavigation = i;
        });
        foundNext = true;
        break;
      }
    }
    if (!foundNext) {
      // Si aucun exercice non complété n'est trouvé après startIndex,
      // vérifier s'il y en a avant (au cas où on a sauté des exercices)
      for (int i = 0; i < startIndex; i++) {
        if (!_sessionExercisesDisplayData[i].isCompleted) {
          setState(() {
            _currentExerciseIndexForNavigation = i;
          });
          foundNext = true;
          break;
        }
      }
    }
    if (!foundNext &&
        _sessionExercisesDisplayData.every((ex) => ex.isCompleted)) {
      print("All exercises completed!");
      // Peut-être afficher un message ou activer le bouton "End Workout" de manière plus prominente
    }
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
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool allExercisesCompleted =
        _sessionExercisesDisplayData.every((ex) => ex.isCompleted);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _formatDuration(_currentWorkoutDuration),
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
                Text(
                  _sessionExercisesDisplayData.every((e) => e.isCompleted)
                      ? "All Done!"
                      : "Next Up:",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${_sessionExercisesDisplayData.where((e) => e.isCompleted).length}/${_sessionExercisesDisplayData.length} completed",
                  style: theme.textTheme.bodySmall,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sessionExercisesDisplayData.length,
              itemBuilder: (context, index) {
                final displayData = _sessionExercisesDisplayData[index];
                // L'exercice "courant" est celui indiqué par _currentExerciseIndexForNavigation
                // ET qui n'est pas encore complété.
                final bool isVisuallyCurrent =
                    index == _currentExerciseIndexForNavigation &&
                        !displayData.isCompleted;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 6.0),
                  elevation: isVisuallyCurrent ? 4.0 : 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: displayData.isCompleted
                          ? Colors.green.withOpacity(0.5)
                          : (isVisuallyCurrent
                              ? colorScheme.primary
                              : Colors.transparent),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: displayData.isCompleted
                          ? Colors.green
                          : (isVisuallyCurrent
                              ? colorScheme.primary
                              : colorScheme.secondaryContainer),
                      child: displayData.isCompleted
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              "${index + 1}",
                              style: TextStyle(
                                  color: isVisuallyCurrent
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    title: Text(
                      displayData.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: displayData.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: displayData.isCompleted
                            ? theme.textTheme.bodySmall?.color?.withOpacity(0.6)
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      displayData.setsAndRepsInfo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(displayData.isCompleted ? 0.5 : 0.8),
                        decoration: displayData.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: displayData.isCompleted
                        ? null
                        : Icon(Icons.play_circle_outline,
                            color: colorScheme.primary, size: 28),
                    onTap: displayData.isCompleted
                        ? null
                        : () {
                            setState(() {
                              _currentExerciseIndexForNavigation = index;
                            });
                            _navigateToExerciseLogging(
                                context, displayData.originalExercise, index);
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
                _sessionTimer?.cancel(); // Arrêter le timer
                // TODO: Implémenter la logique de fin de workout
                // (collecter les données logguées, sauvegarde dans Firestore, navigation)
                print(
                    "Workout Ended at ${_formatDuration(_currentWorkoutDuration)} (Placeholder)");
                Navigator.of(context).popUntil(
                    (route) => route.isFirst); // Revenir au MainDashboard
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: theme.textTheme.titleMedium),
            ),
          ),
        ],
      ),
    );
  }
}
