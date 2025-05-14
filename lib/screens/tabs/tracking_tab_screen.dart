// lib/screens/tabs/tracking_tab_screen.dart
import 'dart:async';

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

  Map<DateTime, List<String>> _plannedEvents = {};
  StreamSubscription? _userDocSubscription;

  Set<DateTime> _completedWorkoutDates = {};
  StreamSubscription? _workoutLogsSubscription;
  List<Map<String, dynamic>> _selectedDayRawLogs = [];

  final String _dateFieldForWorkoutLog =
      'savedAt'; // Ou 'workoutDate' si c'est votre champ principal

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay =
        DateTime(now.year, now.month, now.day); // Normalize to date only
    print(
        "TrackingTabScreen initState: _selectedDay initialisé à $_selectedDay");

    final userDocStreamForPlannedRoutine = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .cast<DocumentSnapshot<Map<String, dynamic>>>();

    final workoutLogsStream = _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: widget.user.uid)
        .orderBy(_dateFieldForWorkoutLog, descending: true)
        .snapshots()
        .cast<QuerySnapshot<Map<String, dynamic>>>();

    _loadPlannedRoutineEvents(userDocStreamForPlannedRoutine);
    _listenToWorkoutLogsAndUpdateCalendar(workoutLogsStream);

    if (_selectedDay != null) {
      _loadLogsForSelectedDay(_selectedDay!);
    }
  }

  @override
  void dispose() {
    print("TrackingTabScreen: Disposing and cancelling listeners.");
    _userDocSubscription?.cancel();
    _workoutLogsSubscription?.cancel();
    super.dispose();
  }

  void _loadPlannedRoutineEvents(
      Stream<DocumentSnapshot<Map<String, dynamic>>> stream) {
    _userDocSubscription?.cancel();
    _userDocSubscription = stream.listen((userDocSnapshot) {
      print(
          "TrackingTabScreen: User doc snapshot received. Exists: ${userDocSnapshot.exists}");
      if (!mounted) return;

      if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
        final Map<String, dynamic>? userData = userDocSnapshot.data();
        final Map<String, dynamic>? currentRoutineData =
            userData?['currentRoutine'] as Map<String, dynamic>?;

        if (currentRoutineData != null) {
          try {
            print(
                "TrackingTabScreen: Parsing currentRoutine pour _plannedEvents.");
            final routine = WeeklyRoutine.fromMap(currentRoutineData);
            _generatePlannedEventsForRoutine(routine);
          } catch (e, s) {
            print(
                "TrackingTabScreen: Error parsing currentRoutine from user document: $e\n$s");
            if (mounted) setState(() => _plannedEvents = {});
          }
        } else {
          print("TrackingTabScreen: No currentRoutine found in user doc.");
          if (mounted) setState(() => _plannedEvents = {});
        }
      } else {
        print("TrackingTabScreen: User doc does not exist or no data.");
        if (mounted) setState(() => _plannedEvents = {});
      }
    }, onError: (error, stackTrace) {
      print(
          "TrackingTabScreen: Error in userDocStream listener: $error\n$stackTrace");
      if (mounted) setState(() => _plannedEvents = {});
    });
  }

  void _generatePlannedEventsForRoutine(WeeklyRoutine routine) {
    final Map<DateTime, List<String>> newPlannedEvents = {};
    final Timestamp? createdAtTs = routine.generatedAt;
    if (createdAtTs == null || routine.durationInWeeks <= 0) {
      print(
          "TrackingTabScreen: No routine start date or duration for planned events.");
      if (mounted) setState(() => _plannedEvents = newPlannedEvents);
      return;
    }

    final DateTime routineStartDate = createdAtTs.toDate();
    final Timestamp? expiresAtTs = routine.expiresAt;
    final DateTime routineEndDate = expiresAtTs?.toDate() ??
        routineStartDate.add(Duration(days: (routine.durationInWeeks * 7) - 1));

    DateTime currentDate = DateTime(
        routineStartDate.year, routineStartDate.month, routineStartDate.day);
    int count = 0;

    if (routine.dailyWorkouts.isEmpty) {
      print("TrackingTabScreen: Routine has no dailyWorkouts defined.");
      if (mounted) setState(() => _plannedEvents = newPlannedEvents);
      return;
    }
    final List<String> dayKeys = WeeklyRoutine.daysOfWeek;

    while (!currentDate.isAfter(routineEndDate) &&
        count < (routine.durationInWeeks * 7 + 14)) {
      count++;
      final dayOfWeekIndex = currentDate.weekday - 1;

      if (dayOfWeekIndex >= 0 && dayOfWeekIndex < dayKeys.length) {
        final dayKey = dayKeys[dayOfWeekIndex];
        final List<RoutineExercise>? exercisesForDay =
            routine.dailyWorkouts[dayKey];
        if (exercisesForDay != null && exercisesForDay.isNotEmpty) {
          final dateOnly =
              DateTime(currentDate.year, currentDate.month, currentDate.day);
          newPlannedEvents[dateOnly] = ['Planned Workout'];
        }
      } else {
        print(
            "TrackingTabScreen: Invalid weekday index: $dayOfWeekIndex for date $currentDate");
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    print(
        "TrackingTabScreen: Generated ${newPlannedEvents.length} planned events.");
    if (mounted) setState(() => _plannedEvents = newPlannedEvents);
  }

  void _listenToWorkoutLogsAndUpdateCalendar(
      Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
    _workoutLogsSubscription?.cancel();
    _workoutLogsSubscription = stream.listen((logSnapshot) {
      print(
          "TrackingTabScreen (Listener): Workout logs snapshot received. Docs count: ${logSnapshot.docs.length}");
      if (!mounted) {
        print(
            "TrackingTabScreen (Listener): Widget not mounted. Skipping update.");
        return;
      }

      final Set<DateTime> newCompletedDates = {};
      // bool currentSelectedDayIsAmongCompletedInSnapshot = false; // Retiré, on se base sur newCompletedDates.contains

      for (var doc in logSnapshot.docs) {
        final data = doc.data();
        final Timestamp? timestamp =
            data[_dateFieldForWorkoutLog] as Timestamp?;
        if (timestamp != null) {
          final DateTime workoutDateTime = timestamp.toDate();
          final DateTime workoutDateOnly = DateTime(
              workoutDateTime.year, workoutDateTime.month, workoutDateTime.day);
          newCompletedDates.add(workoutDateOnly);
          // if (_selectedDay != null && isSameDay(workoutDateOnly, _selectedDay!)) {
          //   currentSelectedDayIsAmongCompletedInSnapshot = true;
          // }
        } else {
          print(
              "TrackingTabScreen (Listener): Log doc ${doc.id} missing '$_dateFieldForWorkoutLog' timestamp.");
        }
      }
      print(
          "TrackingTabScreen (Listener): newCompletedDates from logs: $newCompletedDates (total: ${newCompletedDates.length})");
      // print("TrackingTabScreen (Listener): For _selectedDay: $_selectedDay, currentSelectedDayIsAmongCompletedInSnapshot: $currentSelectedDayIsAmongCompletedInSnapshot");

      bool completedDatesCollectionHasChanged =
          _completedWorkoutDates.length != newCompletedDates.length ||
              !_completedWorkoutDates.containsAll(newCompletedDates) ||
              !newCompletedDates.containsAll(_completedWorkoutDates);

      if (mounted) {
        if (completedDatesCollectionHasChanged) {
          setState(() {
            _completedWorkoutDates = newCompletedDates;
            print(
                "TrackingTabScreen (Listener): setState for _completedWorkoutDates. New count: ${_completedWorkoutDates.length}");
          });
        } else {
          print(
              "TrackingTabScreen (Listener): _completedWorkoutDates collection has not changed for calendar markers.");
        }

        if (_selectedDay != null) {
          if (newCompletedDates.contains(_selectedDay!)) {
            // Le jour sélectionné EST (ou reste) complété. On recharge ses logs pour être sûr.
            print(
                "TrackingTabScreen (Listener): _selectedDay ${_selectedDay} IS in newCompletedDates. Forcing reload of its logs via _loadLogsForSelectedDay.");
            _loadLogsForSelectedDay(_selectedDay!);
          } else if (_selectedDayRawLogs.isNotEmpty) {
            // Le jour sélectionné N'EST PAS dans newCompletedDates (peut-être un log a été supprimé)
            // ET il affichait des logs, donc on les vide.
            print(
                "TrackingTabScreen (Listener): _selectedDay ${_selectedDay} NOT in newCompletedDates, but was showing logs. Clearing its displayed logs.");
            setState(() {
              _selectedDayRawLogs = [];
            });
          } else {
            print(
                "TrackingTabScreen (Listener): _selectedDay ${_selectedDay} details not affected by this specific log update or no logs to clear.");
          }
        }
      }
    }, onError: (error, stackTrace) {
      print(
          "TrackingTabScreen (Listener): Error in workoutLogsStream listener: $error\n$stackTrace");
      if (mounted) {
        setState(() {
          _completedWorkoutDates = {};
          _selectedDayRawLogs = [];
        });
      }
    });
  }

  Future<void> _loadLogsForSelectedDay(DateTime day) async {
    if (!mounted) return;
    final normalizedDay = DateTime(day.year, day.month, day.day);
    print(
        "TrackingTabScreen: _loadLogsForSelectedDay called for $normalizedDay");

    final startOfDay = Timestamp.fromDate(normalizedDay);
    final endOfDay =
        Timestamp.fromDate(normalizedDay.add(const Duration(days: 1)));

    try {
      final logSnapshot = await _firestore
          .collection('workout_logs')
          .where('userId', isEqualTo: widget.user.uid)
          .where(_dateFieldForWorkoutLog, isGreaterThanOrEqualTo: startOfDay)
          .where(_dateFieldForWorkoutLog, isLessThan: endOfDay)
          .orderBy(_dateFieldForWorkoutLog, descending: true)
          .get();

      if (!mounted) return;
      print(
          "TrackingTabScreen: Loaded ${logSnapshot.docs.length} logs for $normalizedDay from Firestore via _loadLogsForSelectedDay.");

      // Comparer avec les logs existants pour éviter un setState inutile si les données sont identiques
      // C'est une micro-optimisation, peut être omise si elle cause des problèmes.
      // Pour la simplicité et la robustesse, on peut toujours appeler setState.
      // bool logsChanged = _selectedDayRawLogs.length != logSnapshot.docs.length ||
      //                    !ListEquality().equals(_selectedDayRawLogs.map((e) => e['id']).toList(), logSnapshot.docs.map((e) => e.id).toList());

      // Toujours appeler setState pour garantir le rafraîchissement si _loadLogsForSelectedDay est appelé.
      setState(() {
        _selectedDayRawLogs = logSnapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'id': doc.id};
        }).toList();
        print(
            "TrackingTabScreen: setState after _loadLogsForSelectedDay. _selectedDayRawLogs has ${_selectedDayRawLogs.length} items.");
      });
    } catch (e, s) {
      print(
          "TrackingTabScreen: Error loading logs for selected day $normalizedDay: $e\n$s");
      if (mounted) setState(() => _selectedDayRawLogs = []);
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    List<String> events = [];
    if (_completedWorkoutDates.contains(dateOnly)) {
      events.add('Completed');
    } else if (_plannedEvents[dateOnly]?.isNotEmpty ?? false) {
      events.add('Planned');
    }
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    print(
        "TrackingTabScreen: _onDaySelected: selected $normalizedSelectedDay, current _selectedDay $_selectedDay");
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDay = normalizedSelectedDay;
          _focusedDay = focusedDay;
          _selectedDayRawLogs = [];
          print(
              "TrackingTabScreen: _onDaySelected - new day selected, _selectedDayRawLogs cleared.");
        });
        _loadLogsForSelectedDay(normalizedSelectedDay);
      }
    } else {
      print(
          "TrackingTabScreen: _onDaySelected - same day selected. Forcing reload of logs for this day.");
      _loadLogsForSelectedDay(normalizedSelectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    print(
        "TrackingTabScreen: Build method called. _selectedDay: $_selectedDay, _completedWorkoutDates count: ${_completedWorkoutDates.length}, _selectedDayRawLogs count: ${_selectedDayRawLogs.length}");

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              "Track Your Progress",
              style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          TableCalendar<String>(
            locale: 'en_US',
            firstDay: DateTime.utc(DateTime.now().year - 2, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 2, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
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
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                  color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
              todayDecoration: BoxDecoration(
                color:
                    colorScheme.primaryContainer.withAlpha((255 * 0.7).round()),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold),
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                  color: colorScheme.onSurface.withAlpha((255 * 0.7).round())),
              defaultTextStyle: TextStyle(color: colorScheme.onSurface),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: textTheme.titleMedium ??
                  const TextStyle(fontWeight: FontWeight.bold),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: colorScheme.primary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: colorScheme.primary),
            ),
            onPageChanged: (focusedDay) {
              if (mounted) {
                setState(() => _focusedDay = focusedDay);
              }
            },
          ),
          Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withAlpha((255 * 0.5).round())),
          Expanded(
            child: _buildSelectedDayInfo(context, textTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(List<String> events, ColorScheme colorScheme) {
    bool isCompleted = events.contains('Completed');
    bool isPlanned = events.contains('Planned');
    Color markerColor;
    if (isCompleted) {
      markerColor = Colors.green.shade600;
    } else if (isPlanned) {
      markerColor = colorScheme.secondary;
    } else {
      return const SizedBox.shrink();
    }
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: markerColor),
    );
  }

  String _formatDurationFromSeconds(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "${twoDigits(hours)}h ${minutes}m ${seconds}s";
    }
    return "${minutes}m ${seconds}s";
  }

  Widget _buildSelectedDayInfo(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_selectedDay == null) {
      return Center(
          child:
              Text("Select a day to see details.", style: textTheme.bodyLarge));
    }
    print(
        "TrackingTabScreen _buildSelectedDayInfo: Building for _selectedDay: $_selectedDay");

    final normalizedSelectedDay =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final bool isWorkoutCompletedToday =
        _completedWorkoutDates.contains(normalizedSelectedDay);
    final bool isWorkoutPlannedToday =
        _plannedEvents[normalizedSelectedDay]?.isNotEmpty ?? false;

    print(
        "TrackingTabScreen _buildSelectedDayInfo: isWorkoutCompletedToday: $isWorkoutCompletedToday, isWorkoutPlannedToday: $isWorkoutPlannedToday");
    print(
        "TrackingTabScreen _buildSelectedDayInfo: _selectedDayRawLogs count for display: ${_selectedDayRawLogs.length}");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMd('en_US').format(_selectedDay!),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (isWorkoutCompletedToday) ...[
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green.shade700, size: 26),
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
                      child: Column(
                      // Pour centrer le texte et l'indicateur
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Loading workout details...", // Changé de "not found" à "loading"
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        const CircularProgressIndicator(), // Ajout d'un loader
                      ],
                    ))
                  : ListView.builder(
                      itemCount: _selectedDayRawLogs.length,
                      itemBuilder: (context, index) {
                        final log = _selectedDayRawLogs[index];
                        final workoutName =
                            log['workoutName'] as String? ?? "Unnamed Workout";
                        final durationSeconds =
                            log['durationSeconds'] as int? ?? 0;
                        final exercisesLogged =
                            log['exercises'] as List<dynamic>? ?? [];
                        final Timestamp workoutDateTimestamp =
                            log[_dateFieldForWorkoutLog] as Timestamp? ??
                                Timestamp.now();
                        final String workoutTime = DateFormat.jm()
                            .format(workoutDateTimestamp.toDate());

                        final exercisesWithLoggedSets =
                            exercisesLogged.where((ex) {
                          final exData = ex as Map<String, dynamic>?;
                          final List<dynamic>? loggedSets =
                              exData?['loggedSets'] as List<dynamic>?;
                          return loggedSets != null && loggedSets.isNotEmpty;
                        }).toList();

                        return Card(
                          elevation: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            leading: Icon(Icons.assessment_outlined,
                                color: colorScheme.primary, size: 26),
                            title: Text("$workoutName ($workoutTime)",
                                style: textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                "Duration: ${_formatDurationFromSeconds(durationSeconds)}\n"
                                "${exercisesWithLoggedSets.length} exercises with logged sets",
                                style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            childrenPadding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 12, top: 0),
                            iconColor: colorScheme.primary,
                            collapsedIconColor: colorScheme.onSurfaceVariant,
                            children:
                                exercisesWithLoggedSets.map<Widget>((exMap) {
                              final exData = exMap as Map<String, dynamic>;
                              final String exName =
                                  exData['exerciseName'] as String? ??
                                      'Unknown Exercise';
                              final List<dynamic> loggedSetsDynamic =
                                  exData['loggedSets'] as List<dynamic>? ?? [];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(exName,
                                        style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                    ...loggedSetsDynamic.map((setMap) {
                                      final setData =
                                          setMap as Map<String, dynamic>;
                                      final setNum =
                                          setData['setNumber'] as int?;
                                      final reps =
                                          setData['performedReps'] as String?;
                                      final weight =
                                          setData['performedWeightKg']
                                              as String?;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, top: 3.0),
                                        child: Text(
                                          "Set ${setNum ?? '-'}: ${reps ?? '-'} reps @ ${weight ?? '-'}kg",
                                          style: textTheme.bodySmall?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant),
                                        ),
                                      );
                                    }).toList(),
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
            Row(
              children: [
                Icon(Icons.event_available_outlined,
                    color: colorScheme.secondary, size: 26),
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
            Row(
              children: [
                Icon(Icons.bed_outlined,
                    color: colorScheme.onSurfaceVariant
                        .withAlpha((255 * 0.7).round()),
                    size: 26),
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
