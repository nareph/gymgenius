import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/presentation/screens/health/health_dashboard_screen.dart';

/// Short Home CTA into Health Platform dashboard.
class HomeHealthPlatformCard extends StatelessWidget {
  final HealthPlatformSnapshot? snapshot;

  const HomeHealthPlatformCard({super.key, this.snapshot});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = snapshot?.hasAnyData == true
        ? 'Hydration ${snapshot!.hydrationPercent}% · Habits ${snapshot!.habitsCompletionPercent}%'
        : 'Log BP, glucose, hydration, wellness & habits';

    return Card(
      child: ListTile(
        leading: Icon(Icons.favorite_outline, color: scheme.primary),
        title: const Text('Health Platform'),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () =>
            Navigator.of(context).push(HealthDashboardScreen.route()),
      ),
    );
  }
}
