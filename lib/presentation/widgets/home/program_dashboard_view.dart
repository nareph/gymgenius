import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';
import 'package:gymgenius/presentation/screens/active_workout_session_screen.dart';
import 'package:gymgenius/presentation/widgets/program_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProgramDashboardView extends StatelessWidget {
  final TrainingProgram program;
  final HealthProfile healthProfile;
  final DailyPlan dailyPlan;

  const ProgramDashboardView({
    super.key,
    required this.program,
    required this.healthProfile,
    required this.dailyPlan,
  });

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _extractSplitTheme(List<Exercise> exercises) {
    if (exercises.isEmpty) return 'Rest';
    for (final exercise in exercises) {
      final description = exercise.description;
      final splitMatch = RegExp(r'Split:\s*([^*\n]+)', caseSensitive: false)
          .firstMatch(description);
      if (splitMatch != null) {
        String splitTheme = splitMatch.group(1)?.trim() ?? '';
        splitTheme = splitTheme
            .replaceAll('Day', '')
            .replaceAll('Focus', '')
            .replaceAll('Training', '')
            .trim();
        final standardizedSplits = {
          'push': 'Push',
          'pull': 'Pull',
          'legs': 'Legs',
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
          if (lowerTheme.contains(entry.key)) return entry.value;
        }
        if (splitTheme.isNotEmpty) return splitTheme;
      }
    }
    // fallback
    if (exercises.any((e) =>
        e.name.toLowerCase().contains('push') ||
        e.name.toLowerCase().contains('chest'))) {
      return 'Push';
    }
    if (exercises.any((e) =>
        e.name.toLowerCase().contains('pull') ||
        e.name.toLowerCase().contains('back'))) {
      return 'Pull';
    }
    if (exercises.any((e) =>
        e.name.toLowerCase().contains('squat') ||
        e.name.toLowerCase().contains('leg'))) {
      return 'Legs';
    }
    return 'Workout';
  }

  Color _getSplitThemeColor(List<Exercise> exercises, ColorScheme colorScheme) {
    if (exercises.isEmpty) return colorScheme.surfaceContainerHighest;
    final splitTheme = _extractSplitTheme(exercises).toLowerCase();
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

  void _startTodaysWorkout(
    BuildContext context,
    List<Exercise> exercises,
    String dayKey,
  ) {
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);
    final theme = Theme.of(context);
    final sessionName = "${capitalize(program.name)} - ${capitalize(dayKey)}";

    void initiateAndNavigate() {
      workoutManager.forceStartNewWorkout(
        exercises,
        workoutName: sessionName,
        programId: program.id,
        dayKey: dayKey.toLowerCase(),
      );
      if (workoutManager.isWorkoutActive) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActiveWorkoutSessionScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to start the workout."),
            backgroundColor: theme.colorScheme.error,
          ),
        );
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
                    builder: (_) => const ActiveWorkoutSessionScreen(),
                  ),
                );
              },
              child: Text(
                "Resume Current",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                initiateAndNavigate();
              },
              child: Text(
                "End & Start New",
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
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
    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final todayDayKey = daysOfWeek[today.weekday - 1];
    final weeklySchedule = program.weeklySchedule;

    // --------------------------------------------------------------
    // The DecisionEngine's final decision for today's workout.
    // If empty, today is a rest day.
    // --------------------------------------------------------------
    final todaysExercises = dailyPlan.todayWorkout?.finalExercises ?? [];

    final user = context.read<AuthBloc>().state.user;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          "Your Current Program: ${program.name}",
          style: textTheme.headlineSmall,
        ),
        Text(
          "Duration: ${program.durationWeeks} weeks. "
          "Expires: ${DateFormat.yMMMd().add_jm().format(program.expiresAt.toLocal())}",
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          "Week ${dailyPlan.programProgress.currentWeek} of ${program.durationWeeks}",
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        // ------------------------------------------------------------------
        // Today's workout card (only if not expired and not a rest day)
        // ------------------------------------------------------------------
        if (todaysExercises.isNotEmpty && !program.isExpired)
          Card(
            color: _getSplitThemeColor(todaysExercises, colorScheme)
                .withAlpha(178),
            elevation: 2,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              leading: Icon(
                Icons.fitness_center,
                color: colorScheme.onPrimaryContainer,
                size: 30,
              ),
              title: Text(
                "Today: ${_extractSplitTheme(todaysExercises)}",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${todaysExercises.length} exercises planned",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withAlpha(204),
                    ),
                  ),
                  if (_extractSplitTheme(todaysExercises) != 'Rest')
                    Text(
                      "Split: ${_extractSplitTheme(todaysExercises)}",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withAlpha(180),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text("START"),
                onPressed: () =>
                    _startTodaysWorkout(context, todaysExercises, todayDayKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  textStyle: textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        // ------------------------------------------------------------------
        // Rest day message (when todaysExercises is empty and program valid)
        // ------------------------------------------------------------------
        else if (!program.isExpired)
          Card(
            color: colorScheme.surfaceContainerHighest,
            elevation: 1,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              leading: Icon(
                Icons.hotel_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 30,
              ),
              title: Text(
                "${capitalize(todayDayKey)} (Rest Day)",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                "Enjoy your recovery, ${user?.displayName?.split(' ')[0] ?? 'User'}.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(204),
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),

        if (!program.isExpired) ...[
          Text(
            "Weekly Training Schedule:",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysOfWeek.length,
            itemBuilder: (context, index) {
              final dayKey = daysOfWeek[index];
              final dayExercises = weeklySchedule[dayKey] ?? [];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ProgramCard(
                  dayKey: dayKey,
                  exercises: dayExercises,
                  program: program,
                  healthProfile: healthProfile,
                  isToday: dayKey == todayDayKey,
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
