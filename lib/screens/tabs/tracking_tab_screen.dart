// lib/screens/tabs/tracking_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // For WeeklyRoutine and RoutineExercise
import 'package:intl/intl.dart'; // For date formatting
import 'package:table_calendar/table_calendar.dart'; // For the calendar UI

class TrackingTabScreen extends StatefulWidget {
  final User user;
  const TrackingTabScreen({super.key, required this.user});

  @override
  State<TrackingTabScreen> createState() => _TrackingTabScreenState();
}

class _TrackingTabScreenState extends State<TrackingTabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime _focusedDay; // The day the calendar is currently focused on
  DateTime? _selectedDay; // The day currently selected by the user

  // Stores events loaded from the user's planned routine
  Map<DateTime, List<String>> _plannedEvents = {};
  // Stream to listen for changes in the user's document (which contains the current routine)
  Stream<DocumentSnapshot<Map<String, dynamic>>>?
      _userDocStreamForPlannedRoutine;

  // Stores dates on which workouts were completed, loaded from workout_logs
  Set<DateTime> _completedWorkoutDates = {};
  // Stream to listen for workout logs
  Stream<QuerySnapshot<Map<String, dynamic>>>? _workoutLogsStream;
  // Stores the raw log data for the _selectedDay
  List<Map<String, dynamic>> _selectedDayRawLogs = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay =
        DateTime(now.year, now.month, now.day); // Normalize to date only

    // Stream for the user's current planned routine
    _userDocStreamForPlannedRoutine = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .cast<DocumentSnapshot<Map<String, dynamic>>>(); // Ensure correct type

    // Stream for the user's workout logs
    _workoutLogsStream = _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: widget.user.uid)
        .orderBy('workoutDate', descending: true) // Most recent logs first
        .snapshots()
        .cast<QuerySnapshot<Map<String, dynamic>>>(); // Ensure correct type

    _loadPlannedRoutineEvents(); // Initial load and listener setup for planned events
    _listenToWorkoutLogsAndUpdateCalendar(); // Initial load and listener for completed logs

    if (_selectedDay != null) {
      _loadLogsForSelectedDay(
          _selectedDay!); // Load logs for the initially selected day
    }
  }

  // Listens to the user document stream to update planned workout events on the calendar.
  void _loadPlannedRoutineEvents() {
    _userDocStreamForPlannedRoutine?.listen((userDocSnapshot) {
      if (!mounted) return; // Check if the widget is still in the tree

      if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
        final Map<String, dynamic>? userData = userDocSnapshot.data();
        final Map<String, dynamic>? currentRoutineData =
            userData?['currentRoutine'] as Map<String, dynamic>?;

        if (currentRoutineData != null) {
          try {
            final routine = WeeklyRoutine.fromMap(currentRoutineData);
            _generatePlannedEventsForRoutine(routine);
          } catch (e, s) {
            print(
                "TrackingTabScreen: Error parsing currentRoutine from user document: $e\n$s");
            if (mounted) setState(() => _plannedEvents = {});
          }
        } else {
          if (mounted)
            setState(() => _plannedEvents = {}); // No current routine
        }
      } else {
        if (mounted)
          setState(() =>
              _plannedEvents = {}); // User document doesn't exist or no data
      }
    });
  }

  // Generates a map of dates to planned workout events based on the provided routine.
  void _generatePlannedEventsForRoutine(WeeklyRoutine routine) {
    final Map<DateTime, List<String>> newPlannedEvents = {};
    final Timestamp? createdAtTs = routine.generatedAt;
    if (createdAtTs == null || routine.durationInWeeks <= 0) {
      if (mounted)
        setState(() =>
            _plannedEvents = newPlannedEvents); // No start date or duration
      return;
    }

    final DateTime routineStartDate = createdAtTs.toDate();
    final Timestamp? expiresAtTs = routine.expiresAt;
    // Calculate end date carefully
    final DateTime routineEndDate = expiresAtTs?.toDate() ??
        routineStartDate.add(Duration(days: (routine.durationInWeeks * 7) - 1));

    DateTime currentDate = DateTime(
        routineStartDate.year, routineStartDate.month, routineStartDate.day);
    while (!currentDate.isAfter(routineEndDate)) {
      final dayOfWeekName = DateFormat('EEEE')
          .format(currentDate)
          .toLowerCase(); // e.g., "monday"
      final List<RoutineExercise>? exercisesForDay =
          routine.dailyWorkouts[dayOfWeekName];

      if (exercisesForDay != null && exercisesForDay.isNotEmpty) {
        final dateOnly = DateTime(currentDate.year, currentDate.month,
            currentDate.day); // Normalize date
        newPlannedEvents[dateOnly] = ['Planned Workout']; // Mark as planned
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    if (mounted) {
      setState(() => _plannedEvents = newPlannedEvents);
    }
  }

  // Listens to the workout logs stream to update completed workout dates on the calendar
  // and refresh logs for the selected day if it's affected.
  void _listenToWorkoutLogsAndUpdateCalendar() {
    _workoutLogsStream?.listen((logSnapshot) {
      // logSnapshot is QuerySnapshot<Map<String, dynamic>>
      if (!mounted) return;

      final Set<DateTime> newCompletedDates = {};
      List<Map<String, dynamic>> currentSelectedDayLogsIfUpdated = [];

      for (var doc in logSnapshot.docs) {
        // doc is QueryDocumentSnapshot<Map<String, dynamic>>
        final data = doc.data(); // data is Map<String, dynamic>
        final Timestamp? timestamp = data['workoutDate'] as Timestamp?;
        if (timestamp != null) {
          final DateTime workoutDateTime = timestamp.toDate();
          final DateTime workoutDateOnly = DateTime(
              workoutDateTime.year, workoutDateTime.month, workoutDateTime.day);
          newCompletedDates
              .add(workoutDateOnly); // Add to set of completed dates

          // If this log is for the currently selected day, add it to a temporary list
          if (_selectedDay != null &&
              isSameDay(workoutDateOnly, _selectedDay!)) {
            currentSelectedDayLogsIfUpdated
                .add({...data, 'id': doc.id}); // Clone map and add document ID
          }
        }
      }

      if (mounted) {
        setState(() {
          _completedWorkoutDates = newCompletedDates;
          // If the selected day was updated, refresh its logs
          if (_selectedDay != null &&
              newCompletedDates.contains(_selectedDay!)) {
            // Sort logs for the selected day (most recent first)
            currentSelectedDayLogsIfUpdated.sort((a, b) {
              Timestamp tsA = (a['workoutDate'] as Timestamp?) ??
                  (a['savedAt'] as Timestamp?) ??
                  Timestamp.now();
              Timestamp tsB = (b['workoutDate'] as Timestamp?) ??
                  (b['savedAt'] as Timestamp?) ??
                  Timestamp.now();
              return tsB.compareTo(tsA);
            });
            _selectedDayRawLogs = currentSelectedDayLogsIfUpdated;
          } else if (_selectedDay != null &&
              !newCompletedDates.contains(_selectedDay!)) {
            // If the selected day no longer has completed workouts (e.g., data deleted), clear its logs
            _selectedDayRawLogs = [];
          }
        });
      }
    });
  }

  // Fetches workout logs specifically for the given day.
  Future<void> _loadLogsForSelectedDay(DateTime day) async {
    if (!mounted) return;
    final normalizedDay = DateTime(day.year, day.month, day.day); // Date only

    // Create Firestore timestamp range for the selected day
    final startOfDay = Timestamp.fromDate(normalizedDay);
    final endOfDay =
        Timestamp.fromDate(normalizedDay.add(const Duration(days: 1)));

    try {
      final logSnapshot = await _firestore
          .collection('workout_logs')
          .where('userId', isEqualTo: widget.user.uid)
          .where('workoutDate', isGreaterThanOrEqualTo: startOfDay)
          .where('workoutDate', isLessThan: endOfDay)
          .orderBy('workoutDate', descending: true)
          .get(); // logSnapshot is QuerySnapshot<Map<String, dynamic>>

      if (!mounted) return;

      setState(() {
        _selectedDayRawLogs = logSnapshot.docs.map((doc) {
          // doc is QueryDocumentSnapshot<Map<String, dynamic>>
          final data = doc.data(); // data is Map<String, dynamic>
          return {...data, 'id': doc.id}; // Clone map and add document ID
        }).toList();
      });
    } catch (e, s) {
      print(
          "TrackingTabScreen: Error loading logs for selected day $normalizedDay: $e\n$s");
      if (mounted) {
        setState(() => _selectedDayRawLogs = []); // Clear logs on error
      }
      // Optionally show a SnackBar to the user
    }
  }

  // Provides events for the TableCalendar's eventLoader.
  List<String> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day); // Normalize date
    List<String> events = [];
    if (_completedWorkoutDates.contains(dateOnly)) {
      events.add('Completed'); // Mark as completed if a log exists
    } else if (_plannedEvents[dateOnly]?.isNotEmpty ?? false) {
      events.add('Planned'); // Mark as planned if in the routine
    }
    return events;
  }

  // Callback for when a day is selected on the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      // Check if a new day is selected
      if (mounted) {
        setState(() {
          _selectedDay = normalizedSelectedDay;
          _focusedDay = focusedDay; // Update focused day as well
          _selectedDayRawLogs = []; // Clear logs for the previous day initially
        });
        _loadLogsForSelectedDay(
            normalizedSelectedDay); // Load logs for the newly selected day
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // No AppBar needed if this is a tab view within a larger Scaffold
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 20, 16, 12), // Adjusted padding
            child: Text(
              "Track Your Progress",
              style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          TableCalendar<String>(
            // Specify event type if known, helps with `eventLoader` type
            locale: 'en_US', // Set locale for date formatting
            firstDay: DateTime.utc(
                DateTime.now().year - 2, 1, 1), // Example: 2 years back
            lastDay: DateTime.utc(
                DateTime.now().year + 2, 12, 31), // Example: 2 years forward
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.month, // Default to month view
            startingDayOfWeek: StartingDayOfWeek.monday, // Start week on Monday
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    // Position markers nicely
                    right: 2,
                    bottom: 2,
                    child: _buildEventsMarker(events, colorScheme),
                  );
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                  color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
              todayDecoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold),
              outsideDaysVisible: false, // Hide days outside the current month
              weekendTextStyle:
                  TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible:
                  false, // Hide format button (Month/2 Weeks/Week)
              titleCentered: true,
              titleTextStyle: textTheme.titleMedium ??
                  const TextStyle(fontWeight: FontWeight.bold), // Title style
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: colorScheme.primary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: colorScheme.primary),
            ),
            onPageChanged: (focusedDay) {
              if (mounted) {
                setState(() => _focusedDay =
                    focusedDay); // Update focused day when page changes
              }
            },
          ),
          Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withOpacity(0.5)),
          Expanded(
            child: _buildSelectedDayInfo(context, textTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  // Builds a small marker dot for calendar days with events.
  Widget _buildEventsMarker(List<String> events, ColorScheme colorScheme) {
    bool isCompleted = events.contains('Completed');
    bool isPlanned = events.contains('Planned');

    Color markerColor;
    if (isCompleted) {
      markerColor = Colors.green.shade600; // Green for completed
    } else if (isPlanned) {
      markerColor = colorScheme.secondary; // Secondary theme color for planned
    } else {
      return const SizedBox.shrink(); // No marker if no recognized event type
    }
    return Container(
      width: 7, height: 7, // Slightly smaller marker
      decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
    );
  }

  // Formats duration from total seconds to a HH:MM:SS or MM:SS string.
  String _formatDurationFromSeconds(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "${twoDigits(hours)}h ${minutes}m ${seconds}s"; // More descriptive
    }
    return "${minutes}m ${seconds}s";
  }

  // Builds the UI to display information for the selected day.
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMd('en_US')
                .format(_selectedDay!), // e.g., "January 15, 2024"
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12), // Consistent spacing

          if (isWorkoutCompletedToday) ...[
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade700, size: 26), // Using outline
                const SizedBox(width: 8),
                Text("Workout Completed!",
                    style: textTheme.titleMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _selectedDayRawLogs.isEmpty
                  ? Center(
                      child: Text("Loading workout details...",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant)))
                  : ListView.builder(
                      itemCount: _selectedDayRawLogs.length,
                      itemBuilder: (context, index) {
                        final log = _selectedDayRawLogs[index];
                        final workoutName =
                            log['workoutName'] as String? ?? "Unnamed Workout";
                        final durationSeconds =
                            log['durationInSeconds'] as int? ?? 0;
                        final exercisesLogged =
                            log['completedExercises'] as List<dynamic>? ?? [];

                        final Timestamp workoutDateTimestamp =
                            log['workoutDate'] as Timestamp? ?? Timestamp.now();
                        final String workoutTime = DateFormat.jm().format(
                            workoutDateTimestamp.toDate()); // e.g., 5:30 PM

                        return Card(
                          elevation: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            leading: Icon(Icons.assessment_outlined,
                                color: colorScheme.primary,
                                size: 26), // Changed icon
                            title: Text("$workoutName ($workoutTime)",
                                style: textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                "Duration: ${_formatDurationFromSeconds(durationSeconds)}\n"
                                "${exercisesLogged.where((ex) => (ex['loggedSets'] as List<dynamic>?)?.isNotEmpty ?? false).length} exercises with logged sets",
                                style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            childrenPadding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 12, top: 0),
                            iconColor: colorScheme.primary,
                            collapsedIconColor: colorScheme.onSurfaceVariant,
                            children: exercisesLogged
                                .map<Widget>((exMap) {
                                  final exData = exMap as Map<String, dynamic>;
                                  final String exName =
                                      exData['exerciseName'] as String? ??
                                          'Unknown Exercise';
                                  final List<dynamic> loggedSetsDynamic =
                                      exData['loggedSets'] as List<dynamic>? ??
                                          [];

                                  if (loggedSetsDynamic.isEmpty)
                                    return const SizedBox
                                        .shrink(); // Don't show if no sets logged

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(exName,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        ...loggedSetsDynamic.map((setMap) {
                                          final setData =
                                              setMap as Map<String, dynamic>;
                                          final setNum =
                                              setData['setNumber'] as int?;
                                          final reps = setData['performedReps']
                                              as String?;
                                          final weight =
                                              setData['performedWeightKg']
                                                  as String?;
                                          // final Timestamp setLoggedAtTs = setData['loggedAt'] as Timestamp? ?? Timestamp.now();
                                          // final String setTime = DateFormat.jm().format(setLoggedAtTs.toDate()); // Time for each set might be too much detail

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, top: 3.0),
                                            child: Text(
                                              "Set ${setNum ?? '-'}: ${reps ?? '-'} reps @ ${weight ?? '-'}kg",
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: colorScheme
                                                          .onSurfaceVariant),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  );
                                })
                                .where((widget) => widget is! SizedBox)
                                .toList(), // Filter out empty SizedBoxes
                          ),
                        );
                      },
                    ),
            ),
          ] else if (isWorkoutPlannedToday) ...[
            Row(
              children: [
                Icon(Icons.event_available_outlined,
                    color: colorScheme.secondary, size: 26), // Changed icon
                const SizedBox(width: 8),
                Text("Workout Planned",
                    style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                "This day is scheduled for a workout according to your current plan. Get ready!",
                style: textTheme.bodyMedium),
          ] else ...[
            // Rest day or no plan
            Row(
              children: [
                Icon(Icons.bed_outlined,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    size: 26), // Changed icon
                const SizedBox(width: 8),
                Text("Rest Day",
                    style: textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                "No workout planned or completed for this day. Enjoy your rest!",
                style: textTheme.bodyMedium),
          ]
        ],
      ),
    );
  }
}
