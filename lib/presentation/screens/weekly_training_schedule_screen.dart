import 'package:flutter/material.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/presentation/widgets/program_card.dart';

class WeeklyTrainingScheduleScreen extends StatelessWidget {
  final TrainingProgram program;
  final HealthProfile healthProfile;

  const WeeklyTrainingScheduleScreen({
    super.key,
    required this.program,
    required this.healthProfile,
  });

  static Route<void> route({
    required TrainingProgram program,
    required HealthProfile healthProfile,
  }) {
    return MaterialPageRoute(
      builder: (_) => WeeklyTrainingScheduleScreen(
        program: program,
        healthProfile: healthProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final today = DateTime.now();
    final todayDayKey = daysOfWeek[today.weekday - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Training Schedule'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            program.name,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Review your full weekly split and planned sessions.',
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...daysOfWeek.map((dayKey) {
            final dayExercises = program.weeklySchedule[dayKey] ?? const [];
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
          }),
        ],
      ),
    );
  }
}
