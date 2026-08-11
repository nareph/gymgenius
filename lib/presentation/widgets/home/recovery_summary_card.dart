import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/presentation/screens/recovery/recovery_screen.dart';

/// Compact Home summary of today's recovery status.
class RecoverySummaryCard extends StatelessWidget {
  final RecoveryStatus status;

  const RecoverySummaryCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final cardColor = _cardColor(colorScheme, status.readinessScore);
    final onCard = _onCardColor(colorScheme, status.readinessScore);

    return Card(
      color: cardColor.withValues(alpha: 0.55),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(RecoveryScreen.route(status));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                _icon(status.recommendedIntensity),
                color: onCard,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recovery',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onCard,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Readiness ${status.readinessScore}  •  '
                      '${status.recommendedIntensity.displayName}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: onCard.withValues(alpha: 0.85),
                      ),
                    ),
                    if (status.reasons.isNotEmpty)
                      Text(
                        status.reasons.first,
                        style: textTheme.bodySmall?.copyWith(
                          color: onCard.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: onCard),
            ],
          ),
        ),
      ),
    );
  }

  Color _cardColor(ColorScheme cs, int readiness) {
    if (readiness >= 80) return cs.primaryContainer;
    if (readiness >= 60) return cs.tertiaryContainer;
    if (readiness >= 40) return Colors.orange.shade200;
    return cs.errorContainer;
  }

  Color _onCardColor(ColorScheme cs, int readiness) {
    if (readiness >= 80) return cs.onPrimaryContainer;
    if (readiness >= 60) return cs.onTertiaryContainer;
    if (readiness >= 40) return Colors.orange.shade900;
    return cs.onErrorContainer;
  }

  IconData _icon(RecommendedIntensity intensity) {
    switch (intensity) {
      case RecommendedIntensity.max:
        return Icons.bolt_rounded;
      case RecommendedIntensity.high:
        return Icons.trending_up_rounded;
      case RecommendedIntensity.moderate:
        return Icons.self_improvement_rounded;
      case RecommendedIntensity.light:
        return Icons.directions_walk_rounded;
      case RecommendedIntensity.rest:
        return Icons.hotel_rounded;
    }
  }
}
