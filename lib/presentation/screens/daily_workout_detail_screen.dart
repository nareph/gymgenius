// lib/presentation/screens/daily_workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';
import 'package:gymgenius/presentation/screens/active_workout_session_screen.dart';
import 'package:provider/provider.dart';

class DailyWorkoutDetailScreen extends StatefulWidget {
  final String dayTitle;
  final List<Exercise> initialExercises;
  final String? programIdForLog;
  final String dayKeyForLog;
  final HealthProfile healthProfile;

  const DailyWorkoutDetailScreen({
    super.key,
    required this.dayTitle,
    required this.initialExercises,
    this.programIdForLog,
    required this.dayKeyForLog,
    required this.healthProfile,
  });

  @override
  State<DailyWorkoutDetailScreen> createState() =>
      _DailyWorkoutDetailScreenState();
}

class _DailyWorkoutDetailScreenState extends State<DailyWorkoutDetailScreen> {
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.initialExercises);
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(exercise.name),
        content: SingleChildScrollView(
          child: Text(
            exercise.description.replaceAll("\\n", "\n\n"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final workoutManager = context.read<WorkoutSessionManager>();
    final sessionName =
        widget.dayTitle.replaceFirst(" Workout Details", " Workout");

    return Scaffold(
      appBar: AppBar(title: Text(widget.dayTitle)),
      body: Column(
        children: [
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6)),
                          const SizedBox(height: 20),
                          Text(
                            "No exercises scheduled.",
                            style: textTheme.titleLarge
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enjoy your rest day!",
                            style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            exercise.name,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "${exercise.sets} sets of ${exercise.reps}"
                            "${exercise.weightSuggestion != null && exercise.weightSuggestion!.isNotEmpty && exercise.weightSuggestion!.toLowerCase() != 'bodyweight' ? ' @ ${exercise.weightSuggestion}kg' : (exercise.isBodyweight ? ' (Bodyweight)' : '')}"
                            "\nRest: ${exercise.restSeconds}s between sets",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Icon(Icons.info_outline_rounded,
                              color:
                                  colorScheme.secondary.withValues(alpha: 0.8)),
                          onTap: () => _showExerciseDetails(context, exercise),
                        ),
                      );
                    },
                  ),
          ),
          if (_exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill_rounded, size: 24),
                label: const Text("Start This Workout"),
                onPressed: () {
                  if (workoutManager.isWorkoutActive) {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: const Text("Workout in Progress"),
                        content: const Text(
                            "Another workout session is active. What would you like to do?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogCtx).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ActiveWorkoutSessionScreen()),
                              );
                            },
                            child: Text("Resume Current",
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogCtx).pop();
                              workoutManager.forceStartNewWorkout(
                                _exercises,
                                workoutName: sessionName,
                                programId: widget.programIdForLog,
                                dayKey: widget.dayKeyForLog,
                              );
                              if (workoutManager.isWorkoutActive) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ActiveWorkoutSessionScreen()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: const Text(
                                            "Failed to start workout."),
                                        backgroundColor:
                                            theme.colorScheme.error));
                              }
                            },
                            child: Text("End & Start New",
                                style:
                                    TextStyle(color: theme.colorScheme.error)),
                          ),
                          TextButton(
                              onPressed: () => Navigator.of(dialogCtx).pop(),
                              child: const Text("Cancel")),
                        ],
                      ),
                    );
                  } else {
                    final started = workoutManager.startWorkoutIfNoSession(
                      _exercises,
                      workoutName: sessionName,
                      programId: widget.programIdForLog,
                      dayKey: widget.dayKeyForLog,
                    );
                    if (started) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ActiveWorkoutSessionScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Failed to start workout."),
                          backgroundColor: theme.colorScheme.error));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
