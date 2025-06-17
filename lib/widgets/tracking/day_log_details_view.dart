import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayLogDetailsView extends StatelessWidget {
  final DateTime selectedDay;
  final bool isLoading;
  final bool isCompleted;
  final bool isPlanned;
  final List<Map<String, dynamic>> logs;

  // The Firestore field in 'workout_logs' collection that stores the workout completion timestamp.
  // This is used for querying logs by date.
  final String _dateFieldForWorkoutLogQuery = 'savedAt';

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
          // Display the formatted selected date.
          Text(
            DateFormat.yMMMMd('en_US')
                .format(selectedDay!), // e.g., "May 15, 2025"
            style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 16), // Increased spacing

          // Display workout status for the selected day (Completed, Planned, or Rest).
          if (isCompleted) ...[
            Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade600, size: 28), // Rounded icon
              const SizedBox(width: 10),
              Text("Workout Completed!",
                  style: textTheme.titleMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child:
                  isLoading // Show loader while logs for completed day are fetching
                      ? const Center(child: CircularProgressIndicator())
                      : logs.isEmpty
                          ? Center(
                              child: Text(
                                  "No detailed logs found for this completed workout.",
                                  style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant)))
                          : ListView.builder(
                              padding: EdgeInsets
                                  .zero, // Remove ListView default padding
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final workoutName =
                                    log['workoutName'] as String? ??
                                        "Unnamed Workout";
                                final durationSeconds =
                                    log['durationSeconds'] as int? ?? 0;
                                final exercisesLogged =
                                    log['exercises'] as List<dynamic>? ?? [];
                                final Timestamp workoutDateTimestamp =
                                    log[_dateFieldForWorkoutLogQuery]
                                            as Timestamp? ??
                                        Timestamp.now();
                                final String workoutTime = DateFormat.jm()
                                    .format(workoutDateTimestamp.toDate());

                                final exercisesWithLoggedSets = exercisesLogged
                                    .whereType<Map<String, dynamic>>()
                                    .where((ex) {
                                  final List<dynamic>? loggedSets =
                                      ex['loggedSets'] as List<dynamic>?;
                                  return loggedSets != null &&
                                      loggedSets.isNotEmpty;
                                }).toList();

                                return Card(
                                  elevation: 1.5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: ExpansionTile(
                                    leading: Icon(Icons.receipt_long_outlined,
                                        color: colorScheme.primary,
                                        size: 28), // Changed icon
                                    title: Text("$workoutName ($workoutTime)",
                                        style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                        "Duration: ${_formatDurationFromSeconds(durationSeconds)}\n"
                                        "${exercisesWithLoggedSets.length} exercises with logged sets",
                                        style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.3)),
                                    tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10), // Adjusted padding
                                    childrenPadding: const EdgeInsets.only(
                                        left: 20,
                                        right: 16,
                                        bottom: 12,
                                        top: 0), // Indent children
                                    iconColor: colorScheme.primary,
                                    collapsedIconColor:
                                        colorScheme.onSurfaceVariant,
                                    children: exercisesWithLoggedSets
                                        .map<Widget>((exData) {
                                      final String exName =
                                          exData['exerciseName'] as String? ??
                                              'Unknown Exercise';
                                      final List<dynamic> loggedSetsDynamic =
                                          exData['loggedSets']
                                                  as List<dynamic>? ??
                                              [];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(exName,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                            ...loggedSetsDynamic
                                                .whereType<
                                                    Map<String, dynamic>>()
                                                .map((setData) {
                                              final setNum =
                                                  setData['setNumber'] as int?;
                                              final reps =
                                                  setData['performedReps']
                                                      as String?;
                                              final weight =
                                                  setData['performedWeightKg']
                                                      as String?;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0, top: 4.0),
                                                child: Text(
                                                  "Set ${setNum ?? '-'}: ${reps ?? '-'} reps @ ${weight ?? '-'}kg",
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                          color: colorScheme
                                                              .onSurfaceVariant),
                                                ),
                                              );
                                            }),
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
            Row(children: [
              Icon(Icons.event_note_outlined,
                  color: colorScheme.secondary, size: 28), // Changed icon
              const SizedBox(width: 10),
              Text("Workout Planned",
                  style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 10),
            Text(
                "This day is scheduled for a workout according to your current plan. Get ready to crush it!",
                style: textTheme.bodyLarge?.copyWith(
                    color:
                        colorScheme.onSurfaceVariant)), // Slightly larger text
          ] else ...[
            // Rest Day
            Row(children: [
              Icon(Icons.bedtime_outlined,
                  color: colorScheme.onSurfaceVariant.withAlpha(178),
                  size: 28), // ~70% opacity
              const SizedBox(width: 10),
              Text("Rest Day",
                  style: textTheme.titleMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ]),
            const SizedBox(height: 10),
            Text(
                "No workout planned or completed for this day. Enjoy your recovery and come back stronger!",
                style: textTheme.bodyLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ]
        ],
      ),
    );
  }
}
