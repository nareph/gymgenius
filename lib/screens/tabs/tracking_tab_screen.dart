// lib/screens/tabs/tracking_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // Pour WeeklyRoutine et RoutineExercise
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TrackingTabScreen extends StatefulWidget {
  final User user;
  const TrackingTabScreen({super.key, required this.user});

  @override
  State<TrackingTabScreen> createState() => _TrackingTabScreenState();
}

class _TrackingTabScreenState extends State<TrackingTabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  Map<DateTime, List<String>> _plannedEvents = {};
  // Stream pour écouter le document utilisateur qui contient la routine actuelle
  Stream<DocumentSnapshot<Map<String, dynamic>>>?
      _userDocStreamForPlannedRoutine;

  Set<DateTime> _completedWorkoutDates = {};
  Stream<QuerySnapshot<Map<String, dynamic>>>?
      _workoutLogsStream; // Typé pour QuerySnapshot
  List<Map<String, dynamic>> _selectedDayRawLogs = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = DateTime(now.year, now.month, now.day); // Normalisé

    _userDocStreamForPlannedRoutine = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .cast<DocumentSnapshot<Map<String, dynamic>>>(); // Assurer le type

    _workoutLogsStream = _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: widget.user.uid)
        .orderBy('workoutDate', descending: true)
        .snapshots()
        .cast<QuerySnapshot<Map<String, dynamic>>>(); // Assurer le type

    _loadPlannedRoutineEvents();
    _listenToWorkoutLogsAndUpdateCalendar();
    if (_selectedDay != null) {
      _loadLogsForSelectedDay(_selectedDay!);
    }
  }

  void _loadPlannedRoutineEvents() {
    _userDocStreamForPlannedRoutine?.listen((userDocSnapshot) {
      if (!mounted) return;
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
                "TTS: Error parsing currentRoutine from user document: $e\n$s");
            if (mounted) {
              setState(() => _plannedEvents = {});
            }
          }
        } else {
          if (mounted) {
            setState(() => _plannedEvents = {});
          }
        }
      } else {
        if (mounted) {
          setState(() => _plannedEvents = {});
        }
      }
    });
  }

  void _generatePlannedEventsForRoutine(WeeklyRoutine routine) {
    final Map<DateTime, List<String>> newPlannedEvents = {};
    final Timestamp? createdAtTs = routine.generatedAt;
    if (createdAtTs == null || routine.durationInWeeks <= 0) {
      if (mounted) setState(() => _plannedEvents = newPlannedEvents);
      return;
    }

    final DateTime routineStartDate = createdAtTs.toDate();
    final Timestamp? expiresAtTs = routine.expiresAt;
    final DateTime routineEndDate = expiresAtTs?.toDate() ??
        routineStartDate.add(Duration(days: (routine.durationInWeeks * 7) - 1));

    DateTime currentDate = DateTime(
        routineStartDate.year, routineStartDate.month, routineStartDate.day);
    while (!currentDate.isAfter(routineEndDate)) {
      final dayOfWeekName =
          DateFormat('EEEE').format(currentDate).toLowerCase();
      final List<RoutineExercise>? exercisesForDay =
          routine.dailyWorkouts[dayOfWeekName];

      if (exercisesForDay != null && exercisesForDay.isNotEmpty) {
        final dateOnly =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        newPlannedEvents[dateOnly] = ['Planned Workout'];
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    if (mounted) {
      setState(() => _plannedEvents = newPlannedEvents);
    }
  }

  void _listenToWorkoutLogsAndUpdateCalendar() {
    _workoutLogsStream?.listen((logSnapshot) {
      if (!mounted) return;
      final Set<DateTime> newCompletedDates = {};
      List<Map<String, dynamic>> currentSelectedDayLogsIfUpdated = [];

      for (var doc in logSnapshot.docs) {
        // doc est QueryDocumentSnapshot<Map<String, dynamic>>
        final data = doc.data(); // data est Map<String, dynamic>
        final Timestamp? timestamp = data['workoutDate'] as Timestamp?;
        if (timestamp != null) {
          final DateTime workoutDateTime = timestamp.toDate();
          final DateTime workoutDateOnly = DateTime(
              workoutDateTime.year, workoutDateTime.month, workoutDateTime.day);
          newCompletedDates.add(workoutDateOnly);

          if (_selectedDay != null &&
              isSameDay(workoutDateOnly, _selectedDay!)) {
            currentSelectedDayLogsIfUpdated
                .add({...data, 'id': doc.id}); // Clone et ajoute l'id
          }
        }
      }

      if (mounted) {
        setState(() {
          _completedWorkoutDates = newCompletedDates;
          if (_selectedDay != null &&
              newCompletedDates.contains(_selectedDay!)) {
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
            _selectedDayRawLogs = [];
          }
        });
      }
    });
  }

  Future<void> _loadLogsForSelectedDay(DateTime day) async {
    if (!mounted) return;
    final normalizedDay = DateTime(day.year, day.month, day.day);

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
          .get(); // logSnapshot est QuerySnapshot<Map<String, dynamic>>

      if (!mounted) return;

      setState(() {
        _selectedDayRawLogs = logSnapshot.docs.map((doc) {
          // doc est QueryDocumentSnapshot<Map<String, dynamic>>
          final data = doc.data(); // data est Map<String, dynamic>
          return {...data, 'id': doc.id}; // Clone et ajoute l'id
        }).toList();
      });
    } catch (e, s) {
      print("TTS: Error loading logs for selected day $normalizedDay: $e\n$s");
      if (mounted) {
        setState(() => _selectedDayRawLogs = []);
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    List<dynamic> events = [];
    if (_completedWorkoutDates.contains(dateOnly)) {
      events.add('Completed');
    } else if (_plannedEvents[dateOnly]?.isNotEmpty ?? false) {
      // Vérification null-safe
      events.add('Planned');
    }
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDay = normalizedSelectedDay;
          _focusedDay = focusedDay;
          _selectedDayRawLogs = [];
        });
        _loadLogsForSelectedDay(normalizedSelectedDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "Track Your Progress",
              style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          TableCalendar(
            locale: 'en_US',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
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
                    right: 1,
                    bottom: 1,
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
                color: colorScheme.primaryContainer.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: textTheme.titleLarge ?? const TextStyle(),
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
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: _buildSelectedDayInfo(context, textTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(List<dynamic> events, ColorScheme colorScheme) {
    bool isCompleted = events.contains('Completed');
    bool isPlanned = events.contains('Planned');

    if (isCompleted) {
      return Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
      );
    } else if (isPlanned) {
      return Container(
        width: 8,
        height: 8,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: colorScheme.secondary),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatDurationFromSeconds(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "${twoDigits(hours)}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  Widget _buildSelectedDayInfo(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_selectedDay == null) {
      return const Center(child: Text("Select a day to see details."));
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
            DateFormat.yMMMMd('en_US').format(_selectedDay!),
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (isWorkoutCompletedToday) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text("Workout Completed!",
                    style: textTheme.titleMedium?.copyWith(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _selectedDayRawLogs.isEmpty
                  ? Center(
                      child: Text("Loading workout details...",
                          style: textTheme.bodyMedium))
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
                        final String workoutTime = DateFormat.jm()
                            .format(workoutDateTimestamp.toDate());

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            leading: Icon(Icons.fitness_center,
                                color: colorScheme.primary),
                            title: Text("$workoutName ($workoutTime)",
                                style: textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                "Duration: ${_formatDurationFromSeconds(durationSeconds)}\n${exercisesLogged.where((ex) => (ex['loggedSets'] as List<dynamic>?)?.isNotEmpty ?? false).length} exercises with logged sets"),
                            childrenPadding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 8),
                            children: exercisesLogged
                                .map<Widget>((exMap) {
                                  final exData = exMap as Map<String, dynamic>;
                                  final String exName =
                                      exData['exerciseName'] as String? ??
                                          'N/A';
                                  final List<dynamic> loggedSetsDynamic =
                                      exData['loggedSets'] as List<dynamic>? ??
                                          [];

                                  if (loggedSetsDynamic.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
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
                                          final Timestamp setLoggedAtTs =
                                              setData['loggedAt']
                                                      as Timestamp? ??
                                                  Timestamp.now();
                                          final String setTime = DateFormat.jm()
                                              .format(setLoggedAtTs.toDate());

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, top: 2.0),
                                            child: Text(
                                              "Set ${setNum ?? '-'}: ${reps ?? '-'} reps @ ${weight ?? '-'}kg ($setTime)",
                                              style: textTheme.bodySmall,
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  );
                                })
                                .where((widget) => widget is! SizedBox)
                                .toList(),
                          ),
                        );
                      },
                    ),
            ),
          ] else if (isWorkoutPlannedToday) ...[
            Row(
              children: [
                Icon(Icons.event_note, color: colorScheme.secondary, size: 28),
                const SizedBox(width: 8),
                Text("Workout Planned", style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text("Check your routine for details.",
                style: textTheme.bodyMedium),
          ] else ...[
            Row(
              children: [
                Icon(Icons.bedtime_outlined,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    size: 28),
                const SizedBox(width: 8),
                Text("Rest Day", style: textTheme.titleMedium),
              ],
            )
          ]
        ],
      ),
    );
  }
}
