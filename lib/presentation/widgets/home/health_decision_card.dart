import 'package:flutter/material.dart';
import 'package:gymgenius/engines/decision_engine/models/health_decision.dart';

/// Compact Home card for today's health recommendation.
class HealthDecisionCard extends StatelessWidget {
  final HealthDecision decision;

  const HealthDecisionCard({
    super.key,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.health_and_safety_outlined,
          color: colorScheme.primary,
          size: 28,
        ),
        title: Text(
          'Today\'s recommendation',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(decision.displayAction),
            const SizedBox(height: 2),
            Text(
              decision.reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
