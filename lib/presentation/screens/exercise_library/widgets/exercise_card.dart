// lib/presentation/screens/exercise_library/widgets/exercise_card.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

import '../../../../domain/enums/exports.dart';

class ExerciseCard extends StatelessWidget {
  final ExercisePoolEntry exercise;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getExerciseIcon(),
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        ...exercise.targetMuscles.take(3).map(
                            (muscle) => _buildTag(context, muscle.displayName)),
                        if (exercise.targetMuscles.length > 3)
                          _buildTag(context,
                              '+${exercise.targetMuscles.length - 3} more'),
                      ],
                    ),
                  ],
                ),
              ),
              // Chevr on
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withAlpha(102),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            ),
      ),
    );
  }

  IconData _getExerciseIcon() {
    switch (exercise.category) {
      case ExerciseCategory.compound:
        return Icons.fitness_center;
      case ExerciseCategory.isolation:
        return Icons.track_changes;
      default:
        return Icons.sports_gymnastics;
    }
  }
}
