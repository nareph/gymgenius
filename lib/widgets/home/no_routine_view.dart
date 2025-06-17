import 'package:flutter/material.dart';

class NoRoutineView extends StatelessWidget {
  final VoidCallback onGenerate;

  const NoRoutineView({super.key, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.fitness_center,
                size: 50, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text("No Workout Plan Found",
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Text(
                "Let's generate a personalized workout plan to help you reach your fitness goals!",
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text("Generate My First Routine"),
              onPressed: onGenerate,
            ),
          ]),
        ),
      ),
    );
  }
}
