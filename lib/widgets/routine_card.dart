// lib/widgets/routine_card.dart
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart'; // For OnboardingData
import 'package:gymgenius/models/routine.dart'; // For RoutineExercise and WeeklyRoutine
import 'package:gymgenius/screens/daily_workout_detail_screen.dart'; // To navigate to

// RoutineCard: A widget to display a summary of a single day's workout or rest day
// within a weekly routine schedule.
class RoutineCard extends StatelessWidget {
  final String dayKey; // e.g., "monday", "tuesday"
  final List<RoutineExercise> exercises; // List of exercises for this day
  final bool isToday; // Flag if this card represents the current day
  final WeeklyRoutine parentRoutine; // The parent routine this day belongs to
  final OnboardingData
      onboardingData; // User's onboarding data, passed to detail screen

  const RoutineCard({
    super.key,
    required this.dayKey,
    required this.exercises,
    required this.parentRoutine,
    required this.onboardingData, // Ensure this is passed when RoutineCard is created
    this.isToday = false,
  });

  // Helper to capitalize the first letter of a string.
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Navigates to the DailyWorkoutDetailScreen for the selected day.
  // Navigation only occurs if it's not a rest day (i.e., exercises list is not empty).
  void _navigateToDetail(BuildContext context) {
    if (exercises.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyWorkoutDetailScreen(
            dayTitle: "${_capitalize(dayKey)} Workout Details",
            initialExercises: exercises,
            routineIdForLog: parentRoutine.id,
            dayKeyForLog: dayKey.toLowerCase(),
            onboardingData: onboardingData, // Pass onboardingData
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bool isRestDay = exercises.isEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: isRestDay ? 0.5 : (isToday ? 4.0 : 1.5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isToday && !isRestDay
            ? BorderSide(color: colorScheme.primary, width: 1.5)
            : (isRestDay
                ? BorderSide(
                    color: colorScheme.outline.withAlpha((77).round()),
                    width: 0.8)
                : BorderSide.none),
      ),
      color: isRestDay ? colorScheme.surfaceContainerLowest : null,
      child: InkWell(
        onTap: isRestDay ? null : () => _navigateToDetail(context),
        splashColor: isRestDay ? Colors.transparent : null,
        highlightColor: isRestDay ? Colors.transparent : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _capitalize(dayKey),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday && !isRestDay
                            ? colorScheme.primary
                            : (isRestDay
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isRestDay)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.onSurface.withAlpha((178).round()),
                    )
                  else
                    Chip(
                      label: Text(
                        "REST",
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      backgroundColor: colorScheme.secondaryContainer
                          .withAlpha((178).round()),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (!isRestDay) ...[
                ...exercises.take(3).map((ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "• ${ex.name} (${ex.sets}x${ex.reps})",
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                if (exercises.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "...and ${exercises.length - 3} more.",
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant
                            .withAlpha((150).round()),
                      ),
                    ),
                  ),
              ] else
                Text(
                  "Take this day to recover and recharge!",
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
