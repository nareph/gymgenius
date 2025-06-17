import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/repositories/workout_repository.dart';
import 'package:gymgenius/viewmodels/active_workout_viewmodel.dart';
import 'package:provider/provider.dart';

/// ActiveWorkoutSessionScreen: The main screen for an ongoing workout.
///
/// This widget is now a "dumb" component that primarily displays the state
/// from [WorkoutSessionManager]. It delegates all user actions (ending the workout,
/// logging an exercise) to an [ActiveWorkoutViewModel] instance, which contains
/// the business logic.
class ActiveWorkoutSessionScreen extends StatelessWidget {
  const ActiveWorkoutSessionScreen({super.key});

  /// Helper function to format a duration into a readable HH:MM:SS or MM:SS string.
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

  /// Determines if all exercises in the session have been marked as completed.
  bool _allExercisesEffectivelyCompleted(WorkoutSessionManager manager) {
    if (!manager.isWorkoutActive || manager.plannedExercises.isEmpty) {
      return false;
    }
    // Check if there is a logged entry for every planned exercise.
    if (manager.loggedExercisesData.length < manager.plannedExercises.length) {
      return false;
    }
    return manager.loggedExercisesData.every((exData) => exData.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    // We create the ViewModel here, providing it with the necessary dependencies from the context.
    // This ViewModel is short-lived and tied to this screen's lifecycle.
    final viewModel = ActiveWorkoutViewModel(
      sessionManager: context.read<WorkoutSessionManager>(),
      workoutRepository: context.read<WorkoutRepository>(),
      context: context, // Pass context for navigation and SnackBars
    );

    // The Consumer widget listens to changes in WorkoutSessionManager and rebuilds the UI.
    return Consumer<WorkoutSessionManager>(
      builder: (consumerContext, manager, child) {
        // --- Automatic Navigation Logic ---
        // If the workout is no longer active, navigate away from this screen.
        if (!manager.isWorkoutActive) {
          // Schedule a task to be run after the current build cycle is complete.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (consumerContext.mounted) {
              // Pop all routes until we get back to the first screen in the stack (usually MainDashboard).
              Navigator.of(consumerContext).popUntil((route) => route.isFirst);
            }
          });
          // Display a temporary loading screen while navigating away.
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Finalizing workout session..."),
                ],
              ),
            ),
          );
        }

        // --- Empty Workout State UI ---
        // If the workout started with no exercises.
        if (manager.plannedExercises.isEmpty) {
          return _buildEmptyWorkoutView(consumerContext, viewModel);
        }

        // --- Main Active Workout UI ---
        return _buildActiveWorkoutView(consumerContext, manager, viewModel);
      },
    );
  }

  /// Builds the UI for an active workout session with exercises.
  Widget _buildActiveWorkoutView(
    BuildContext context,
    WorkoutSessionManager manager,
    ActiveWorkoutViewModel viewModel,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Determine the visually highlighted exercise.
    int visuallyHighlightedIndex =
        manager.loggedExercisesData.indexWhere((ex) => !ex.isCompleted);
    if (visuallyHighlightedIndex == -1) {
      visuallyHighlightedIndex = manager.completedExercisesCount;
    }

    final bool allDone = _allExercisesEffectivelyCompleted(manager);

    // Determine the text for the "Next Up" banner.
    String nextUpText;
    if (allDone) {
      nextUpText = "Workout Complete! Press Finish.";
    } else if (visuallyHighlightedIndex < manager.plannedExercises.length) {
      nextUpText =
          "Next Up: ${manager.plannedExercises[visuallyHighlightedIndex].name}";
    } else {
      nextUpText = "Ready to log!";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(manager.currentWorkoutName),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _formatDuration(manager.currentWorkoutDuration),
                style: textTheme.titleMedium?.copyWith(
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
          // "Next Up" Banner
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            color: colorScheme.surfaceContainerHighest.withAlpha(77),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(nextUpText,
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis)),
                Text(
                    "${manager.completedExercisesCount} / ${manager.totalExercises} done"),
              ],
            ),
          ),
          // List of exercises
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: manager.plannedExercises.length,
              itemBuilder: (listContext, index) {
                final plannedExercise = manager.plannedExercises[index];
                final loggedData = manager.loggedExercisesData[index];
                final isCompleted = loggedData.isCompleted;
                final isCurrent = index == visuallyHighlightedIndex && !allDone;

                return ExerciseTile(
                  exercise: plannedExercise,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  index: index,
                  onTap: () => viewModel.navigateToLogExercise(index),
                );
              },
            ),
          ),
          // "End Workout" Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
            child: _EndWorkoutButton(
              allExercisesCompleted: allDone,
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (dialogContext) =>
                      _buildEndWorkoutDialog(dialogContext, allDone),
                ).then((confirmed) {
                  if (confirmed == true) {
                    viewModel.endWorkout();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UI for when a workout session is started with no exercises.
  Widget _buildEmptyWorkoutView(
      BuildContext context, ActiveWorkoutViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text("Empty Workout")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.playlist_remove_rounded,
                size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Text("This workout has no exercises.",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text("End Empty Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              onPressed: viewModel.endWorkout,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the confirmation dialog for ending a workout.
  AlertDialog _buildEndWorkoutDialog(BuildContext context, bool allDone) {
    return AlertDialog(
      title: const Text('Confirm End Workout'),
      content: Text(allDone
          ? 'Well done! Ready to save this session?'
          : 'Are you sure you want to end the workout early? Any completed exercises will be saved.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            allDone ? 'Finish & Save' : 'End Early',
            style: TextStyle(
                color: allDone
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}

/// A stateless widget for the "End Workout" button to keep the build method cleaner.
class _EndWorkoutButton extends StatelessWidget {
  final bool allExercisesCompleted;
  final VoidCallback onPressed;

  const _EndWorkoutButton(
      {required this.allExercisesCompleted, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(allExercisesCompleted
          ? Icons.save_alt_rounded
          : Icons.stop_circle_outlined),
      label: Text(allExercisesCompleted
          ? "FINISH & SAVE WORKOUT"
          : "END WORKOUT EARLY"),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: allExercisesCompleted
            ? Colors.green.shade600
            : Theme.of(context).colorScheme.errorContainer,
        foregroundColor: allExercisesCompleted
            ? Colors.white
            : Theme.of(context).colorScheme.onErrorContainer,
        minimumSize: const Size(double.infinity, 52),
      ),
    );
  }
}

/// A stateless widget for displaying a single exercise in the list.
class ExerciseTile extends StatelessWidget {
  final RoutineExercise exercise;
  final bool isCompleted;
  final bool isCurrent;
  final int index;
  final VoidCallback onTap;

  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.isCompleted,
    required this.isCurrent,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String setsRepsInfo = "${exercise.sets} sets × ${exercise.reps} reps";
    if (exercise.weightSuggestionKg.isNotEmpty &&
        !['n/a', 'bodyweight']
            .contains(exercise.weightSuggestionKg.toLowerCase())) {
      setsRepsInfo += " @ ${exercise.weightSuggestionKg}kg";
    } else if (exercise.weightSuggestionKg.toLowerCase() == 'bodyweight') {
      setsRepsInfo += " (Bodyweight)";
    }

    return Card(
      elevation: isCurrent ? 4.0 : (isCompleted ? 0.5 : 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withAlpha(153)
              : (isCurrent
                  ? theme.colorScheme.primary.withAlpha(204)
                  : theme.colorScheme.outlineVariant.withAlpha(100)),
          width: isCurrent ? 2.0 : 1.2,
        ),
      ),
      color: isCompleted
          ? theme.colorScheme.surfaceContainer.withAlpha(100)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? Colors.green.shade600
              : (isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondaryContainer),
          child: isCompleted
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
              : Text("${index + 1}",
                  style: TextStyle(
                      color: isCurrent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSecondaryContainer)),
        ),
        title: Text(
          exercise.name,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? theme.colorScheme.onSurfaceVariant.withAlpha(153)
                : null,
          ),
        ),
        subtitle: Text(setsRepsInfo,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        trailing: isCompleted
            ? null
            : Icon(
                isCurrent
                    ? Icons.edit_note_rounded
                    : Icons.play_circle_outline_rounded,
                color: theme.colorScheme.primary),
        onTap: isCompleted ? null : onTap,
      ),
    );
  }
}
