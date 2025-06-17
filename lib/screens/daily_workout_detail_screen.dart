// lib/screens/daily_workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart'; // <<--- AJOUTÉ
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:provider/provider.dart';

// DailyWorkoutDetailScreen: Displays the list of exercises for a specific day
// and allows the user to start the workout.
class DailyWorkoutDetailScreen extends StatefulWidget {
  // Changed to StatefulWidget for future flexibility (e.g., exercise replacement)
  final String dayTitle;
  final List<RoutineExercise>
      initialExercises; 
  final String? routineIdForLog;
  final String dayKeyForLog;
  final OnboardingData onboardingData; 

  const DailyWorkoutDetailScreen({
    super.key,
    required this.dayTitle,
    required this.initialExercises, 
    this.routineIdForLog,
    required this.dayKeyForLog,
    required this.onboardingData, 
  });

  @override
  State<DailyWorkoutDetailScreen> createState() =>
      _DailyWorkoutDetailScreenState();
}

class _DailyWorkoutDetailScreenState extends State<DailyWorkoutDetailScreen> {
  late List<RoutineExercise> _currentExercises; // Local state for exercises

  @override
  void initState() {
    super.initState();
    // Initialize the local list of exercises from the widget's initial data
    _currentExercises = List.from(widget.initialExercises);
  }

  // Method to display details of a single exercise
  void _showExerciseDetails(BuildContext context, RoutineExercise exercise) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(exercise.name),
        content: SingleChildScrollView(
          child: Text(
            exercise.description
                .replaceAll("\\n", "\n\n"), // Format description
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);
    // Use widget.dayTitle as it's passed in and doesn't change
    final String sessionName =
        widget.dayTitle.replaceFirst(" Workout Details", " Workout");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayTitle),
        // elevation: 1.0, // Inherited from AppBarTheme
      ),
      body: Column(
        children: [
          // List of exercises
          Expanded(
            child: _currentExercises.isEmpty
                ? Center(
                    // Display if no exercises are scheduled
                    child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_outlined,
                            size: 64, // Increased size
                            color: colorScheme.onSurfaceVariant
                                .withAlpha((153).round())), // ~60% opacity
                        const SizedBox(height: 20),
                        Text(
                          "No exercises scheduled for this day.",
                          style: textTheme.titleLarge
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enjoy your rest or check back later!",
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withAlpha((200).round())),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0), // Added vertical padding
                    itemCount: _currentExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _currentExercises[index];
                      return Card(
                        // elevation: 1.5, // Inherited from CardTheme or can be set
                        margin: const EdgeInsets.symmetric(
                            vertical:
                                6.0), // Removed horizontal margin as ListView has padding
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Inherited
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0), // Increased vertical padding
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // Slightly larger
                              ),
                            ),
                          ),
                          title: Text(
                            exercise.name,
                            style: textTheme.titleMedium?.copyWith(
                                fontWeight:
                                    FontWeight.w600), // Changed to titleMedium
                          ),
                          subtitle: Text(
                            "${exercise.sets} sets of ${exercise.reps}"
                            "${exercise.weightSuggestionKg.isNotEmpty && exercise.weightSuggestionKg.toLowerCase() != 'n/a' && exercise.weightSuggestionKg.toLowerCase() != 'bodyweight' ? ' @ ${exercise.weightSuggestionKg}kg' : (exercise.weightSuggestionKg.toLowerCase() == 'bodyweight' ? ' (Bodyweight)' : '')}"
                            "\nRest: ${exercise.restBetweenSetsSeconds}s between sets",
                            style: textTheme.bodyMedium?.copyWith(
                                // Changed to bodyMedium
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4), // Increased line height
                          ),
                          isThreeLine: true,
                          trailing: Icon(Icons.info_outline_rounded,
                              color: colorScheme.secondary
                                  .withAlpha((200).round())), // Info icon
                          onTap: () => _showExerciseDetails(
                              context, exercise), // Show details on tap
                        ),
                      );
                    },
                  ),
          ),
          // "Start This Workout" button, shown only if there are exercises
          if (_currentExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 24.0), // Standard padding
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill_rounded,
                    size: 24), // Slightly larger icon
                label: const Text("Start This Workout"),
                onPressed: () {
                  // Logic to start the workout session
                  if (workoutManager.isWorkoutActive) {
                    // If a workout is already active, show a confirmation dialog
                    showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                              title: const Text("Workout in Progress"),
                              content: const Text(
                                  "Another workout session is currently active. What would you like to do?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogCtx)
                                        .pop(); // Close dialog
                                    Navigator.push(
                                      // Navigate to the active session
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
                                    Navigator.of(dialogCtx)
                                        .pop(); // Close dialog
                                    // Force start a new workout, ending the current one
                                    workoutManager.forceStartNewWorkout(
                                      _currentExercises, // Use the local list of exercises
                                      workoutName: sessionName,
                                      routineId: widget.routineIdForLog,
                                      dayKey: widget.dayKeyForLog,
                                    );
                                    if (workoutManager.isWorkoutActive) {
                                      // Navigate if new workout started
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ActiveWorkoutSessionScreen()));
                                    } else {
                                      // Should not happen if forceStartNewWorkout is robust
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: const Text(
                                                  "Failed to start the new workout."),
                                              backgroundColor:
                                                  theme.colorScheme.error));
                                    }
                                  },
                                  child: Text("End & Start New",
                                      style: TextStyle(
                                          color: theme.colorScheme.error)),
                                ),
                                TextButton(
                                    onPressed: () => Navigator.of(dialogCtx)
                                        .pop(), // Close dialog
                                    child: const Text("Cancel")),
                              ],
                            ));
                  } else {
                    // No workout active, start a new session
                    bool started = workoutManager.startWorkoutIfNoSession(
                      _currentExercises, // Use the local list of exercises
                      workoutName: sessionName,
                      routineId: widget.routineIdForLog,
                      dayKey: widget.dayKeyForLog,
                    );
                    if (started) {
                      // Navigate if workout started
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ActiveWorkoutSessionScreen()));
                    } else {
                      // Should be rare if no session was active
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                              "Failed to start workout. An unexpected error occurred."),
                          backgroundColor: theme.colorScheme.error));
                    }
                  }
                },
                // Style inherited from ElevatedButtonThemeData in AppTheme.dart
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 52), // Full width button
                ),
              ),
            ),
        ],
      ),
    );
  }
}
