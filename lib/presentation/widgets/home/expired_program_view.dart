import 'package:flutter/material.dart';

class ExpiredProgramView extends StatelessWidget {
  final String programName;
  final VoidCallback onGenerate;
  final VoidCallback onDismiss;

  const ExpiredProgramView({
    super.key,
    required this.programName,
    required this.onGenerate,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        elevation: 2,
        color: theme.colorScheme.tertiaryContainer.withAlpha(180),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy_outlined,
                  size: 50, color: theme.colorScheme.onTertiaryContainer),
              const SizedBox(height: 16),
              Text(
                "Program Expired!",
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Your program '$programName' has completed. It's time to generate a new plan to continue your fitness journey!",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.autorenew_rounded),
                label: const Text("Generate New Program"),
                onPressed: onGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  "Dismiss (Clear Old Program)",
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(200)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
