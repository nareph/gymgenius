// lib/presentation/widgets/tracking/day_log_details_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';

class DayLogDetailsView extends StatelessWidget {
  final DateTime selectedDay;
  final bool isLoading;
  final bool isCompleted;
  final bool isPlanned;
  final List<WorkoutLog> logs; // Now using domain WorkoutLog

  const DayLogDetailsView({
    super.key,
    required this.selectedDay,
    required this.isLoading,
    required this.isCompleted,
    required this.isPlanned,
    required this.logs,
  });

  String _formatDurationFromSeconds(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) return "${twoDigits(hours)}h ${minutes}m ${seconds}s";
    if (int.parse(minutes) > 0) return "${minutes}m ${seconds}s";
    return "${seconds}s";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading && !isCompleted) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMd('en_US').format(selectedDay),
            style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          if (isCompleted) ...[
            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.green.shade600, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Workout Completed!",
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : logs.isEmpty
                      ? Center(
                          child: Text(
                            "No detailed logs found for this completed workout.",
                            style: textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];

                            // Get exercises with logged sets
                            final exercisesWithSets = log.exercises
                                .where((ex) => ex.sets.isNotEmpty)
                                .toList();

                            // Build a name from the program ID and day (or fallback)
                            final workoutName =
                                "Workout (${log.day})"; // Could also use programId
                            final workoutTime =
                                DateFormat.jm().format(log.endedAt);

                            return Card(
                              elevation: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              child: ExpansionTile(
                                leading: Icon(
                                  Icons.fitness_center_rounded,
                                  color: colorScheme.primary,
                                  size: 28,
                                ),
                                title: Text(
                                  "$workoutName ($workoutTime)",
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Duration: ${_formatDurationFromSeconds(log.durationSeconds)}",
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${exercisesWithSets.length} exercises completed",
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                childrenPadding: const EdgeInsets.only(
                                    left: 20, right: 16, bottom: 12, top: 0),
                                iconColor: colorScheme.primary,
                                collapsedIconColor:
                                    colorScheme.onSurfaceVariant,
                                initiallyExpanded: false,
                                children: exercisesWithSets.isEmpty
                                    ? [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "No sets logged for this workout",
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                      ]
                                    : exercisesWithSets.map<Widget>((exercise) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 8, bottom: 4),
                                                child: Text(
                                                  exercise.name,
                                                  style: textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                              ...exercise.sets.map((set) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 16, bottom: 4),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme
                                                        .surfaceContainerHighest
                                                        .withAlpha(51),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 28,
                                                        height: 28,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: colorScheme
                                                              .primary
                                                              .withAlpha(26),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            set.setNumber
                                                                .toString(),
                                                            style: textTheme
                                                                .labelSmall
                                                                ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: colorScheme
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          "${set.reps} reps · ${set.weightKg} kg",
                                                          style: textTheme
                                                              .bodyMedium,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                              if (exercise !=
                                                  exercisesWithSets.last)
                                                const SizedBox(height: 8),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                              ),
                            );
                          },
                        ),
            ),
          ] else if (isPlanned) ...[
            Row(
              children: [
                Icon(Icons.event_note_outlined,
                    color: colorScheme.secondary, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Workout Planned",
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "This day is scheduled for a workout according to your current plan. Get ready to crush it!",
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.bedtime_outlined,
                    color: colorScheme.onSurfaceVariant.withAlpha(178),
                    size: 28),
                const SizedBox(width: 10),
                Text(
                  "Rest Day",
                  style: textTheme.titleMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "No workout planned or completed for this day. Enjoy your recovery and come back stronger!",
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
