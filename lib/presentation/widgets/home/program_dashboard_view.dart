// lib/presentation/widgets/home/program_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/providers/workout_session_manager.dart';
import 'package:gymgenius/presentation/screens/active_workout_session_screen.dart';
import 'package:gymgenius/presentation/screens/weekly_training_schedule_screen.dart';
import 'package:gymgenius/presentation/widgets/home/coach_home_card.dart';
import 'package:gymgenius/presentation/widgets/home/health_decision_card.dart';
import 'package:gymgenius/presentation/widgets/home/home_health_platform_card.dart';
import 'package:gymgenius/presentation/widgets/home/home_progress_summary_card.dart';
import 'package:gymgenius/presentation/widgets/home/nutrition_summary_card.dart';
import 'package:gymgenius/presentation/widgets/home/recovery_summary_card.dart';
import 'package:gymgenius/presentation/widgets/home/workout_adaptation_banner.dart';
import 'package:gymgenius/presentation/viewmodels/home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Displays the main dashboard for an active training program.
///
/// Recovery information is displayed only when a real DailyCheckIn has
/// produced a RecoveryStatus.
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

  Color _getSplitColor(
    String splitName,
    ColorScheme colorScheme,
  ) {
    final lower = splitName.toLowerCase();

    if (lower.contains('chest') || lower.contains('push')) {
      return colorScheme.primaryContainer;
    }

    if (lower.contains('back') || lower.contains('pull')) {
      return colorScheme.secondaryContainer;
    }

    if (lower.contains('legs') ||
        lower.contains('lower') ||
        lower.contains('glutes')) {
      return colorScheme.tertiaryContainer;
    }

    if (lower.contains('shoulders') ||
        lower.contains('arms') ||
        lower.contains('triceps') ||
        lower.contains('biceps')) {
      return colorScheme.errorContainer;
    }

    if (lower.contains('core') || lower.contains('abs')) {
      return Colors.orange.shade100;
    }

    if (lower.contains('upper')) {
      return colorScheme.primaryContainer;
    }

    return colorScheme.surfaceContainerHigh;
  }

  void _startTodaysWorkout(
    BuildContext context,
    List<Exercise> exercises,
    String dayKey,
  ) {
    final workoutManager = Provider.of<WorkoutSessionManager>(
      context,
      listen: false,
    );
    final theme = Theme.of(context);
    final sessionName = "${capitalize(program.name)} - ${capitalize(dayKey)}";

    final userId = context.read<AuthBloc>().state.user?.id;

    void initiateAndNavigate() {
      workoutManager.forceStartNewWorkout(
        exercises,
        workoutName: sessionName,
        userId: userId,
        programId: program.id,
        dayKey: dayKey.toLowerCase(),
      );

      if (workoutManager.isWorkoutActive) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ActiveWorkoutSessionScreen(),
          ),
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
            "A workout session is currently active. What would you like to do?",
          ),
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

    const daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    final todayDayKey = daysOfWeek[today.weekday - 1];
    final todaysExercises = dailyPlan.todayWorkout.finalExercises;
    final splitDisplayName = dailyPlan.todayWorkout.splitDisplayName;
    final user = context.read<AuthBloc>().state.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Your Current Program: ${program.name}",
          style: textTheme.headlineSmall,
        ),
        Text(
          "Duration: ${program.durationWeeks} weeks. "
          "Expires: ${DateFormat.yMMMd().add_jm().format(program.expiresAt.toLocal())}",
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          "Week ${dailyPlan.programProgress.currentWeek} of ${program.durationWeeks}",
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        // ==========================================================
        // Today's workout
        // ==========================================================

        if (todaysExercises.isNotEmpty && !program.isExpired)
          Card(
            color: _getSplitColor(splitDisplayName, colorScheme).withAlpha(178),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              leading: Icon(
                Icons.fitness_center,
                color: colorScheme.onPrimaryContainer,
                size: 30,
              ),
              title: Text(
                "Today: $splitDisplayName",
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
                  if (splitDisplayName != 'Rest' &&
                      splitDisplayName != 'Workout')
                    Text(
                      "Split: $splitDisplayName",
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
                onPressed: () => _startTodaysWorkout(
                  context,
                  todaysExercises,
                  todayDayKey,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        else if (!program.isExpired)
          Card(
            color: colorScheme.surfaceContainerHighest,
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
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

        // ==========================================================
        // AI Coach
        // ==========================================================

        Builder(
          builder: (context) {
            final homeVm = context.watch<HomeViewModel>();

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CoachHomeCard(
                response: homeVm.dailyCoaching,
                isLoading: homeVm.isLoadingCoaching,
                onRetry: homeVm.retryCoaching,
                dailyPlan: dailyPlan,
              ),
            );
          },
        ),

        // ==========================================================
        // Health Platform
        // ==========================================================

        if (dailyPlan.healthPlatformSnapshot != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: HomeHealthPlatformCard(
              snapshot: dailyPlan.healthPlatformSnapshot!,
            ),
          ),

        // ==========================================================
        // Workout adaptation
        // ==========================================================

        if (dailyPlan.finalDecision.requiresAdaptation) ...[
          const SizedBox(height: 16),
          WorkoutAdaptationBanner(decision: dailyPlan.finalDecision),
        ],

        // ==========================================================
        // Health decision
        // ==========================================================

        if (dailyPlan.healthDecision != null) ...[
          const SizedBox(height: 16),
          HealthDecisionCard(decision: dailyPlan.healthDecision!),
        ],

        // ==========================================================
        // Recovery
        // ==========================================================

        if (dailyPlan.recoveryStatus != null) ...[
          const SizedBox(height: 16),
          RecoverySummaryCard(status: dailyPlan.recoveryStatus!),
        ],

        // ==========================================================
        // Nutrition
        // ==========================================================

        if (dailyPlan.nutritionPlan != null) ...[
          const SizedBox(height: 16),
          NutritionSummaryCard(plan: dailyPlan.nutritionPlan!),
        ],

        // ==========================================================
        // Progress
        // ==========================================================

        if (dailyPlan.progressSnapshot != null) ...[
          const SizedBox(height: 16),
          HomeProgressSummaryCard(snapshot: dailyPlan.progressSnapshot!),
        ],

        const SizedBox(height: 24),

        // ==========================================================
        // Weekly schedule
        // ==========================================================

        if (!program.isExpired) ...[
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                WeeklyTrainingScheduleScreen.route(
                  program: program,
                  healthProfile: healthProfile,
                ),
              );
            },
            icon: const Icon(Icons.calendar_view_week_rounded),
            label: const Text('View Weekly Training Schedule'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
