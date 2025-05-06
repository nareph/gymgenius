// lib/screens/tabs/tracking_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart'; // Pour accéder à RoutineExercise et WeeklyRoutine
import 'package:intl/intl.dart'; // Pour formater les clés de jour
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
  Map<DateTime, List<dynamic>> _events =
      {}; // Pour stocker les marqueurs d'événements

  // Stream pour écouter les changements de la routine
  Stream<DocumentSnapshot>? _routineStream;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = DateTime(
        now.year, now.month, now.day); // Sélectionne aujourd'hui sans l'heure
    _routineStream =
        _firestore.collection('routines').doc(widget.user.uid).snapshots();
    _loadRoutineEvents(); // Charge les événements initiaux
  }

  void _loadRoutineEvents() {
    _routineStream?.listen((routineSnapshot) {
      if (routineSnapshot.exists && routineSnapshot.data() != null) {
        try {
          final routine = WeeklyRoutine.fromFirestore(routineSnapshot);
          _generateEventsForRoutine(routine);
        } catch (e) {
          print("Error parsing routine for calendar events: $e");
          if (mounted) {
            setState(() {
              _events = {};
            });
          }
        }
      } else {
        // Aucune routine trouvée, effacer les événements
        if (mounted) {
          setState(() {
            _events = {};
          });
        }
      }
    });
  }

  // Génère les marqueurs d'événements pour la durée de la routine
  void _generateEventsForRoutine(WeeklyRoutine routine) {
    final Map<DateTime, List<dynamic>> newEvents = {};
    if (routine.createdAt == null || routine.durationInWeeks <= 0) {
      if (mounted) setState(() => _events = newEvents);
      return;
    }

    final DateTime startDate = routine.createdAt!.toDate();
    final DateTime endDate =
        startDate.add(Duration(days: routine.durationInWeeks * 7));

    // Parcourt chaque jour de la start date à la end date
    DateTime currentDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final dayOfWeekName =
          DateFormat('EEEE').format(currentDate).toLowerCase(); // Ex: "monday"
      final exercisesForDay = routine.dailyWorkouts[dayOfWeekName];

      if (exercisesForDay != null && exercisesForDay.isNotEmpty) {
        final dateOnly =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        newEvents[dateOnly] = [
          'Workout'
        ]; // Ajoute un simple marqueur 'Workout'
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    if (mounted) {
      setState(() {
        _events = newEvents;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        // Enlève l'heure de la sélection pour éviter les problèmes de comparaison
        _selectedDay =
            DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Utilise un Scaffold pour potentiellement ajouter un FAB plus tard
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Track Your Progress",
              style:
                  textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ),
          TableCalendar(
            locale:
                'en_US', // Ou 'fr_FR', etc. si vous avez configuré la localisation
            firstDay: DateTime.utc(2020, 1, 1), // Date lointaine dans le passé
            lastDay: DateTime.utc(2035, 12, 31), // Date lointaine dans le futur
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader:
                _getEventsForDay, // Fonction pour charger les marqueurs
            calendarFormat: CalendarFormat.month, // Affiche un mois complet
            startingDayOfWeek:
                StartingDayOfWeek.monday, // Commence la semaine le Lundi
            calendarStyle: CalendarStyle(
              // Style des marqueurs d'événements
              markerDecoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              // Style du jour sélectionné
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              // Style du jour "aujourd'hui"
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible:
                  false, // Cache les jours du mois précédent/suivant
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // Cache le bouton "2 weeks", "Month"
              titleCentered: true,
              titleTextStyle: textTheme.titleLarge ?? const TextStyle(),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: colorScheme.primary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: colorScheme.primary),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay =
                  focusedDay; // Met à jour le focus quand l'utilisateur change de mois
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildSelectedDayInfo(context, textTheme, colorScheme),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher des infos sur le jour sélectionné
  Widget _buildSelectedDayInfo(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    if (_selectedDay == null) {
      return const Center(child: Text("Select a day"));
    }
    final eventsToday = _getEventsForDay(_selectedDay!);
    final bool isWorkoutDay = eventsToday.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMd().format(_selectedDay!), // Ex: July 11, 2023
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (isWorkoutDay) ...[
            Row(
              children: [
                Icon(Icons.fitness_center, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text("Workout planned", style: textTheme.titleMedium),
              ],
            ),
            // TODO: Afficher la liste des exercices prévus pour ce jour
            // TODO: Ajouter un bouton "Mark as Completed"
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Mark Session Completed"),
                  onPressed: () {
                    // TODO: Implémenter la logique de sauvegarde de la session complétée
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Completion tracking coming soon!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.bedtime_outlined,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
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
