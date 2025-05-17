// lib/screens/tabs/tracking_tab_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For WeeklyRoutine and RoutineExercise
import 'package:gymgenius/services/logger_service.dart'; // Import the logger service
import 'package:intl/intl.dart'; // For date formatting
import 'package:table_calendar/table_calendar.dart'; // For the calendar UI

// TrackingTabScreen: Displays a calendar to track planned and completed workouts.
// Users can select a day to see details of workouts logged for that day.
class TrackingTabScreen extends StatefulWidget {
  final User user; // The currently authenticated user.
  const TrackingTabScreen({super.key, required this.user});

  @override
  State<TrackingTabScreen> createState() => _TrackingTabScreenState();
}

class _TrackingTabScreenState extends State<TrackingTabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime
      _focusedDay; // The day the calendar is currently focused on (e.g., current month).
  DateTime?
      _selectedDay; // The day currently selected by the user on the calendar.

  // Stores events derived from the user's current routine, marking planned workout days.
  // Key: Normalized DateTime (date only), Value: List of event descriptions (e.g., ['Planned']).
  Map<DateTime, List<String>> _plannedEvents = {};
  StreamSubscription?
      _userDocSubscription; // Subscription to the user's document stream.

  // Stores dates for which workouts have been completed, used for calendar markers.
  Set<DateTime> _completedWorkoutDates = {};
  StreamSubscription?
      _workoutLogsSubscription; // Subscription to the user's workout logs.

  // Stores the raw log data for the _selectedDay to display details.
  List<Map<String, dynamic>> _selectedDayRawLogs = [];
  bool _isLoadingSelectedDayLogs =
      false; // To show a loader when fetching logs for a day.

  // The Firestore field in 'workout_logs' collection that stores the workout completion timestamp.
  // This is used for querying logs by date.
  final String _dateFieldForWorkoutLogQuery =
      'savedAt'; // Or 'startTime' if that's more appropriate for the workout date

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = DateTime(now.year, now.month,
        now.day); // Normalize to date only for initial selection
    Log.debug(
        "TrackingTabScreen initState: _selectedDay initialized to $_selectedDay");

    // Stream for the user's document to get the current routine for planned events.
    final userDocStream = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .cast<DocumentSnapshot<Map<String, dynamic>>>();

    // Stream for the user's workout logs to mark completed days and fetch details.
    final workoutLogsStream = _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: widget.user.uid)
        // Order by the date field to potentially optimize queries or processing.
        .orderBy(_dateFieldForWorkoutLogQuery, descending: true)
        .snapshots()
        .cast<QuerySnapshot<Map<String, dynamic>>>();

    _subscribeToRoutineUpdates(userDocStream);
    _subscribeToWorkoutLogs(workoutLogsStream);

    if (_selectedDay != null) {
      _loadLogsForSelectedDay(
          _selectedDay!); // Load logs for the initially selected day
    }
  }

  @override
  void dispose() {
    Log.debug(
        "TrackingTabScreen: Disposing and cancelling stream subscriptions.");
    _userDocSubscription?.cancel();
    _workoutLogsSubscription?.cancel();
    super.dispose();
  }

  // Subscribes to the user's document stream to update planned events when the routine changes.
  void _subscribeToRoutineUpdates(
      Stream<DocumentSnapshot<Map<String, dynamic>>> stream) {
    _userDocSubscription?.cancel(); // Cancel any existing subscription
    _userDocSubscription = stream.listen((userDocSnapshot) {
      Log.debug(
          "TrackingTabScreen: User document snapshot received. Exists: ${userDocSnapshot.exists}");
      if (!mounted) return;

      if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
        final Map<String, dynamic>? userData = userDocSnapshot.data();
        final Map<String, dynamic>? currentRoutineData =
            userData?['currentRoutine'] as Map<String, dynamic>?;

        if (currentRoutineData != null) {
          try {
            Log.debug(
                "TrackingTabScreen: Parsing currentRoutine for _plannedEvents.");
            final routine = WeeklyRoutine.fromMap(currentRoutineData);
            _generatePlannedEventsForRoutine(
                routine); // Regenerate planned events
          } catch (e, s) {
            Log.error(
                "TrackingTabScreen: Error parsing currentRoutine from user document: $e",
                error: e,
                stackTrace: s);
            if (mounted) setState(() => _plannedEvents = {});
          }
        } else {
          Log.debug(
              "TrackingTabScreen: No currentRoutine found in user document.");
          if (mounted) {
            setState(() =>
                _plannedEvents = {}); // Clear planned events if no routine
          }
        }
      } else {
        Log.debug(
            "TrackingTabScreen: User document does not exist or no data.");
        if (mounted) setState(() => _plannedEvents = {});
      }
    }, onError: (error, stackTrace) {
      Log.error("TrackingTabScreen: Error in userDocStream listener: $error",
          error: error, stackTrace: stackTrace);
      if (mounted) setState(() => _plannedEvents = {});
    });
  }

  // Generates a map of planned workout events based on the provided routine.
  void _generatePlannedEventsForRoutine(WeeklyRoutine routine) {
    final Map<DateTime, List<String>> newPlannedEvents = {};
    // Ensure routine has a valid start date and duration.
    if (routine.durationInWeeks <= 0 ||
        routine.dailyWorkouts.isEmpty) {
      Log.debug(
          "TrackingTabScreen: Invalid routine data for generating planned events (generatedAt, duration, or dailyWorkouts missing).");
      if (mounted) setState(() => _plannedEvents = newPlannedEvents);
      return;
    }

    final DateTime routineStartDate = routine.generatedAt.toDate();
    // Calculate end date: if expiresAt exists use it, otherwise calculate from duration.
    final DateTime routineEndDate = routine.expiresAt?.toDate() ??
        routineStartDate.add(Duration(days: (routine.durationInWeeks * 7) - 1));

    DateTime currentDate = DateTime(
        routineStartDate.year, routineStartDate.month, routineStartDate.day);
    int safetyCounter = 0; // Prevent infinite loops
    final List<String> dayKeys =
        WeeklyRoutine.daysOfWeek; // ["monday", "tuesday", ...]

    // Iterate through the routine duration to mark planned workout days.
    while (!currentDate.isAfter(routineEndDate) &&
        safetyCounter < (routine.durationInWeeks * 7 + 21)) {
      // Added a bit more buffer
      safetyCounter++;
      final dayOfWeekIndex = currentDate.weekday - 1; // Monday = 0, Sunday = 6

      if (dayOfWeekIndex >= 0 && dayOfWeekIndex < dayKeys.length) {
        final String dayKey =
            dayKeys[dayOfWeekIndex].toLowerCase(); // Ensure lowercase key
        final List<RoutineExercise>? exercisesForDay =
            routine.dailyWorkouts[dayKey];

        if (exercisesForDay != null && exercisesForDay.isNotEmpty) {
          final DateTime dateOnly =
              DateTime(currentDate.year, currentDate.month, currentDate.day);
          newPlannedEvents[dateOnly] = [
            'Planned'
          ]; // Mark as a planned workout day
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    Log.debug(
        "TrackingTabScreen: Generated ${newPlannedEvents.length} planned events for routine '${routine.name}'.");
    if (mounted) setState(() => _plannedEvents = newPlannedEvents);
  }

  // Subscribes to the workout logs stream to update completed workout dates and selected day's log details.
  void _subscribeToWorkoutLogs(
      Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
    _workoutLogsSubscription?.cancel();
    _workoutLogsSubscription = stream.listen((logSnapshot) {
      Log.debug(
          "TrackingTabScreen (LogListener): Received ${logSnapshot.docs.length} workout log documents.");
      if (!mounted) return;

      final Set<DateTime> newCompletedDates = {};
      bool selectedDayLogsNeedRefresh = false;

      for (var doc in logSnapshot.docs) {
        final data = doc.data();
        final Timestamp? timestamp =
            data[_dateFieldForWorkoutLogQuery] as Timestamp?;
        if (timestamp != null) {
          final DateTime workoutDateTime = timestamp.toDate();
          final DateTime workoutDateOnly = DateTime(
              workoutDateTime.year, workoutDateTime.month, workoutDateTime.day);
          newCompletedDates.add(workoutDateOnly);
          // If the current log update affects the selected day, mark it for log refresh.
          if (_selectedDay != null &&
              isSameDay(workoutDateOnly, _selectedDay!)) {
            selectedDayLogsNeedRefresh = true;
          }
        }
      }

      // Update _completedWorkoutDates if there's a change for calendar markers.
      if (_completedWorkoutDates.length != newCompletedDates.length ||
          !_completedWorkoutDates.containsAll(newCompletedDates)) {
        setState(() {
          _completedWorkoutDates = newCompletedDates;
          Log.debug(
              "TrackingTabScreen (LogListener): _completedWorkoutDates updated. Count: ${newCompletedDates.length}");
        });
      }

      // Refresh logs for the selected day if needed.
      if (_selectedDay != null) {
        final bool wasSelectedDayCompleted =
            _selectedDayRawLogs.isNotEmpty; // Approximation
        final bool isSelectedDayNowCompleted =
            newCompletedDates.contains(_selectedDay!);

        if (selectedDayLogsNeedRefresh ||
            (wasSelectedDayCompleted != isSelectedDayNowCompleted)) {
          Log.debug(
              "TrackingTabScreen (LogListener): Selected day $_selectedDay logs require refresh.");
          _loadLogsForSelectedDay(_selectedDay!);
        }
      }
    }, onError: (error, stackTrace) {
      Log.error(
          "TrackingTabScreen (LogListener): Error in workoutLogsStream: $error",
          error: error,
          stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _completedWorkoutDates = {};
          _selectedDayRawLogs = [];
        });
      }
    });
  }

  // Fetches and loads workout logs for a specific selected day.
  Future<void> _loadLogsForSelectedDay(DateTime day) async {
    if (!mounted) return;
    final normalizedDay = DateTime(day.year, day.month, day.day);
    Log.debug(
        "TrackingTabScreen: Loading logs for selected day: $normalizedDay");
    setState(() => _isLoadingSelectedDayLogs = true);

    final startOfDay = Timestamp.fromDate(normalizedDay);
    final endOfDay =
        Timestamp.fromDate(normalizedDay.add(const Duration(days: 1)));

    try {
      final logSnapshot = await _firestore
          .collection('workout_logs')
          .where('userId', isEqualTo: widget.user.uid)
          .where(_dateFieldForWorkoutLogQuery,
              isGreaterThanOrEqualTo: startOfDay)
          .where(_dateFieldForWorkoutLogQuery, isLessThan: endOfDay)
          .orderBy(_dateFieldForWorkoutLogQuery,
              descending: true) // Show most recent logs first for the day
          .get();

      if (!mounted) return;
      final newLogs = logSnapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'id': doc.id}; // Include document ID for potential use
      }).toList();

      // Only update state if logs have actually changed to prevent unnecessary rebuilds.
      // This requires a deep comparison or comparison by a unique identifier if available.
      // For simplicity, we update if length changes or content might differ (can be refined).
      if (!listEquals(_selectedDayRawLogs.map((e) => e['id']).toList(),
          newLogs.map((e) => e['id']).toList())) {
        setState(() {
          _selectedDayRawLogs = newLogs;
          Log.debug(
              "TrackingTabScreen: Loaded ${_selectedDayRawLogs.length} logs for $normalizedDay.");
        });
      } else {
        Log.debug("TrackingTabScreen: Logs for $normalizedDay are unchanged.");
      }
    } catch (e, s) {
      Log.error("TrackingTabScreen: Error loading logs for $normalizedDay: $e",
          error: e, stackTrace: s);
      if (mounted) {
        setState(() => _selectedDayRawLogs = []); // Clear logs on error
      }
    } finally {
      if (mounted) setState(() => _isLoadingSelectedDayLogs = false);
    }
  }

  // Provides a list of event markers for a given day on the calendar.
  List<String> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    List<String> events = [];
    if (_completedWorkoutDates.contains(dateOnly)) {
      events.add('Completed'); // Marker for completed workouts
    } else if (_plannedEvents[dateOnly]?.isNotEmpty ?? false) {
      events.add('Planned'); // Marker for planned workouts
    }
    return events;
  }

  // Callback when a day is selected on the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    Log.debug(
        "TrackingTabScreen: _onDaySelected: selected $normalizedSelectedDay, current _selectedDay $_selectedDay");

    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDay = normalizedSelectedDay;
          _focusedDay = focusedDay; // Update focused day as well
          _selectedDayRawLogs = []; // Clear previous day's logs immediately
          _isLoadingSelectedDayLogs = true; // Indicate loading for the new day
          Log.debug(
              "TrackingTabScreen: New day selected. _selectedDayRawLogs cleared, loading new logs.");
        });
        _loadLogsForSelectedDay(
            normalizedSelectedDay); // Fetch logs for the newly selected day
      }
    } else {
      // If the same day is tapped again, optionally refresh its logs.
      Log.debug(
          "TrackingTabScreen: Same day selected. Forcing reload of logs.");
      _loadLogsForSelectedDay(normalizedSelectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    Log.debug(
        "TrackingTabScreen build: _selectedDay: $_selectedDay, completed: ${_completedWorkoutDates.length}, planned: ${_plannedEvents.length}, logsForSelectedDay: ${_selectedDayRawLogs.length}");

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 20, 16, 12), // Consistent padding
            child: Text(
              "Track Your Progress", // Screen title
              style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          // Calendar widget
          TableCalendar<String>(
            locale: 'en_US', // Calendar locale
            firstDay: DateTime.utc(
                DateTime.now().year - 2, 1, 1), // Calendar range start
            lastDay: DateTime.utc(
                DateTime.now().year + 2, 12, 31), // Calendar range end
            focusedDay: _focusedDay, // The day currently in focus (month view)
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day), // Determines if a day is selected
            onDaySelected: _onDaySelected, // Callback for when a day is tapped
            eventLoader:
                _getEventsForDay, // Function to load events for each day
            calendarFormat: CalendarFormat.month, // Display format
            startingDayOfWeek:
                StartingDayOfWeek.monday, // Week starts on Monday
            calendarBuilders: CalendarBuilders(
              // Custom builders for calendar components
              markerBuilder: (context, day, events) {
                // Custom marker for events
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 2,
                    bottom: 2,
                    child: _buildEventsMarker(events, colorScheme),
                  );
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              // Styling for the calendar
              selectedDecoration: BoxDecoration(
                  color: colorScheme.primary, shape: BoxShape.circle),
              selectedTextStyle: TextStyle(
                  color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
              todayDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha((178).round()),
                  shape: BoxShape.circle), // ~70% opacity
              todayTextStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold),
              outsideDaysVisible: false, // Hide days outside the current month
              weekendTextStyle: TextStyle(
                  color: colorScheme.onSurface
                      .withAlpha((178).round())), // ~70% opacity
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
            ),
            headerStyle: HeaderStyle(
              // Styling for the calendar header
              formatButtonVisible:
                  false, // Hide format button (e.g., week/month toggle)
              titleCentered: true,
              titleTextStyle: textTheme.titleMedium ??
                  const TextStyle(fontWeight: FontWeight.bold),
              leftChevronIcon: Icon(Icons.chevron_left_rounded,
                  color: colorScheme.primary, size: 28),
              rightChevronIcon: Icon(Icons.chevron_right_rounded,
                  color: colorScheme.primary, size: 28),
            ),
            onPageChanged: (focusedDay) {
              // Callback when calendar page (month) changes
              if (mounted) {
                setState(() => _focusedDay = focusedDay);
              }
            },
          ),
          Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant
                  .withAlpha((128).round())), // ~50% opacity
          // Expanded section to display information for the selected day
          Expanded(
            child: _buildSelectedDayInfo(context, textTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  // Builds a custom marker for calendar events (Planned/Completed).
  Widget _buildEventsMarker(List<String> events, ColorScheme colorScheme) {
    bool isCompleted = events.contains('Completed');
    bool isPlanned = events.contains('Planned');
    Color markerColor;

    if (isCompleted) {
      markerColor = Colors.green.shade600; // Green for completed
    } else if (isPlanned) {
      markerColor = colorScheme.secondary; // Secondary color for planned
    } else {
      return const SizedBox.shrink(); // No marker if no relevant event
    }
    return Container(
      width: 8, // Slightly larger marker
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
    );
  }

  // Formats a duration in seconds into a human-readable string (e.g., "01h 15m 30s").
  String _formatDurationFromSeconds(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "${twoDigits(hours)}h ${minutes}m ${seconds}s";
    }
    if (int.parse(minutes) > 0) {
      // Show minutes only if non-zero
      return "${minutes}m ${seconds}s";
    }
    return "${seconds}s"; // Only show seconds if minutes and hours are zero
  }

  // Builds the UI to display details for the selected day.
  Widget _buildSelectedDayInfo(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_selectedDay == null) {
      return Center(
          child:
              Text("Select a day to see details.", style: textTheme.bodyLarge));
    }

    final normalizedSelectedDay =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final bool isWorkoutCompletedToday =
        _completedWorkoutDates.contains(normalizedSelectedDay);
    final bool isWorkoutPlannedToday =
        _plannedEvents[normalizedSelectedDay]?.isNotEmpty ?? false;

    if (_isLoadingSelectedDayLogs &&
        !isWorkoutCompletedToday &&
        !isWorkoutPlannedToday) {
      // Show a simple loading indicator if fetching for a day that's not marked yet
      // This might be brief as it resolves to "Rest Day".
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Adjust padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the formatted selected date.
          Text(
            DateFormat.yMMMMd('en_US')
                .format(_selectedDay!), // e.g., "May 15, 2025"
            style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 16), // Increased spacing

          // Display workout status for the selected day (Completed, Planned, or Rest).
          if (isWorkoutCompletedToday) ...[
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
                  _isLoadingSelectedDayLogs // Show loader while logs for completed day are fetching
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedDayRawLogs.isEmpty
                          ? Center(
                              child: Text(
                                  "No detailed logs found for this completed workout.",
                                  style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant)))
                          : ListView.builder(
                              padding: EdgeInsets
                                  .zero, // Remove ListView default padding
                              itemCount: _selectedDayRawLogs.length,
                              itemBuilder: (context, index) {
                                final log = _selectedDayRawLogs[index];
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
          ] else if (isWorkoutPlannedToday) ...[
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
