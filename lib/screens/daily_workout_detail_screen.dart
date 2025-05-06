// lib/screens/daily_workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // Pour RoutineExercise
import 'package:gymgenius/screens/active_workout_session_screen.dart'; // Importer le nouvel écran

class DailyWorkoutDetailScreen extends StatelessWidget {
  final String dayTitle;
  final List<RoutineExercise> exercises;

  const DailyWorkoutDetailScreen({
    super.key,
    required this.dayTitle,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(dayTitle),
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      body: exercises.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_outlined,
                        size: 60,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      "It's a Rest Day!",
                      style: textTheme.headlineSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No exercises scheduled for $dayTitle.",
                      style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              // Envelopper dans une Column pour ajouter le bouton en bas
              children: [
                Expanded(
                  // Pour que le ListView prenne l'espace disponible
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16.0, 16.0, 16.0, 0), // Ajuster le padding
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              _buildDetailRow(
                                context,
                                icon: Icons.fitness_center,
                                label: "Sets & Reps:",
                                value:
                                    "${exercise.sets} sets of ${exercise.reps}",
                              ),
                              const SizedBox(height: 8.0),
                              _buildDetailRow(
                                context,
                                icon: Icons.scale,
                                label: "Weight:",
                                value: exercise.weightSuggestionKg.isNotEmpty &&
                                        exercise.weightSuggestionKg != 'N/A'
                                    ? exercise.weightSuggestionKg
                                    : "Bodyweight / As appropriate",
                              ),
                              const SizedBox(height: 8.0),
                              _buildDetailRow(
                                context,
                                icon: Icons.timer_outlined,
                                label: "Rest:",
                                value:
                                    "${exercise.restBetweenSetsSeconds} seconds",
                              ),
                              const SizedBox(height: 12.0),
                              if (exercise.description.isNotEmpty) ...[
                                Text(
                                  "Description:",
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  exercise.description,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bouton "Start Workout" en bas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text("Start Workout"),
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size(double.infinity, 50), // Pleine largeur
                      textStyle: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      // TODO: Plus tard, initialiser le WorkoutSessionManager ici
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveWorkoutSessionScreen(
                            workoutTitle: dayTitle,
                            exercises: exercises,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.0, color: colorScheme.secondary),
        const SizedBox(width: 10.0),
        Text(
          label,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurface.withOpacity(0.9)),
          ),
        ),
      ],
    );
  }
}
