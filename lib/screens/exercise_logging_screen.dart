import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/models/workout_log.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/viewmodels/exercise_logging_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Provides the necessary ViewModel for the ExerciseLoggingView.
class ExerciseLoggingScreen extends StatelessWidget {
  final RoutineExercise exercise;
  final VoidCallback onExerciseCompleted;

  const ExerciseLoggingScreen({
    super.key,
    required this.exercise,
    required this.onExerciseCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExerciseLoggingViewModel(
        sessionManager: context.read<WorkoutSessionManager>(),
        exercise: exercise,
      ),
      child: const ExerciseLoggingView(),
    );
  }
}

/// The core UI of the logging screen, now driven by ViewModels.
class ExerciseLoggingView extends StatelessWidget {
  const ExerciseLoggingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the session manager for real-time updates on workout state.
    final manager = context.watch<WorkoutSessionManager>();
    // Read the viewModel once, as we mainly use it for controllers and methods.
    final viewModel = context.read<ExerciseLoggingViewModel>();

    final currentLoggedData = manager.currentLoggedExerciseData;

    // --- Automatic Navigation Logic ---
    // If the workout state is no longer valid for this screen, pop back.
    if (!manager.isWorkoutActive ||
        currentLoggedData == null ||
        currentLoggedData.originalExercise.id != viewModel.exercise.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const Scaffold(body: Center(child: Text("Finalizing...")));
    }

    // --- Completed Exercise UI ---
    if (currentLoggedData.isCompleted) {
      return _buildCompletedView(
          context, viewModel.exercise.name, currentLoggedData);
    }

    // --- Main Logging UI ---
    return Scaffold(
      appBar: AppBar(title: Text(viewModel.exercise.name)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SetHeader(exercise: viewModel.exercise),
              if (manager.isResting)
                _RestTimerView(manager: manager)
              else ...[
                const SizedBox(height: 20),
                if (viewModel.exercise.isTimed)
                  _TimedExerciseForm()
                else
                  _RepBasedExerciseForm(),
              ],
              if (currentLoggedData.loggedSets.isNotEmpty)
                _LoggedSetsList(loggedData: currentLoggedData),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UI Sub-Widgets ---

Widget _buildCompletedView(
    BuildContext context, String exerciseName, LoggedExerciseData loggedData) {
  return Scaffold(
    appBar: AppBar(title: Text(exerciseName), automaticallyImplyLeading: false),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text("$exerciseName Complete!",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text("${loggedData.loggedSets.length} sets logged.",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              label: const Text("Continue Workout"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SetHeader extends StatelessWidget {
  final RoutineExercise exercise;
  const _SetHeader({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<WorkoutSessionManager>();
    final setNumber = manager.currentSetIndexForLogging + 1;
    final totalSets = exercise.sets;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              setNumber <= totalSets
                  ? "Set $setNumber of $totalSets"
                  : "Extra Set",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              "Target: ${exercise.reps} reps", // Simplified for brevity
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RestTimerView extends StatelessWidget {
  final WorkoutSessionManager manager;
  const _RestTimerView({required this.manager});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ExerciseLoggingViewModel>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("REST",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              viewModel.formatDuration(manager.restTimeRemainingSeconds),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: manager.currentRestTotalSeconds > 0
                  ? manager.restTimeRemainingSeconds /
                      manager.currentRestTotalSeconds
                  : 0,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: manager.skipRest,
              child: const Text("Skip Rest", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimedExerciseForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel =
        context.watch<ExerciseLoggingViewModel>(); // watch for timer updates
    return Column(
      children: [
        // Row for minutes/seconds input fields...
        // ...
        const SizedBox(height: 20),
        Text(viewModel.formatDuration(viewModel.currentExerciseRunDownSeconds),
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: Icon(viewModel.isExerciseTimerRunning
              ? Icons.stop_circle_outlined
              : Icons.play_circle_outline_rounded),
          label: Text(viewModel.isExerciseTimerRunning
              ? "Stop & Log Time"
              : "Start Timer"),
          onPressed:
              context.read<ExerciseLoggingViewModel>().startOrStopExerciseTimer,
        ),
      ],
    );
  }
}

class _RepBasedExerciseForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ExerciseLoggingViewModel>();
    return Column(
      children: [
        if (viewModel.exercise.usesWeight) ...[
          TextFormField(
            controller: viewModel.weightController,
            decoration: const InputDecoration(labelText: "Weight (kg)"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: viewModel.repsController,
          decoration: const InputDecoration(labelText: "Reps"),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text("Log Set"),
          onPressed: () {
            final error = viewModel.logSet();
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error), backgroundColor: Colors.red));
            }
          },
        ),
      ],
    );
  }
}

class _LoggedSetsList extends StatelessWidget {
  final LoggedExerciseData loggedData;
  const _LoggedSetsList({required this.loggedData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Logged Sets:", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: loggedData.loggedSets.length,
            itemBuilder: (ctx, index) {
              final loggedSet = loggedData.loggedSets[index];
              return ListTile(
                leading: CircleAvatar(child: Text("${loggedSet.setNumber}")),
                title: Text(
                    "Reps: ${loggedSet.performedReps}, Weight: ${loggedSet.performedWeightKg}kg"),
                trailing: Text(DateFormat.jm().format(loggedSet.loggedAt)),
              );
            },
          ),
        ],
      ),
    );
  }
}
