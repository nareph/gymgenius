// lib/screens/daily_workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // Pour RoutineExercise

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
        title: Text(dayTitle), // Affiche le nom du jour (ex: "Monday Workout")
        backgroundColor: colorScheme.surface, // Assorti au thème
        elevation: 1, // Légère ombre
      ),
      body: exercises.isEmpty
          ? Center(
              child: Text(
                "No exercises scheduled for $dayTitle.",
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
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
                          value: "${exercise.sets} sets of ${exercise.reps}",
                        ),
                        const SizedBox(height: 8.0),
                        _buildDetailRow(
                          context,
                          icon: Icons.scale,
                          label: "Weight:",
                          value: exercise.weightSuggestionKg,
                        ),
                        const SizedBox(height: 8.0),
                        _buildDetailRow(
                          context,
                          icon: Icons.timer_outlined,
                          label: "Rest:",
                          value: "${exercise.restBetweenSetsSeconds} seconds",
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
                              color: colorScheme.onSurface.withOpacity(0.8),
                              height: 1.4, // Meilleure lisibilité
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Helper widget pour afficher une ligne de détail avec icône
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
