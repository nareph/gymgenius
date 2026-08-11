import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/presentation/screens/main_dashboard_screen.dart';

/// Compact Progress insight on Home — detail lives on Tracking tab.
class HomeProgressSummaryCard extends StatelessWidget {
  final ProgressSnapshot snapshot;

  const HomeProgressSummaryCard({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final consistency = snapshot.consistency?.consistencyScore;
    final weightTrend = snapshot.weightTrend?.direction;
    final strengthTrend = snapshot.strengthProgress?.overallTrend;

    final parts = <String>[];
    if (consistency != null) {
      parts.add('Consistency $consistency%');
    }
    if (weightTrend != null && weightTrend != TrendDirection.insufficientData) {
      parts.add('Weight ${weightTrend.displayName.toLowerCase()}');
    }
    if (strengthTrend != null &&
        strengthTrend != TrendDirection.insufficientData) {
      parts.add('Strength ${strengthTrend.displayName.toLowerCase()}');
    }
    if (snapshot.anyPlateauDetected) {
      parts.add('Plateau detected');
    }

    final subtitle = parts.isEmpty
        ? 'Keep logging workouts and weight to unlock insights'
        : parts.join(' · ');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final dashboard =
              context.findAncestorStateOfType<MainDashboardScreenState>();
          dashboard?.selectTab(kTrackingTabIndex);
        },
        child: ListTile(
          leading: Icon(
            Icons.insights_outlined,
            color: colorScheme.primary,
            size: 28,
          ),
          title: Text(
            'Progress',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
