// lib/screens/exercise_logging_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart'; // For WorkoutSessionManager, LoggedExerciseData
import 'package:intl/intl.dart'; // For date formatting (e.g., logged set time)
import 'package:provider/provider.dart'; // For accessing WorkoutSessionManager

class ExerciseLoggingScreen extends StatefulWidget {
  final RoutineExercise exercise; // The specific exercise being logged
  final VoidCallback
      onExerciseCompleted; // Callback when this exercise is fully logged

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
  bool _isPopping =
      false; // Flag to prevent multiple pops if state changes rapidly

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();

    // Initialize fields after the first frame to ensure manager state is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still in the tree

      final manager =
          Provider.of<WorkoutSessionManager>(context, listen: false);

      // Validate if this screen is still relevant for the current exercise in the manager
      if (manager.isWorkoutActive &&
          manager.currentExercise?.id == widget.exercise.id &&
          manager.currentLoggedExerciseData?.originalExercise.id ==
              widget.exercise.id) {
        // If the exercise is not yet completed, initialize input fields
        if (!(manager.currentLoggedExerciseData?.isCompleted ?? false)) {
          _initializeFieldsForCurrentSet(manager);
        }
        // If it is completed, the build method will handle showing the "Completed" UI.
      } else if (mounted && !_isPopping && Navigator.canPop(context)) {
        // If the manager's state doesn't match this screen's exercise, pop back.
        // This can happen if the workout was ended or changed externally.
        print(
            "ExerciseLoggingScreen initState: Manager state mismatch. Popping. Manager Ex: ${manager.currentExercise?.name}, Screen Ex: ${widget.exercise.name}");
        _isPopping = true;
        Navigator.of(context).pop();
      }
    });
  }

  // Initializes the reps and weight input fields based on the current set's suggestions.
  void _initializeFieldsForCurrentSet(WorkoutSessionManager manager) {
    final RoutineExercise? exerciseToLogFrom =
        manager.currentExercise; // Should be non-null if called correctly
    final LoggedExerciseData? loggedData =
        manager.currentLoggedExerciseData; // Should be non-null

    if (exerciseToLogFrom == null || loggedData == null) {
      print(
          "ExerciseLoggingScreen _initializeFieldsForCurrentSet: exerciseToLogFrom or loggedData is null. Cannot initialize.");
      return;
    }

    final int setIndexToLog =
        manager.currentSetIndexForLogging; // 0-based index of the set to log

    // If exercise is completed or all sets are targeted, clear fields (or handle as completed)
    if (loggedData.isCompleted || setIndexToLog >= exerciseToLogFrom.sets) {
      _repsController.text = "";
      _weightController.text = "";
      return;
    }

    // --- Initialize Reps Field ---
    String repsSuggestion = exerciseToLogFrom.reps.trim();
    String initialRepsText = "";
    final RegExp repsRangeRegex =
        RegExp(r'^(\d+)\s*-\s*\d+'); // e.g., "8-12" -> extracts "8"
    final RegExp singleRepRegex =
        RegExp(r'^(\d+)$'); // e.g., "10" -> extracts "10"

    if (repsSuggestion.toLowerCase() == 'amrap' ||
        repsSuggestion.toLowerCase() == 'to failure' ||
        repsSuggestion == 'N/A') {
      initialRepsText = ""; // No specific rep suggestion
    } else if (repsRangeRegex.hasMatch(repsSuggestion)) {
      initialRepsText = repsRangeRegex.firstMatch(repsSuggestion)!.group(1)!;
    } else if (singleRepRegex.hasMatch(repsSuggestion)) {
      initialRepsText = singleRepRegex.firstMatch(repsSuggestion)!.group(1)!;
    }
    _repsController.text = initialRepsText;

    // --- Initialize Weight Field ---
    String weightSuggestion = exerciseToLogFrom.weightSuggestionKg.trim();
    String initialWeightText = "";
    if (weightSuggestion.toLowerCase() == 'bodyweight' ||
        weightSuggestion.toLowerCase() == 'bw' ||
        weightSuggestion == 'N/A' ||
        weightSuggestion.isEmpty) {
      initialWeightText =
          ""; // For bodyweight or no suggestion, leave field empty (implies 0 or user input)
    } else {
      // Try to extract a number, with or without "kg" at the end
      final RegExp weightRegex =
          RegExp(r'^(\d+(\.\d+)?)\s*(kg)?$', caseSensitive: false);
      final match = weightRegex.firstMatch(weightSuggestion);
      if (match != null) {
        initialWeightText = match.group(1)!; // Takes the numeric part
      }
      // If not N/A, empty, or a number (with optional kg), initialWeightText remains ""
    }
    _weightController.text = initialWeightText;
  }

  // Handles logging the current set's performance.
  void _handleLogSet(WorkoutSessionManager manager) {
    if (!mounted || _isPopping)
      return; // Prevent action if widget is disposed or already popping

    final LoggedExerciseData? currentLogData =
        manager.currentLoggedExerciseData;
    // Double-check manager state consistency before proceeding
    if (manager.currentExercise == null ||
        currentLogData == null ||
        manager.currentExercise!.id != widget.exercise.id ||
        currentLogData.originalExercise.id != widget.exercise.id) {
      print(
          "ExerciseLoggingScreen _handleLogSet: Manager state mismatch. Popping. Manager Ex: ${manager.currentExercise?.name}, Screen Ex: ${widget.exercise.name}");
      if (mounted && !_isPopping && Navigator.canPop(context)) {
        _isPopping = true;
        Navigator.of(context).pop();
      }
      return;
    }

    // If the exercise is already marked as completed by the manager, pop back
    if (currentLogData.isCompleted) {
      print(
          "ExerciseLoggingScreen _handleLogSet: Exercise already completed by manager. Popping.");
      widget.onExerciseCompleted(); // Notify parent
      if (mounted && !_isPopping && Navigator.canPop(context)) {
        _isPopping = true;
        Navigator.of(context).pop();
      }
      return;
    }

    final String reps = _repsController.text.trim();
    final String weightInput = _weightController.text.trim();
    String weightToLog = "0"; // Default to "0" if weight input is empty

    // Validate reps
    if (reps.isEmpty || int.tryParse(reps) == null || int.parse(reps) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Please enter a valid number of reps (> 0)."),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // Validate and parse weight
    if (weightInput.isNotEmpty) {
      if (double.tryParse(weightInput) != null &&
          double.parse(weightInput) >= 0) {
        weightToLog = double.parse(weightInput)
            .toString(); // Standardize numeric format (e.g., "50.0" or "50")
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              "Weight must be a valid number (e.g., 10 or 10.5) or empty for 0kg."),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
    }

    print(
        "ExerciseLoggingScreen _handleLogSet: Logging set - Reps: $reps, Weight: $weightToLog kg for ${manager.currentExercise?.name}");
    manager.logSetForCurrentExercise(
        reps, weightToLog); // This updates the manager's state

    // If the exercise is NOT completed after this set AND not currently resting, re-initialize fields for the next set.
    // The manager.logSetForCurrentExercise method handles starting rest if applicable.
    if (mounted &&
        !(manager.currentLoggedExerciseData?.isCompleted ?? true) &&
        !manager.isResting) {
      _initializeFieldsForCurrentSet(manager);
    }
    // If exercise is completed or rest started, the Consumer in build() will update UI.
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Formats rest time from seconds to MM:SS.
  String _formatRestTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Consumer to react to WorkoutSessionManager state changes
    return Consumer<WorkoutSessionManager>(
      builder: (consumerContext, manager, child) {
        final RoutineExercise? currentRoutineExFromManager =
            manager.currentExercise;
        final LoggedExerciseData? currentLoggedDataFromManager =
            manager.currentLoggedExerciseData;

        // If _isPopping is true, show a loading indicator to prevent UI flicker during pop.
        if (_isPopping) {
          return Scaffold(
              appBar: AppBar(
                  title: Text(widget
                      .exercise.name)), // Show exercise name while popping
              body: const Center(child: CircularProgressIndicator()));
        }

        // Safety check: If manager state is inconsistent with this screen, schedule a pop.
        // This is a fallback for edge cases.
        if (!manager.isWorkoutActive ||
            currentRoutineExFromManager == null ||
            currentLoggedDataFromManager == null ||
            currentRoutineExFromManager.id != widget.exercise.id ||
            currentLoggedDataFromManager.originalExercise.id !=
                widget.exercise.id) {
          print(
              "ExerciseLoggingScreen Consumer build: Manager state mismatch or workout inactive. Scheduling pop. Manager Ex: ${currentRoutineExFromManager?.name}, Screen Ex: ${widget.exercise.name}");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(consumerContext) && !_isPopping) {
              // Check if this screen is still the current route before popping
              if (ModalRoute.of(consumerContext)?.isCurrent ?? false) {
                print(
                    "ExerciseLoggingScreen Consumer build (callback): Popping due to state mismatch.");
                _isPopping = true;
                Navigator.pop(consumerContext);
              }
            }
          });
          // Show a temporary placeholder UI while popping
          return Scaffold(
              appBar: AppBar(title: Text(widget.exercise.name)),
              body: const Center(child: Text("Session updated, returning...")));
        }

        // At this point, manager state is consistent with widget.exercise
        final RoutineExercise exerciseToDisplay = currentRoutineExFromManager;
        final LoggedExerciseData loggedDataForThisExercise =
            currentLoggedDataFromManager;

        final int totalSetsInPlan = exerciseToDisplay.sets;
        final bool isThisExerciseCompletedByManager =
            loggedDataForThisExercise.isCompleted;
        // currentSetIndexForLogging is 0-based for the *next* set to be logged.
        final int setBeingLoggedDisplayNumber =
            manager.currentSetIndexForLogging + 1;

        // --- UI for Completed Exercise ---
        if (isThisExerciseCompletedByManager) {
          return Scaffold(
            appBar: AppBar(
                title: Text(exerciseToDisplay.name),
                automaticallyImplyLeading: false),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 80, color: Colors.green.shade600),
                    const SizedBox(height: 24),
                    Text("${exerciseToDisplay.name} Complete!",
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Text(
                        "${loggedDataForThisExercise.loggedSets.length} / $totalSetsInPlan sets logged.",
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 36),
                    ElevatedButton.icon(
                      icon:
                          const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      label: const Text("Continue Workout"),
                      onPressed: () {
                        widget.onExerciseCompleted(); // Call the callback
                        if (mounted &&
                            Navigator.canPop(consumerContext) &&
                            !_isPopping) {
                          print(
                              "ExerciseLoggingScreen Completed UI: Popping after exercise completion.");
                          _isPopping = true;
                          Navigator.pop(consumerContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          textStyle: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // --- UI for Logging Current Set or Resting ---
        return Scaffold(
          appBar: AppBar(
            title: Text(exerciseToDisplay.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Manually handle back press
                if (mounted &&
                    Navigator.canPop(consumerContext) &&
                    !_isPopping) {
                  print(
                      "ExerciseLoggingScreen AppBar: Back button pressed. Popping.");
                  _isPopping = true;
                  Navigator.pop(consumerContext);
                }
              },
            ),
          ),
          body: GestureDetector(
            // To dismiss keyboard on tap outside fields
            onTap: () => FocusScope.of(consumerContext).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Exercise Info Card ---
                  Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            setBeingLoggedDisplayNumber <= totalSetsInPlan
                                ? "Set $setBeingLoggedDisplayNumber of $totalSetsInPlan"
                                : "All $totalSetsInPlan sets targeted", // Should be caught by 'isCompleted' earlier
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Target: ${exerciseToDisplay.reps} @ ${exerciseToDisplay.weightSuggestionKg}",
                            style: theme.textTheme.titleSmall
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

                  // --- Rest Timer UI ---
                  if (manager.isResting)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: colorScheme
                          .surfaceContainerHighest, // A distinct background for rest
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text("REST",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text(
                              _formatRestTime(manager.restTimeRemainingSeconds),
                              style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary),
                            ),
                            const SizedBox(height: 16),
                            if (exerciseToDisplay.restBetweenSetsSeconds > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: LinearProgressIndicator(
                                  value: (exerciseToDisplay
                                              .restBetweenSetsSeconds >
                                          0)
                                      ? (manager.restTimeRemainingSeconds /
                                          exerciseToDisplay
                                              .restBetweenSetsSeconds)
                                      : 0,
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(6),
                                  backgroundColor: colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: manager.skipRest,
                              child: Text("Skip Rest",
                                  style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- Input Fields and Log Button (if not resting and sets remaining) ---
                  if (!manager.isResting &&
                      setBeingLoggedDisplayNumber <= totalSetsInPlan) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      // Changed to TextFormField for consistency and validation potential
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: "Weight (kg)",
                        hintText: exerciseToDisplay.weightSuggestionKg
                                        .replaceAll('kg', '')
                                        .trim() ==
                                    'N/A' ||
                                exerciseToDisplay.weightSuggestionKg
                                    .trim()
                                    .isEmpty
                            ? "e.g., 50 or 50.5"
                            : exerciseToDisplay.weightSuggestionKg
                                .replaceAll('kg', '')
                                .trim(),
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.fitness_center_outlined,
                            color: colorScheme.primary), // Changed icon
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      // validator: (value) { /* Add validation if needed */ },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
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
                        prefixIcon: Icon(Icons.replay_circle_filled_outlined,
                            color: colorScheme.primary), // Changed icon
                      ),
                      keyboardType: TextInputType.number,
                      // validator: (value) { /* Add validation if needed */ },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: Text("Log Set $setBeingLoggedDisplayNumber"),
                      onPressed: () => _handleLogSet(manager),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size(double.infinity, 52),
                          textStyle: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ],

                  // --- Display Logged Sets ---
                  if (loggedDataForThisExercise.loggedSets.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Text("Logged Sets:",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap:
                          true, // Important within a SingleChildScrollView
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable its own scrolling
                      itemCount: loggedDataForThisExercise.loggedSets.length,
                      itemBuilder: (ctx, index) {
                        final loggedSet =
                            loggedDataForThisExercise.loggedSets[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            dense: false, // Slightly more padding
                            leading: CircleAvatar(
                                backgroundColor: colorScheme.secondaryContainer,
                                radius: 18,
                                child: Text("${loggedSet.setNumber}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold))),
                            title: Text(
                              "Reps: ${loggedSet.performedReps}, Weight: ${loggedSet.performedWeightKg}${loggedSet.performedWeightKg == "0" || loggedSet.performedWeightKg.isEmpty ? "" : "kg"}",
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            trailing: Text(
                                DateFormat.jm().format(
                                    loggedSet.loggedAt), // e.g., 5:30 PM
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
