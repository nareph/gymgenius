// lib/screens/exercise_logging_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';

class LoggableSet {
  final int setNumber;
  final String targetRepsInfo; // ex: "8-10" ou "12"
  final String targetWeightSuggestion; // ex: "60kg" ou "Bodyweight"
  TextEditingController repsController;
  TextEditingController weightController;
  bool isLogged;

  LoggableSet({
    required this.setNumber,
    required this.targetRepsInfo,
    required this.targetWeightSuggestion,
    String initialReps = "",
    String initialWeight = "",
    this.isLogged = false,
  })  : repsController = TextEditingController(text: initialReps),
        weightController = TextEditingController(text: initialWeight);

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}

class ExerciseLoggingScreen extends StatefulWidget {
  final RoutineExercise exercise;
  final VoidCallback onExerciseCompleted;

  const ExerciseLoggingScreen({
    super.key,
    required this.exercise,
    required this.onExerciseCompleted,
  });

  @override
  State<ExerciseLoggingScreen> createState() => _ExerciseLoggingScreenState();
}

class _ExerciseLoggingScreenState extends State<ExerciseLoggingScreen> {
  late List<LoggableSet> _loggableSets;
  int _currentSetIndexToLog = 0;

  Timer? _restTimer;
  int _restTimeRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _initializeSets();
  }

  void _initializeSets() {
    _loggableSets = List.generate(widget.exercise.sets, (index) {
      // Essayer de parser le poids suggéré pour le pré-remplir numériquement si possible
      String initialWeight = widget.exercise.weightSuggestionKg;
      // Si weightSuggestionKg est "Bodyweight" ou vide, laisser le champ vide ou mettre "0"
      // Si c'est "N/A", laisser vide.
      if (widget.exercise.weightSuggestionKg.toLowerCase() == 'bodyweight' ||
          widget.exercise.weightSuggestionKg == 'N/A' ||
          widget.exercise.weightSuggestionKg.isEmpty) {
        initialWeight = ""; // ou "0" si vous préférez un placeholder numérique
      } else {
        // Tenter d'extraire la partie numérique si c'est "60kg"
        final RegExp weightRegex = RegExp(r'^\d+(\.\d+)?');
        final match =
            weightRegex.firstMatch(widget.exercise.weightSuggestionKg);
        if (match != null) {
          initialWeight = match.group(0)!;
        }
      }

      // Pour les reps, prendre la première valeur si c'est une plage "8-10"
      String initialReps = widget.exercise.reps;
      if (widget.exercise.reps.contains('-')) {
        initialReps = widget.exercise.reps.split('-').first.trim();
      } else if (widget.exercise.reps.toLowerCase() == 'amrap' ||
          widget.exercise.reps == 'N/A') {
        initialReps = ""; // AMRAP ou N/A, laisser le champ vide
      }

      return LoggableSet(
        setNumber: index + 1,
        targetRepsInfo: widget.exercise.reps,
        targetWeightSuggestion: widget.exercise.weightSuggestionKg,
        initialReps: initialReps,
        initialWeight: initialWeight,
      );
    });
  }

  void _logSet(int setIndex) {
    if (setIndex >= _loggableSets.length || _loggableSets[setIndex].isLogged)
      return;

    // TODO: Valider les entrées des controllers (s'assurer que ce sont des nombres si nécessaire)
    // Pour l'instant, on les prend telles quelles.

    setState(() {
      _loggableSets[setIndex].isLogged = true;
      // TODO: Ici, vous stockerez ces données dans votre WorkoutSessionManager
      print("Set ${setIndex + 1} for ${widget.exercise.name} logged: "
          "Reps: ${_loggableSets[setIndex].repsController.text}, "
          "Weight: ${_loggableSets[setIndex].weightController.text}kg");

      // Trouver le prochain set non loggué
      int nextSetToLog = -1;
      for (int i = 0; i < _loggableSets.length; i++) {
        if (!_loggableSets[i].isLogged) {
          nextSetToLog = i;
          break;
        }
      }

      if (nextSetToLog != -1) {
        _currentSetIndexToLog = nextSetToLog;
      } else {
        _currentSetIndexToLog =
            _loggableSets.length; // Tous les sets sont logués
      }

      if (_loggableSets.every((s) => s.isLogged)) {
        _restTimer?.cancel(); // S'assurer que le timer de repos est arrêté
        _isResting = false;
        widget.onExerciseCompleted();
        // Navigator.of(context).pop(); // Retourner automatiquement
      } else if (widget.exercise.restBetweenSetsSeconds > 0 &&
          setIndex < _loggableSets.length - 1) {
        // Démarrer le timer de repos seulement si ce n'est pas le dernier set loggué
        // et qu'il y a un temps de repos défini.
        _startRestTimer(widget.exercise.restBetweenSetsSeconds);
      }
    });
  }

  void _startRestTimer(int durationInSeconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restTimeRemaining = durationInSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_restTimeRemaining > 0) {
          _restTimeRemaining--;
        } else {
          _isResting = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    for (var logSet in _loggableSets) {
      logSet.dispose();
    }
    super.dispose();
  }

  String _formatRestTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool allSetsManuallyLogged = _loggableSets.every((s) => s.isLogged);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: GestureDetector(
        // Pour pouvoir cacher le clavier en tapant à côté
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Target: ${widget.exercise.sets} sets of ${widget.exercise.reps}",
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.exercise.weightSuggestionKg.isNotEmpty &&
                          widget.exercise.weightSuggestionKg != 'N/A')
                        Text(
                          "Suggested Weight: ${widget.exercise.weightSuggestionKg}",
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      if (widget.exercise.restBetweenSetsSeconds > 0)
                        Text(
                          "Rest: ${widget.exercise.restBetweenSetsSeconds} sec",
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      if (widget.exercise.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text("Notes: ${widget.exercise.description}",
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center),
                      ]
                    ],
                  ),
                ),
              ),
              if (_isResting)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Text("REST",
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                      Text(
                        _formatRestTime(_restTimeRemaining),
                        style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary),
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: widget.exercise.restBetweenSetsSeconds > 0
                            ? _restTimeRemaining /
                                widget.exercise.restBetweenSetsSeconds
                            : 0,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          _restTimer?.cancel();
                          setState(() {
                            _isResting = false;
                          });
                        },
                        child: const Text("Skip Rest"),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _loggableSets.length,
                  itemBuilder: (context, index) {
                    final setInfo = _loggableSets[index];
                    bool canLogThisSet = index == _currentSetIndexToLog &&
                        !_isResting &&
                        !setInfo.isLogged;
                    bool isFutureSet =
                        index > _currentSetIndexToLog && !setInfo.isLogged;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: setInfo.isLogged
                          ? Colors.green.withOpacity(0.1)
                          : (canLogThisSet
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.surfaceContainer
                                  .withOpacity(isFutureSet ? 0.7 : 1.0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: setInfo.isLogged
                                ? Colors.green
                                : (canLogThisSet
                                    ? colorScheme.primary
                                    : colorScheme.outline.withOpacity(0.3)),
                            width:
                                setInfo.isLogged || canLogThisSet ? 1.5 : 1.0,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: setInfo.isLogged
                                  ? Colors.green
                                  : (canLogThisSet
                                      ? colorScheme.primary
                                      : colorScheme.secondaryContainer
                                          .withOpacity(
                                              isFutureSet ? 0.5 : 1.0)),
                              child: Text(
                                "${setInfo.setNumber}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: setInfo.isLogged || canLogThisSet
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: setInfo.weightController,
                                decoration: InputDecoration(
                                  labelText: "Weight (kg)",
                                  hintText: setInfo.targetWeightSuggestion
                                      .replaceAll('kg',
                                          ''), // Afficher la suggestion en hint
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                enabled: canLogThisSet,
                                style: TextStyle(
                                    color: canLogThisSet
                                        ? null
                                        : theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.6)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: setInfo.repsController,
                                decoration: InputDecoration(
                                  labelText: "Reps",
                                  hintText: setInfo
                                      .targetRepsInfo, // Afficher la suggestion en hint
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                keyboardType: TextInputType.number,
                                enabled: canLogThisSet,
                                style: TextStyle(
                                    color: canLogThisSet
                                        ? null
                                        : theme.textTheme.bodySmall?.color
                                            ?.withOpacity(0.6)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 40, // Espace pour l'icône
                              child: setInfo.isLogged
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green, size: 30)
                                  : (canLogThisSet
                                      ? IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.check_circle_outline,
                                              color: colorScheme.primary),
                                          iconSize: 30,
                                          onPressed: () => _logSet(index),
                                          tooltip: "Log Set",
                                        )
                                      : Icon(Icons.hourglass_empty_outlined,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.3),
                                          size: 28)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (allSetsManuallyLogged && !_isResting)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.done_all),
                    label: const Text("Next Exercise"),
                    onPressed: () {
                      // onExerciseCompleted est déjà appelé dans _logSet quand le dernier set est loggué.
                      // Ce bouton est une confirmation visuelle pour l'utilisateur.
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
