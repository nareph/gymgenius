import 'package:flutter/material.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';

class WorkoutRestTimerControls extends StatelessWidget {
  const WorkoutRestTimerControls({
    super.key,
    required this.manager,
    required this.formatDuration,
    this.showSkip = true,
    this.onContinue,
    this.continueLabel,
    this.continueIcon,
  });

  final WorkoutSessionManager manager;
  final String Function(int seconds) formatDuration;
  final bool showSkip;
  final VoidCallback? onContinue;
  final String? continueLabel;
  final IconData? continueIcon;

  bool _isUrgent(int seconds) => seconds > 0 && seconds <= 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgent = _isUrgent(manager.restTimeRemainingSeconds);
    final timerColor =
        urgent ? Colors.orange.shade700 : theme.colorScheme.primary;

    return Column(
      children: [
        Text(
          formatDuration(manager.restTimeRemainingSeconds),
          style: theme.textTheme.displayMedium?.copyWith(
            color: timerColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: manager.currentRestTotalSeconds > 0
              ? manager.restTimeRemainingSeconds /
                  manager.currentRestTotalSeconds
              : 0,
          color: timerColor,
          minHeight: urgent ? 10 : 6,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AdjustButton(
              label: '-10s',
              onPressed: () => manager.adjustRestTimer(-10),
            ),
            const SizedBox(width: 12),
            _AdjustButton(
              label: '+10s',
              onPressed: () => manager.adjustRestTimer(10),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showSkip)
              TextButton(
                onPressed: manager.skipRest,
                child: const Text('Skip Rest', style: TextStyle(fontSize: 16)),
              ),
            if (onContinue != null)
              ElevatedButton.icon(
                icon: Icon(continueIcon ?? Icons.arrow_forward_ios_rounded,
                    size: 18),
                label: Text(continueLabel ?? 'Continue'),
                onPressed: onContinue,
              ),
          ],
        ),
      ],
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 44),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
