import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';

class WeightProgressScreen extends StatelessWidget {
  final ProgressSnapshot snapshot;

  const WeightProgressScreen({super.key, required this.snapshot});

  static Route<void> route(ProgressSnapshot snapshot) {
    return MaterialPageRoute(
      builder: (_) => WeightProgressScreen(snapshot: snapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trend = snapshot.weightTrend;
    final hasData = trend?.hasSufficientData ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Weight Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoTile('Period', snapshot.period.displayName),
          _InfoTile('Computed', _formatDate(snapshot.computedAt)),
          if (!hasData)
            const _InsufficientBanner(
              message:
                  'Log your weight in the daily check-in at least 3 times to see trends.',
            )
          else ...[
            _InfoTile(
                'Current', '${trend!.currentWeightKg!.toStringAsFixed(1)} kg'),
            if (trend.weeklyAverageKg != null)
              _InfoTile(
                'Weekly average',
                '${trend.weeklyAverageKg!.toStringAsFixed(1)} kg',
              ),
            _InfoTile('Change', '${trend.changeKg!.toStringAsFixed(1)} kg'),
            _InfoTile('Trend', trend.direction.displayName),
            if (trend.distanceToTargetKg != null)
              _InfoTile(
                'Distance to target',
                '${trend.distanceToTargetKg!.toStringAsFixed(1)} kg',
              ),
            _InfoTile('Data points', '${trend.dataPointCount}'),
            if (snapshot.weightPlateauDetected)
              const _PlateauBanner(type: 'Weight'),
          ],
          if (snapshot.reasons.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Insights', style: Theme.of(context).textTheme.titleMedium),
            ...snapshot.reasons.map(
              (r) => ListTile(
                leading: const Icon(Icons.lightbulb_outline, size: 20),
                title: Text(r),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InsufficientBanner extends StatelessWidget {
  final String message;

  const _InsufficientBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _PlateauBanner extends StatelessWidget {
  final String type;

  const _PlateauBanner({required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        title: Text(
          '$type plateau detected',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
