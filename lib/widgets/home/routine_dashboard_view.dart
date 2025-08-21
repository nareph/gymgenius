import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:gymgenius/widgets/routine_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RoutineDashboardView extends StatelessWidget {
  final WeeklyRoutine routine;
  final OnboardingData onboardingData;
  final bool isOffline;

  const RoutineDashboardView({
    super.key,
    required this.routine,
    required this.onboardingData,
    this.isOffline = false,
  });

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // 💪 FUNCTION TO EXTRACT MAIN SPLIT THEME FROM AI DESCRIPTION
  String _extractSplitTheme(List<RoutineExercise> exercises) {
    if (exercises.isEmpty) return 'Rest';

    // Look for the split theme in the first exercise's description
    // AI generates descriptions like: "**Target: Chest, Triceps, Shoulders | Split: Push Day**"
    for (final exercise in exercises) {
      final description = exercise.description;

      // Extract split theme after "Split:"
      final splitMatch = RegExp(r'Split:\s*([^*\n]+)', caseSensitive: false)
          .firstMatch(description);

      if (splitMatch != null) {
        String splitTheme = splitMatch.group(1)?.trim() ?? '';

        // Clean up the split theme
        splitTheme = splitTheme
            .replaceAll('Day', '')
            .replaceAll('Focus', '')
            .replaceAll('Training', '')
            .trim();

        // Standardize common patterns
        final standardizedSplits = {
          'push': 'Push',
          'pull': 'Pull',
          'legs': 'Legs',
          'leg': 'Legs',
          'upper body': 'Upper Body',
          'lower body': 'Lower Body',
          'chest': 'Chest',
          'back': 'Back',
          'shoulders': 'Shoulders',
          'arms': 'Arms',
          'core': 'Core',
          'full body': 'Full Body',
          'chest & triceps': 'Chest & Triceps',
          'back & biceps': 'Back & Biceps',
          'shoulders & core': 'Shoulders & Core',
        };

        final lowerTheme = splitTheme.toLowerCase();
        for (final entry in standardizedSplits.entries) {
          if (lowerTheme.contains(entry.key)) {
            return entry.value;
          }
        }

        // Return the cleaned theme if no standard match
        if (splitTheme.isNotEmpty) {
          return splitTheme;
        }
      }
    }

    // Fallback to analyzing exercise names if no split found in description
    return _fallbackSplitAnalysis(exercises);
  }

  // 🔄 FALLBACK ANALYSIS WHEN NO SPLIT THEME IN DESCRIPTION
  String _fallbackSplitAnalysis(List<RoutineExercise> exercises) {
    Set<String> muscleHints = {};

    for (final exercise in exercises) {
      final name = exercise.name.toLowerCase();

      if (name.contains('push') ||
          name.contains('chest') ||
          name.contains('press')) {
        muscleHints.add('push');
      } else if (name.contains('pull') ||
          name.contains('back') ||
          name.contains('row')) {
        muscleHints.add('pull');
      } else if (name.contains('squat') ||
          name.contains('lunge') ||
          name.contains('leg')) {
        muscleHints.add('legs');
      } else if (name.contains('shoulder') || name.contains('lateral')) {
        muscleHints.add('shoulders');
      }
    }

    if (muscleHints.contains('push') && muscleHints.contains('pull')) {
      return 'Upper Body';
    } else if (muscleHints.contains('push')) {
      return 'Push';
    } else if (muscleHints.contains('pull')) {
      return 'Pull';
    } else if (muscleHints.contains('legs')) {
      return 'Legs';
    } else if (muscleHints.contains('shoulders')) {
      return 'Shoulders';
    }

    return 'Workout';
  }

  // 🏷️ FUNCTION TO FORMAT DAY NAME WITH SPLIT THEME
  String _formatDayWithSplit(String dayKey, List<RoutineExercise> exercises) {
    if (exercises.isEmpty) {
      return 'Rest';
    }

    return _extractSplitTheme(exercises);
  }

  // 🎨 FUNCTION TO GET COLOR BASED ON SPLIT THEME
  Color _getSplitThemeColor(
      List<RoutineExercise> exercises, ColorScheme colorScheme) {
    if (exercises.isEmpty) {
      return colorScheme.surfaceContainerHighest;
    }

    final splitTheme = _extractSplitTheme(exercises).toLowerCase();

    // Colors based on split themes
    if (splitTheme.contains('push') || splitTheme.contains('chest')) {
      return colorScheme.primaryContainer;
    } else if (splitTheme.contains('pull') || splitTheme.contains('back')) {
      return colorScheme.secondaryContainer;
    } else if (splitTheme.contains('legs') || splitTheme.contains('lower')) {
      return colorScheme.tertiaryContainer;
    } else if (splitTheme.contains('shoulders') ||
        splitTheme.contains('arms')) {
      return colorScheme.errorContainer;
    } else if (splitTheme.contains('core')) {
      return Colors.orange.shade100;
    } else if (splitTheme.contains('upper')) {
      return colorScheme.primaryContainer;
    }

    return colorScheme.surfaceContainerHigh;
  }

  void _startTodaysDirectWorkout(BuildContext context, WeeklyRoutine routine,
      String dayKey, List<RoutineExercise> exercisesForDay) {
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);
    final theme = Theme.of(context);

    void initiateAndNavigate() {
      workoutManager.forceStartNewWorkout(
        exercisesForDay,
        workoutName:
            "${capitalize(routine.name)} - ${_formatDayWithSplit(dayKey, exercisesForDay)}",
        routineId: routine.id,
        dayKey: dayKey.toLowerCase(),
      );
      if (workoutManager.isWorkoutActive) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActiveWorkoutSessionScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Failed to start the workout."),
            backgroundColor: theme.colorScheme.error));
      }
    }

    if (workoutManager.isWorkoutActive) {
      showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
                title: const Text("Workout in Progress"),
                content: const Text(
                    "A workout session is currently active. What would you like to do?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ActiveWorkoutSessionScreen()));
                    },
                    child: Text("Resume Current",
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      initiateAndNavigate();
                    },
                    child: Text("End & Start New",
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text("Cancel")),
                ],
              ));
    } else {
      initiateAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final today = DateTime.now();
    final todayDayKey = WeeklyRoutine.daysOfWeek[today.weekday - 1];
    final todaysExercises = routine.dailyWorkouts[todayDayKey.toLowerCase()];
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange.shade800, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Offline Mode - Showing cached data",
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        Text("Your Current Plan: ${routine.name}",
            style: textTheme.headlineSmall),
        Text(
          "Duration: ${routine.durationInWeeks} weeks. Expires: ${DateFormat.yMMMd().add_jm().format(routine.expiresAt.toDate().toLocal())}",
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (todaysExercises != null &&
            todaysExercises.isNotEmpty &&
            !routine.isExpired())
          Card(
            color: _getSplitThemeColor(todaysExercises, colorScheme)
                .withAlpha((178).round()),
            elevation: 2,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              leading: Icon(Icons.fitness_center,
                  color: colorScheme.onPrimaryContainer, size: 30),
              title: Text(
                  "Today: ${_formatDayWithSplit(todayDayKey, todaysExercises)}",
                  style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${todaysExercises.length} exercises planned",
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer
                              .withAlpha((204).round()))),
                  if (_extractSplitTheme(todaysExercises) != 'Rest')
                    Text("Split: ${_extractSplitTheme(todaysExercises)}",
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer
                                .withAlpha((180).round()),
                            fontStyle: FontStyle.italic)),
                ],
              ),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text("START"),
                onPressed: () => _startTodaysDirectWorkout(
                    context, routine, todayDayKey, todaysExercises),
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        else if (!routine.isExpired()) // Rest Day
          Card(
            color: colorScheme.surfaceContainerHighest,
            elevation: 1,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              leading: Icon(Icons.hotel_rounded,
                  color: colorScheme.onSurfaceVariant, size: 30),
              title: Text(
                  "${todayDayKey.toUpperCase().substring(0, 3)} (Rest Day)",
                  style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant)),
              subtitle: Text(
                  "Enjoy your recovery, ${user?.displayName?.split(' ')[0] ?? 'User'}.",
                  style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withAlpha((204).round()))),
            ),
          ),
        const SizedBox(height: 24),
        if (!routine.isExpired()) ...[
          Text("Weekly Training Schedule:",
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: WeeklyRoutine.daysOfWeek.length,
            itemBuilder: (context, index) {
              final dayKey = WeeklyRoutine.daysOfWeek[index];
              final exercises =
                  routine.dailyWorkouts[dayKey.toLowerCase()] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: RoutineCard(
                  dayKey: dayKey,
                  exercises: exercises,
                  parentRoutine: routine,
                  onboardingData: onboardingData,
                  isToday: dayKey.toLowerCase() == todayDayKey.toLowerCase(),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
