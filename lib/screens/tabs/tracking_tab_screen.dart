// lib/screens/tabs/tracking_tab_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TrackingTabScreen extends StatelessWidget {
  final User user;
  const TrackingTabScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 80, color: colorScheme.primary.withOpacity(0.6)),
            const SizedBox(height: 20),
            Text(
              "Workout Tracking",
              style: textTheme.headlineMedium
                  ?.copyWith(color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Your progress calendar will be available here soon. Mark your completed sessions and stay motivated!",
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.construction_outlined),
              label: const Text("Coming Soon"),
              onPressed: null, // Désactivé pour l'instant
              style: ElevatedButton.styleFrom(
                // backgroundColor: colorScheme.secondaryContainer,
                // foregroundColor: colorScheme.onSecondaryContainer,
                disabledBackgroundColor:
                    colorScheme.surfaceVariant.withOpacity(0.5),
                disabledForegroundColor:
                    colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            )
          ],
        ),
      ),
    );
  }
}
