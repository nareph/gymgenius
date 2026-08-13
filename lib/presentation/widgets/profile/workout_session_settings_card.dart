import 'package:flutter/material.dart';
import 'package:gymgenius/presentation/providers/workout_session_settings_controller.dart';
import 'package:provider/provider.dart';

class WorkoutSessionSettingsCard extends StatelessWidget {
  const WorkoutSessionSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkoutSessionSettingsController>();
    final theme = Theme.of(context);

    if (controller.isLoading) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final settings = controller.settings;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.volume_up_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Workout Session Sounds',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Timer beeps, rest chime, haptics, and voice countdown during training.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound effects'),
              subtitle: const Text('Beeps at 3-2-1 and completion tones'),
              value: settings.soundsEnabled,
              onChanged: controller.setSoundsEnabled,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Haptic feedback'),
              subtitle: const Text('Vibration on countdown and timer end'),
              value: settings.hapticsEnabled,
              onChanged: controller.setHapticsEnabled,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Voice countdown'),
              subtitle: const Text('Speaks "3, 2, 1, go" and rest alerts'),
              value: settings.voiceCountdownEnabled,
              onChanged: controller.setVoiceCountdownEnabled,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Background notifications'),
              subtitle: const Text(
                'Alert when a timer finishes while the app is in background',
              ),
              value: settings.backgroundNotificationsEnabled,
              onChanged: controller.setBackgroundNotificationsEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
