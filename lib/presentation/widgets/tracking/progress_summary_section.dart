import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/presentation/screens/progress/consistency_progress_screen.dart';
import 'package:gymgenius/presentation/screens/progress/strength_progress_screen.dart';
import 'package:gymgenius/presentation/screens/progress/weight_progress_screen.dart';

/// Progress intelligence cards shown on the Tracking tab.
class ProgressSummarySection extends StatelessWidget {
  final ProgressSnapshot? snapshot;
  final bool isLoading;

  const ProgressSummarySection({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Progress Intelligence',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        _WeightCard(snapshot: snapshot),
        _StrengthCard(snapshot: snapshot),
        _ConsistencyCard(snapshot: snapshot),
        if (snapshot?.anyPlateauDetected ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                title: Text(
                  'Plateau detected',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  snapshot!.reasons
                      .where((r) => r.toLowerCase().contains('plateau'))
                      .join(' · '),
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onErrorContainer
                        .withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WeightCard extends StatelessWidget {
  final ProgressSnapshot? snapshot;

  const _WeightCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final trend = snapshot?.weightTrend;
    final hasData = trend?.hasSufficientData ?? false;

    return _ProgressCard(
      title: 'Weight',
      icon: Icons.monitor_weight_outlined,
      value: hasData ? '${trend!.currentWeightKg!.toStringAsFixed(1)} kg' : '—',
      subtitle: hasData
          ? '${trend!.direction.displayName} · ${trend.changeKg!.toStringAsFixed(1)} kg'
          : 'Insufficient data — log weight in daily check-in',
      trend: trend?.direction,
      onTap: snapshot != null
          ? () => Navigator.of(context).push(
                WeightProgressScreen.route(snapshot!),
              )
          : null,
    );
  }
}

class _StrengthCard extends StatelessWidget {
  final ProgressSnapshot? snapshot;

  const _StrengthCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final strength = snapshot?.strengthProgress;
    final hasData = strength?.hasSufficientData ?? false;

    return _ProgressCard(
      title: 'Strength',
      icon: Icons.fitness_center_outlined,
      value: hasData
          ? '${strength!.strengthChangePercent.toStringAsFixed(1)}%'
          : '—',
      subtitle: hasData
          ? '${strength!.overallTrend.displayName} · ${strength.trackedExerciseCount} exercises'
          : 'Insufficient data — complete more workouts',
      trend: strength?.overallTrend,
      onTap: snapshot != null
          ? () => Navigator.of(context).push(
                StrengthProgressScreen.route(snapshot!),
              )
          : null,
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  final ProgressSnapshot? snapshot;

  const _ConsistencyCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final consistency = snapshot?.consistency;
    final hasData = consistency?.hasSufficientData ?? false;

    return _ProgressCard(
      title: 'Consistency',
      icon: Icons.event_available_outlined,
      value: hasData ? '${consistency!.consistencyScore}%' : '—',
      subtitle: hasData
          ? '${consistency!.completedWorkouts}/${consistency.plannedWorkouts} workouts · '
              '${consistency.weeklyFrequency.toStringAsFixed(1)}/wk'
          : 'Insufficient data — no planned workouts in period',
      trend: consistency?.trend,
      onTap: snapshot != null
          ? () => Navigator.of(context).push(
                ConsistencyProgressScreen.route(snapshot!),
              )
          : null,
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final TrendDirection? trend;
  final VoidCallback? onTap;

  const _ProgressCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.trend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (trend != null) _TrendIcon(trend: trend!),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendIcon extends StatelessWidget {
  final TrendDirection trend;

  const _TrendIcon({required this.trend});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      TrendDirection.gaining => (Icons.trending_up, Colors.green),
      TrendDirection.losing => (Icons.trending_down, Colors.orange),
      TrendDirection.stable => (Icons.trending_flat, Colors.blueGrey),
      TrendDirection.fluctuating => (Icons.swap_vert, Colors.amber),
      TrendDirection.insufficientData => (Icons.help_outline, Colors.grey),
    };

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
