import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';

class StrengthProgressScreen extends StatelessWidget {
  final ProgressSnapshot snapshot;

  const StrengthProgressScreen({super.key, required this.snapshot});

  static Route<void> route(ProgressSnapshot snapshot) {
    return MaterialPageRoute(
      builder: (_) => StrengthProgressScreen(snapshot: snapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = snapshot.strengthProgress;
    final hasData = strength?.hasSufficientData ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Strength Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!hasData)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Complete at least 2 sessions with logged sets to track strength.',
                ),
              ),
            )
          else ...[
            ListTile(
              title: const Text('Overall trend'),
              trailing: Text(strength!.overallTrend.displayName),
            ),
            ListTile(
              title: const Text('Average change'),
              trailing:
                  Text('${strength.strengthChangePercent.toStringAsFixed(1)}%'),
            ),
            if (strength.plateauDetected)
              const ListTile(
                leading:
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text('Strength plateau detected'),
              ),
            const Divider(),
            Text('Top exercises',
                style: Theme.of(context).textTheme.titleMedium),
            ...strength.topExercises.map(
              (e) => ListTile(
                title: Text(e.exerciseName),
                subtitle: Text(
                  'Best: ${e.bestWeightKg} kg × ${e.bestReps} · '
                  'e1RM ${e.estimated1Rm.toStringAsFixed(1)} kg',
                ),
                trailing: Text(e.trend.displayName),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
