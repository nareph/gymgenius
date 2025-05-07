// lib/screens/exercise_logging_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final manager =
          Provider.of<WorkoutSessionManager>(context, listen: false);

      if (manager.isWorkoutActive &&
          manager.currentExercise?.id == widget.exercise.id &&
          manager.currentLoggedExerciseData?.originalExercise.id ==
              widget.exercise.id) {
        if (!(manager.currentLoggedExerciseData?.isCompleted ?? false)) {
          _initializeFieldsForCurrentSet(manager);
        }
      } else if (mounted && !_isPopping && Navigator.canPop(context)) {
        _isPopping = true;
        Navigator.of(context).pop();
      }
    });
  }

  void _initializeFieldsForCurrentSet(WorkoutSessionManager manager) {
    final RoutineExercise exerciseToLogFrom = manager.currentExercise!;
    final LoggedExerciseData loggedData = manager.currentLoggedExerciseData!;
    final int setIndexToLog = manager.currentSetIndexForLogging;

    if (loggedData.isCompleted || setIndexToLog >= exerciseToLogFrom.sets) {
      _repsController.text = "";
      _weightController.text = "";
      return;
    }

    String repsSuggestion = exerciseToLogFrom.reps.trim();
    String initialRepsText = "";
    final RegExp repsRangeRegex = RegExp(r'^(\d+)\s*-\s*\d+');
    final RegExp singleRepRegex = RegExp(r'^(\d+)$');

    if (repsSuggestion.toLowerCase() == 'amrap' ||
        repsSuggestion.toLowerCase() == 'to failure' ||
        repsSuggestion == 'N/A') {
      initialRepsText = "";
    } else if (repsRangeRegex.hasMatch(repsSuggestion)) {
      initialRepsText = repsRangeRegex.firstMatch(repsSuggestion)!.group(1)!;
    } else if (singleRepRegex.hasMatch(repsSuggestion)) {
      initialRepsText = singleRepRegex.firstMatch(repsSuggestion)!.group(1)!;
    }
    _repsController.text = initialRepsText;

    String weightSuggestion = exerciseToLogFrom.weightSuggestionKg.trim();
    String initialWeightText = "";
    if (weightSuggestion == 'N/A' || weightSuggestion.isEmpty) {
      // Plus de logique Bodyweight/BW
      initialWeightText = "";
    } else {
      // Essayer d'extraire un nombre, avec ou sans "kg" à la fin
      final RegExp weightRegex = RegExp(r'^(\d+(\.\d+)?)\s*(kg)?$');
      final match = weightRegex.firstMatch(weightSuggestion);
      if (match != null) {
        initialWeightText = match.group(1)!; // Prend le nombre
      }
      // Si ce n'est pas N/A, vide, ou un nombre (avec optionnel kg), initialWeightText reste ""
    }
    _weightController.text = initialWeightText;
  }

  void _handleLogSet(WorkoutSessionManager manager) {
    if (!mounted || _isPopping) return;

    final LoggedExerciseData? currentLogData =
        manager.currentLoggedExerciseData;
    if (manager.currentExercise == null ||
        currentLogData == null ||
        manager.currentExercise!.id != widget.exercise.id ||
        currentLogData.originalExercise.id != widget.exercise.id) {
      if (mounted && !_isPopping && Navigator.canPop(context)) {
        _isPopping = true;
        Navigator.of(context).pop();
      }
      return;
    }

    if (currentLogData.isCompleted) {
      widget.onExerciseCompleted();
      if (mounted && !_isPopping && Navigator.canPop(context)) {
        _isPopping = true;
        Navigator.of(context).pop();
      }
      return;
    }

    final String reps = _repsController.text.trim();
    final String weightInput = _weightController.text.trim();
    String weightToLog = "0"; // Par défaut si vide

    if (reps.isEmpty || int.tryParse(reps) == null || int.parse(reps) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid number of reps (> 0)."),
          backgroundColor: Colors.red));
      return;
    }

    if (weightInput.isNotEmpty) {
      // Le poids doit être un nombre positif ou zéro
      if (double.tryParse(weightInput) != null &&
          double.parse(weightInput) >= 0) {
        weightToLog = double.parse(weightInput)
            .toString(); // Standardise le format numérique
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Weight must be a valid number (e.g., 10 or 10.5) or empty for 0kg."),
            backgroundColor: Colors.red));
        return;
      }
    }

    manager.logSetForCurrentExercise(reps, weightToLog);

    if (mounted &&
        !(manager.currentLoggedExerciseData?.isCompleted ?? true) &&
        !manager.isResting) {
      _initializeFieldsForCurrentSet(manager);
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
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

    return Consumer<WorkoutSessionManager>(
      builder: (context, manager, child) {
        final RoutineExercise? currentRoutineExFromManager =
            manager.currentExercise;
        final LoggedExerciseData? currentLoggedDataFromManager =
            manager.currentLoggedExerciseData;

        if (_isPopping) {
          return Scaffold(
              appBar: AppBar(title: Text(widget.exercise.name)),
              body: const Center(child: CircularProgressIndicator()));
        }

        if (!manager.isWorkoutActive ||
            currentRoutineExFromManager == null ||
            currentLoggedDataFromManager == null ||
            currentRoutineExFromManager.id != widget.exercise.id ||
            currentLoggedDataFromManager.originalExercise.id !=
                widget.exercise.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context) && !_isPopping) {
              if (ModalRoute.of(context)?.isCurrent ?? false) {
                _isPopping = true;
                Navigator.pop(context);
              }
            }
          });
          return Scaffold(
              appBar: AppBar(title: Text(widget.exercise.name)),
              body: const Center(child: Text("Session updated, returning...")));
        }

        final RoutineExercise exerciseToDisplay = currentRoutineExFromManager;
        final LoggedExerciseData loggedDataForThisExercise =
            currentLoggedDataFromManager;

        final int totalSetsInPlan = exerciseToDisplay.sets;
        final bool isThisExerciseCompletedByManager =
            loggedDataForThisExercise.isCompleted;
        final int setBeingLoggedIndex = manager.currentSetIndexForLogging;

        if (isThisExerciseCompletedByManager) {
          return Scaffold(
            appBar: AppBar(
                title: Text(exerciseToDisplay.name),
                automaticallyImplyLeading: false),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 80, color: Colors.green),
                    const SizedBox(height: 24),
                    Text("${exerciseToDisplay.name} Complete!",
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                        "${loggedDataForThisExercise.loggedSets.length} / $totalSetsInPlan sets logged.",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.colorScheme.outline)),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      label: const Text("Continue Workout"),
                      onPressed: () {
                        widget.onExerciseCompleted();
                        if (mounted &&
                            Navigator.canPop(context) &&
                            !_isPopping) {
                          _isPopping = true;
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          textStyle: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(exerciseToDisplay.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (mounted && Navigator.canPop(context) && !_isPopping) {
                  _isPopping = true;
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            setBeingLoggedIndex < totalSetsInPlan
                                ? "Set ${setBeingLoggedIndex + 1} of $totalSetsInPlan"
                                : "All $totalSetsInPlan sets targeted",
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Target: ${exerciseToDisplay.reps} @ ${exerciseToDisplay.weightSuggestionKg}",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          if (exerciseToDisplay.restBetweenSetsSeconds > 0 &&
                              loggedDataForThisExercise.loggedSets.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                "(Rest after set: ${exerciseToDisplay.restBetweenSetsSeconds} sec)",
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (exerciseToDisplay.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Divider(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text("Notes:",
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(exerciseToDisplay.description,
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.start),
                          ]
                        ],
                      ),
                    ),
                  ),
                  if (manager.isResting)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text("REST",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              _formatRestTime(manager.restTimeRemainingSeconds),
                              style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary),
                            ),
                            const SizedBox(height: 12),
                            if (exerciseToDisplay.restBetweenSetsSeconds > 0)
                              LinearProgressIndicator(
                                value:
                                    (exerciseToDisplay.restBetweenSetsSeconds >
                                            0)
                                        ? (manager.restTimeRemainingSeconds /
                                            exerciseToDisplay
                                                .restBetweenSetsSeconds)
                                        : 0,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                                backgroundColor: colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary),
                              ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: manager.skipRest,
                              child: Text("Skip Rest",
                                  style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!manager.isResting &&
                      setBeingLoggedIndex < totalSetsInPlan) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: "Weight (kg)", // Modifié
                        hintText: exerciseToDisplay.weightSuggestionKg
                                        .replaceAll('kg', '')
                                        .trim() ==
                                    'N/A' ||
                                exerciseToDisplay.weightSuggestionKg
                                    .trim()
                                    .isEmpty
                            ? "e.g., 50.5" // Modifié
                            : exerciseToDisplay.weightSuggestionKg
                                .replaceAll('kg', '')
                                .trim(),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.scale_outlined,
                            color: colorScheme.primary),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true), // Strictement numérique
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _repsController,
                      decoration: InputDecoration(
                        labelText: "Reps",
                        hintText:
                            exerciseToDisplay.reps.toLowerCase() == 'amrap'
                                ? 'As Many As Possible'
                                : exerciseToDisplay.reps,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.repeat_one_outlined,
                            color: colorScheme.primary),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text("Log Set ${setBeingLoggedIndex + 1}"),
                      onPressed: () => _handleLogSet(manager),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ],
                  if (loggedDataForThisExercise.loggedSets.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Text("Logged Sets:",
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: loggedDataForThisExercise.loggedSets.length,
                      itemBuilder: (ctx, index) {
                        final loggedSet =
                            loggedDataForThisExercise.loggedSets[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            dense: false,
                            leading: CircleAvatar(
                                backgroundColor: colorScheme.secondaryContainer,
                                radius: 18,
                                child: Text("${loggedSet.setNumber}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold))),
                            title: Text(
                              // Afficher "kg" seulement si ce n'est pas "0" (qui signifie vide/non applicable)
                              "Reps: ${loggedSet.performedReps}, Weight: ${loggedSet.performedWeightKg}${loggedSet.performedWeightKg == "0" ? "" : "kg"}",
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            trailing: Text(
                                DateFormat.jm().format(loggedSet.loggedAt),
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: colorScheme.outline)),
                          ),
                        );
                      },
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
