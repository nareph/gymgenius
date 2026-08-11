import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

/// Banner shown on Home when today's workout was adapted.
class WorkoutAdaptationBanner extends StatelessWidget {
  final WorkoutDecision decision;

  const WorkoutAdaptationBanner({
    super.key,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    if (!decision.requiresAdaptation) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final reasons = decision.reasons
        .map((r) => r.displayName)
        .where((s) => s.isNotEmpty)
        .toList();

    return Card(
      color: colorScheme.tertiaryContainer.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.tune_rounded,
              color: colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout adapted',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onTertiaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    decision.adjustment.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                  ),
                  if (reasons.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reasons.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onTertiaryContainer
                                .withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
