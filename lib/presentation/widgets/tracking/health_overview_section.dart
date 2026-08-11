import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/presentation/screens/health/health_dashboard_screen.dart';

/// Compact Health Platform overview for the Tracking tab.
class HealthOverviewSection extends StatelessWidget {
  final HealthPlatformSnapshot? snapshot;
  final bool isLoading;

  const HealthOverviewSection({
    super.key,
    required this.snapshot,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Health Platform',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(HealthDashboardScreen.route()),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          snapshot?.hasAnyData == true
                              ? 'Today\'s health overview'
                              : 'Start logging health metrics',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  if (snapshot != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                          context,
                          'Hydration ${snapshot!.hydrationPercent}%',
                        ),
                        _chip(
                          context,
                          'Habits ${snapshot!.habitsCompletionPercent}%',
                        ),
                        if (snapshot!.hasBpCaution)
                          _chip(context, 'BP caution', caution: true),
                        if (snapshot!.hasGlucoseCaution)
                          _chip(context, 'Glucose caution', caution: true),
                        if (snapshot!.wellnessTrendLabel != null)
                          _chip(
                            context,
                            'Mood ${snapshot!.wellnessTrendLabel}',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, {bool caution = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      backgroundColor: caution
          ? scheme.errorContainer
          : scheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: caution ? scheme.onErrorContainer : scheme.onSurface,
        fontSize: 12,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
