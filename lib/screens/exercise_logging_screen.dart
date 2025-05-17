// lib/screens/exercise_logging_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise
import 'package:gymgenius/providers/workout_session_manager.dart'; // For WorkoutSessionManager
import 'package:gymgenius/services/logger_service.dart'; // Import the logger service
import 'package:intl/intl.dart'; // For DateFormat
import 'package:provider/provider.dart'; // For Consumer

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

class _ExerciseLoggingScreenState extends State<ExerciseLoggingScreen>
    with TickerProviderStateMixin {
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  bool _isPopping = false;

  Timer? _exerciseTimer;
  int _currentExerciseRunDownSeconds = 0;
  int _userSetTargetDurationSeconds = 0;
  bool _isExerciseTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _weightController = TextEditingController();
    _minutesController = TextEditingController();
    _secondsController = TextEditingController();

    final manager = Provider.of<WorkoutSessionManager>(context, listen: false);

    if (widget.exercise.isTimed) {
      if (widget.exercise.targetDurationSeconds != null &&
          widget.exercise.targetDurationSeconds! > 0) {
        _userSetTargetDurationSeconds = widget.exercise.targetDurationSeconds!;
      } else {
        _userSetTargetDurationSeconds = 30;
      }
      _minutesController.text =
          (_userSetTargetDurationSeconds ~/ 60).toString();
      _secondsController.text =
          (_userSetTargetDurationSeconds % 60).toString().padLeft(2, '0');
      _currentExerciseRunDownSeconds = _userSetTargetDurationSeconds;
      manager.resetExerciseTimeUpSoundFlag();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  int _parseDurationFromInputs() {
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(_secondsController.text.trim()) ?? 0;
    if (minutes < 0 || seconds < 0 || seconds > 59) {
      return _userSetTargetDurationSeconds > 0
          ? _userSetTargetDurationSeconds
          : 0;
    }
    return (minutes * 60) + seconds;
  }

  void _initializeFieldsForCurrentSet(WorkoutSessionManager manager) {
    final RoutineExercise? exerciseToLogFrom = manager.currentExercise;
    final LoggedExerciseData? loggedData = manager.currentLoggedExerciseData;

    if (exerciseToLogFrom == null || loggedData == null) return;

    if (loggedData.isCompleted ||
        manager.currentSetIndexForLogging >= exerciseToLogFrom.sets) {
      _repsController.text = "";
      _weightController.text = "";
      if (exerciseToLogFrom.isTimed) {
        _userSetTargetDurationSeconds =
            (exerciseToLogFrom.targetDurationSeconds != null &&
                    exerciseToLogFrom.targetDurationSeconds! > 0)
                ? exerciseToLogFrom.targetDurationSeconds!
                : _userSetTargetDurationSeconds > 0
                    ? _userSetTargetDurationSeconds
                    : 30;

        _minutesController.text =
            (_userSetTargetDurationSeconds ~/ 60).toString();
        _secondsController.text =
            (_userSetTargetDurationSeconds % 60).toString().padLeft(2, '0');
        _currentExerciseRunDownSeconds = _userSetTargetDurationSeconds;
        _isExerciseTimerRunning = false;
      } else {
        _minutesController.text = "";
        _secondsController.text = "";
      }
      if (mounted) setState(() {});
      return;
    }

    if (exerciseToLogFrom.isTimed) {
      manager.resetExerciseTimeUpSoundFlag();
      if (manager.currentSetIndexForLogging == 0 &&
          loggedData.loggedSets.isEmpty) {
        _userSetTargetDurationSeconds =
            (exerciseToLogFrom.targetDurationSeconds != null &&
                    exerciseToLogFrom.targetDurationSeconds! > 0)
                ? exerciseToLogFrom.targetDurationSeconds!
                : _userSetTargetDurationSeconds > 0
                    ? _userSetTargetDurationSeconds
                    : 30;
      }
      _minutesController.text =
          (_userSetTargetDurationSeconds ~/ 60).toString();
      _secondsController.text =
          (_userSetTargetDurationSeconds % 60).toString().padLeft(2, '0');
      _currentExerciseRunDownSeconds = _userSetTargetDurationSeconds;
      _isExerciseTimerRunning = false;
      _repsController.text = "";
      _weightController.text = "";
    } else {
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

      if (exerciseToLogFrom.usesWeight) {
        String weightSuggestion = exerciseToLogFrom.weightSuggestionKg.trim();
        String initialWeightText = "";
        if (weightSuggestion.toLowerCase() == 'bodyweight' ||
            weightSuggestion.toLowerCase() == 'bw' ||
            weightSuggestion == 'N/A' ||
            weightSuggestion.isEmpty) {
          initialWeightText = "";
        } else {
          final RegExp weightRegex =
              RegExp(r'^(\d+(\.\d+)?)\s*(kg)?$', caseSensitive: false);
          final match = weightRegex.firstMatch(weightSuggestion);
          if (match != null) {
            initialWeightText = match.group(1)!;
          }
        }
        _weightController.text = initialWeightText;
      } else {
        _weightController.text = "";
      }
      _minutesController.text = "";
      _secondsController.text = "";
    }
    if (mounted) setState(() {});
  }

  void _startOrStopExerciseTimer(WorkoutSessionManager manager) {
    if (!widget.exercise.isTimed) return;
    FocusScope.of(context).unfocus();

    if (_isExerciseTimerRunning) {
      _exerciseTimer?.cancel();
      _isExerciseTimerRunning = false;
      int durationPerformed =
          _userSetTargetDurationSeconds - _currentExerciseRunDownSeconds;
      if (durationPerformed < 0) durationPerformed = 0;
      if (mounted) setState(() {});
      Log.debug(
          "ELS: Timer stopped by user. Duration performed: $durationPerformed s. Target for set: $_userSetTargetDurationSeconds s");
      manager.logSetForCurrentExercise(durationPerformed.toString(), "0");
      if (mounted &&
          !(manager.currentLoggedExerciseData?.isCompleted ?? true) &&
          !manager.isResting) {
        _initializeFieldsForCurrentSet(manager);
      }
    } else {
      final String minText = _minutesController.text.trim();
      final String secText = _secondsController.text.trim();

      if (minText.isEmpty && secText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter a duration.")));
        }
        return;
      }

      final int minutes = int.tryParse(minText) ?? 0;
      final int seconds = int.tryParse(secText) ?? 0;

      if (minutes < 0 || seconds < 0 || seconds > 59) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Invalid duration. Seconds must be 0-59.")));
        }
        return;
      }
      final int newTargetDurationFromInput = (minutes * 60) + seconds;

      if (newTargetDurationFromInput <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Please enter a valid target duration greater than 0 seconds.")));
        }
        return;
      }
      _userSetTargetDurationSeconds = newTargetDurationFromInput;
      _currentExerciseRunDownSeconds = _userSetTargetDurationSeconds;
      _isExerciseTimerRunning = true;
      manager.resetExerciseTimeUpSoundFlag();
      if (mounted) setState(() {});

      _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          _isExerciseTimerRunning = false;
          return;
        }
        if (_currentExerciseRunDownSeconds > 0) {
          if (mounted) setState(() => _currentExerciseRunDownSeconds--);
        } else {
          _exerciseTimer?.cancel();
          _isExerciseTimerRunning = false;
          manager.playExerciseTimeUpSound();
          if (mounted) setState(() {});
          Log.debug(
              "ELS: Timer finished. Logging target duration: $_userSetTargetDurationSeconds s.");
          manager.logSetForCurrentExercise(
              _userSetTargetDurationSeconds.toString(), "0");
          if (mounted &&
              !(manager.currentLoggedExerciseData?.isCompleted ?? true) &&
              !manager.isResting) {
            _initializeFieldsForCurrentSet(manager);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Time's up! Set logged."),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating));
          }
        }
      });
    }
  }

  void _handleLogSet(WorkoutSessionManager manager) {
    if (!mounted || _isPopping) return;
    FocusScope.of(context).unfocus();

    if (widget.exercise.isTimed) {
      Log.error(
          "ELS _handleLogSet: Error - This method is for rep-based exercises.");
      return;
    }
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

    final String reps = _repsController.text.trim();
    final String weightInput = _weightController.text.trim();
    String weightToLog = "0";

    if (reps.isEmpty || int.tryParse(reps) == null || int.parse(reps) < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                const Text("Please enter valid reps (a non-negative number)."),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
      return;
    }

    if (widget.exercise.usesWeight) {
      if (weightInput.isNotEmpty) {
        final parsedWeight = double.tryParse(weightInput);
        if (parsedWeight != null && parsedWeight >= 0) {
          weightToLog = parsedWeight.toStringAsFixed(2);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    "Weight must be a valid number (e.g., 50 or 50.5), or empty for 0kg."),
                backgroundColor: Theme.of(context).colorScheme.error));
          }
          return;
        }
      }
    } else {
      weightToLog = "N/A";
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
    _minutesController.dispose();
    _secondsController.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  String _formatDurationForTimerDisplay(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<WorkoutSessionManager>(
      builder: (consumerContext, manager, child) {
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
            if (mounted && Navigator.canPop(consumerContext) && !_isPopping) {
              if (ModalRoute.of(consumerContext)?.isCurrent ?? false) {
                _isPopping = true;
                Navigator.pop(consumerContext);
              }
            }
          });
          return Scaffold(
              appBar: AppBar(title: Text(widget.exercise.name)),
              body:
                  const Center(child: Text("Finalizing exercise logging...")));
        }

        final RoutineExercise exerciseToDisplay = currentRoutineExFromManager;
        final LoggedExerciseData loggedDataForThisExercise =
            currentLoggedDataFromManager;
        final int totalSetsInPlan = exerciseToDisplay.sets;
        final bool isThisExerciseCompletedByManager =
            loggedDataForThisExercise.isCompleted;
        final int setBeingLoggedDisplayNumber =
            manager.currentSetIndexForLogging + 1;

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
                          style: textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text(
                          "${loggedDataForThisExercise.loggedSets.length} / $totalSetsInPlan sets logged.",
                          style: textTheme.titleMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 36),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 18),
                        label: const Text("Continue Workout"),
                        onPressed: () {
                          widget.onExerciseCompleted();
                          if (mounted &&
                              Navigator.canPop(consumerContext) &&
                              !_isPopping) {
                            _isPopping = true;
                            Navigator.pop(consumerContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            textStyle: textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ]),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(exerciseToDisplay.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (_isExerciseTimerRunning) {
                  showDialog(
                      context: consumerContext,
                      builder: (dialogCtx) => AlertDialog(
                            title: const Text("Timer Running"),
                            content: const Text(
                                "A timer is active. Are you sure you want to go back? The current timed set won't be logged automatically if you stop it now."),
                            actions: [
                              TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.pop(dialogCtx)),
                              TextButton(
                                  child: Text("Go Back",
                                      style: TextStyle(
                                          color: theme.colorScheme.error)),
                                  onPressed: () {
                                    Navigator.pop(dialogCtx);
                                    _exerciseTimer?.cancel();
                                    _isExerciseTimerRunning = false;
                                    if (mounted &&
                                        Navigator.canPop(consumerContext) &&
                                        !_isPopping) {
                                      _isPopping = true;
                                      Navigator.pop(consumerContext);
                                    }
                                  }),
                            ],
                          ));
                } else {
                  if (mounted &&
                      Navigator.canPop(consumerContext) &&
                      !_isPopping) {
                    _isPopping = true;
                    Navigator.pop(consumerContext);
                  }
                }
              },
            ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(consumerContext).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    setBeingLoggedDisplayNumber <=
                                            totalSetsInPlan
                                        ? "Set $setBeingLoggedDisplayNumber of $totalSetsInPlan"
                                        : "Logging Extra Set (Beyond $totalSetsInPlan planned)",
                                    style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    exerciseToDisplay.isTimed
                                        ? "Target Duration: ${_formatDurationForTimerDisplay(_userSetTargetDurationSeconds)}"
                                        : "Target: ${exerciseToDisplay.reps} ${exerciseToDisplay.usesWeight && exerciseToDisplay.weightSuggestionKg.isNotEmpty && exerciseToDisplay.weightSuggestionKg.toLowerCase() != 'n/a' && exerciseToDisplay.weightSuggestionKg.toLowerCase() != 'bodyweight' ? '@ ${exerciseToDisplay.weightSuggestionKg}kg' : (exerciseToDisplay.weightSuggestionKg.toLowerCase() == 'bodyweight' ? '(Bodyweight)' : '')}",
                                    style: textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (exerciseToDisplay.restBetweenSetsSeconds >
                                          0 &&
                                      loggedDataForThisExercise
                                          .loggedSets.isNotEmpty &&
                                      setBeingLoggedDisplayNumber <=
                                          totalSetsInPlan)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                          "(Rest after set: ${exerciseToDisplay.restBetweenSetsSeconds} sec)",
                                          style: textTheme.bodySmall?.copyWith(
                                              color: colorScheme.outline)),
                                    ),
                                ],
                              ),
                            ),
                            if (exerciseToDisplay.description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Divider(
                                  color: colorScheme.outlineVariant
                                      .withAlpha((128).round())),
                              const SizedBox(height: 12),
                              Text("How to Perform:",
                                  style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Text(
                                exerciseToDisplay.description
                                    .replaceAll("\\n", "\n\n"),
                                style: textTheme.bodyMedium?.copyWith(
                                    height: 1.5, color: colorScheme.onSurface),
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: colorScheme.outline
                                            .withAlpha((77).round()))),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.lightbulb_outline_rounded,
                                        size: 22, color: colorScheme.secondary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Tip: For a visual guide on \"${exerciseToDisplay.name}\", search online. Proper form is key!",
                                        style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                            ]
                          ]),
                    ),
                  ),
                  if (manager.isResting)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: [
                          Text("REST",
                              style: textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                              _formatDurationForTimerDisplay(
                                  manager.restTimeRemainingSeconds),
                              style: textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary)),
                          const SizedBox(height: 16),
                          if (manager.currentRestTotalSeconds > 0)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: LinearProgressIndicator(
                                value: manager.currentRestTotalSeconds > 0
                                    ? (manager.restTimeRemainingSeconds
                                            .toDouble() /
                                        manager.currentRestTotalSeconds
                                            .toDouble())
                                    : 0.0,
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
                                      fontSize: 16))),
                        ]),
                      ),
                    ),
                  if (!manager.isResting &&
                      (setBeingLoggedDisplayNumber <= totalSetsInPlan ||
                          !exerciseToDisplay.isTimed)) ...[
                    const SizedBox(height: 10),
                    if (exerciseToDisplay.isTimed) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minutesController,
                              decoration: InputDecoration(
                                labelText: "Minutes",
                                hintText: "MM",
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                prefixIcon: Icon(Icons.hourglass_top_rounded,
                                    color: colorScheme.primary),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2)
                              ],
                              textAlign: TextAlign.center,
                              enabled: !_isExerciseTimerRunning,
                              onChanged: (value) {
                                if (!_isExerciseTimerRunning) {
                                  _userSetTargetDurationSeconds =
                                      _parseDurationFromInputs();
                                  setState(() {
                                    _currentExerciseRunDownSeconds =
                                        _userSetTargetDurationSeconds;
                                  });
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            child: Text(":",
                                style: textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _secondsController,
                              decoration: InputDecoration(
                                labelText: "Seconds",
                                hintText: "SS",
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                prefixIcon: Icon(Icons.hourglass_bottom_rounded,
                                    color: colorScheme.primary),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2)
                              ],
                              textAlign: TextAlign.center,
                              enabled: !_isExerciseTimerRunning,
                              onChanged: (value) {
                                if (!_isExerciseTimerRunning) {
                                  _userSetTargetDurationSeconds =
                                      _parseDurationFromInputs();
                                  setState(() {
                                    _currentExerciseRunDownSeconds =
                                        _userSetTargetDurationSeconds;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final s = int.tryParse(value);
                                  if (s == null || s < 0 || s > 59) {
                                    return '0-59';
                                  }
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                          _formatDurationForTimerDisplay(
                              _currentExerciseRunDownSeconds),
                          textAlign: TextAlign.center,
                          style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isExerciseTimerRunning
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      if (_userSetTargetDurationSeconds > 0 &&
                          _isExerciseTimerRunning)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: LinearProgressIndicator(
                              value: (_userSetTargetDurationSeconds > 0)
                                  ? (_userSetTargetDurationSeconds -
                                              _currentExerciseRunDownSeconds)
                                          .toDouble() /
                                      _userSetTargetDurationSeconds.toDouble()
                                  : 0.0,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary)),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(
                            _isExerciseTimerRunning
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline_rounded,
                            size: 24),
                        label: Text(_isExerciseTimerRunning
                            ? "Stop & Log Time"
                            : "Start Timer"),
                        onPressed: () => _startOrStopExerciseTimer(manager),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _isExerciseTimerRunning
                                ? colorScheme.error
                                : colorScheme.primary,
                            foregroundColor: _isExerciseTimerRunning
                                ? colorScheme.onError
                                : colorScheme.onPrimary,
                            minimumSize: const Size(double.infinity, 52),
                            textStyle: textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      if (exerciseToDisplay.usesWeight) ...[
                        TextFormField(
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
                                prefixIcon: Icon(Icons.fitness_center_rounded,
                                    color: colorScheme.primary)),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true)),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                          controller: _repsController,
                          decoration: InputDecoration(
                              labelText: "Reps",
                              hintText: exerciseToDisplay.reps.toLowerCase() ==
                                      'amrap'
                                  ? 'As Many As Possible'
                                  : exerciseToDisplay.reps,
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(
                                  Icons.replay_circle_filled_rounded,
                                  color: colorScheme.primary)),
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 20),
                        label: Text(
                            setBeingLoggedDisplayNumber <= totalSetsInPlan
                                ? "Log Set $setBeingLoggedDisplayNumber"
                                : "Log Extra Set"),
                        onPressed: () => _handleLogSet(manager),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: const Size(double.infinity, 52),
                            textStyle: textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                  if (loggedDataForThisExercise.loggedSets.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Text("Logged Sets for ${exerciseToDisplay.name}:",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                            dense: true,
                            leading: CircleAvatar(
                                backgroundColor: colorScheme.secondaryContainer,
                                radius: 18,
                                child: Text("${loggedSet.setNumber}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold))),
                            title: Text(
                              exerciseToDisplay.isTimed
                                  ? "Duration: ${loggedSet.performedReps}s"
                                  : "Reps: ${loggedSet.performedReps}, Weight: ${loggedSet.performedWeightKg}${loggedSet.performedWeightKg.toLowerCase() == "n/a" || loggedSet.performedWeightKg == "0" || loggedSet.performedWeightKg.isEmpty ? "" : "kg"}",
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            trailing: Text(
                                DateFormat.jm().format(loggedSet.loggedAt),
                                style: textTheme.bodySmall
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
