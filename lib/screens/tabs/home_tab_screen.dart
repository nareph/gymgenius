// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/data/static_routine.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/screens/daily_workout_detail_screen.dart';

class HomeTabScreen extends StatefulWidget {
  final User user;
  const HomeTabScreen({super.key, required this.user});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  bool _isGeneratingRoutine = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<WeeklyRoutine> _callAiRoutineService(
      String userId, Map<String, dynamic> onboardingData) async {
    print(
        "Simulating AI routine generation with static data for user: $userId");
    await Future.delayed(const Duration(seconds: 2));
    return createStaticWeeklyRoutine(userId);
  }

  Future<void> _generateRoutine() async {
    if (_isGeneratingRoutine) return;
    setState(() => _isGeneratingRoutine = true);

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.user.uid).get();
      Map<String, dynamic> onboardingData =
          userDoc.exists && userDoc.data() != null
              ? userDoc.data() as Map<String, dynamic>
              : {};

      final WeeklyRoutine newRoutine =
          await _callAiRoutineService(widget.user.uid, onboardingData);

      await _firestore.collection('routines').doc(widget.user.uid).set({
        ...newRoutine.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccessSnackBar("New routine generated successfully!");
        setState(() {});
      }
    } catch (e) {
      print("Error generating routine: $e");
      if (mounted) _showErrorSnackBar("Failed to generate routine. Error: $e");
    } finally {
      if (mounted) setState(() => _isGeneratingRoutine = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final snackBar = SnackBar(
      content: Text(message,
          style: TextStyle(color: Theme.of(context).colorScheme.onError)),
      backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    final snackBar = SnackBar(
      content: Text(message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer)),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Renvoie un tuple: (texte des semaines restantes, booléen si expiré)
  (String, bool) _getRoutineStatus(WeeklyRoutine? routine) {
    if (routine == null ||
        routine.createdAt == null ||
        routine.durationInWeeks <= 0) {
      return (
        "Duration not set",
        false
      ); // Non expiré par défaut si pas de données
    }
    final DateTime creationDate = routine.createdAt!.toDate();
    final DateTime endDate =
        creationDate.add(Duration(days: routine.durationInWeeks * 7));

    if (DateTime.now().isAfter(endDate)) {
      return ("Plan finished", true); // Expiré
    }

    final Duration difference = endDate.difference(DateTime.now());
    int weeksRemaining = (difference.inDays / 7).ceil();
    // Assurer que les semaines restantes ne dépassent pas la durée totale ou ne soient négatives
    if (weeksRemaining > routine.durationInWeeks)
      weeksRemaining = routine.durationInWeeks;
    if (weeksRemaining < 0) weeksRemaining = 0;

    return (
      "$weeksRemaining week${weeksRemaining == 1 ? '' : 's'} remaining",
      false
    ); // Non expiré
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Welcome, ${widget.user.email?.split('@')[0] ?? 'Fitness Enthusiast'}!",
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          if (_isGeneratingRoutine)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
              child: Center(
                  child: Text("Generating Your Plan...",
                      style: textTheme.titleMedium)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
              child: Center(
                  child: Text("Current Plan",
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold))),
            ),
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future:
                  _firestore.collection('routines').doc(widget.user.uid).get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isGeneratingRoutine) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: colorScheme.secondary));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error loading routine. Please try again.",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.error)));
                } else if (snapshot.hasData || _isGeneratingRoutine) {
                  if (_isGeneratingRoutine &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: Text("Just a moment...",
                            style: textTheme.titleMedium));
                  }

                  WeeklyRoutine? routine;
                  bool noRoutineExists = true;
                  bool isRoutineExpired = false; // Initialisation
                  String routineStatusText = "N/A";

                  if (snapshot.data != null && snapshot.data!.exists) {
                    noRoutineExists = false;
                    try {
                      routine = WeeklyRoutine.fromFirestore(snapshot.data!);
                      final status = _getRoutineStatus(
                          routine); // Utilise la nouvelle fonction
                      routineStatusText = status.$1;
                      isRoutineExpired = status.$2;
                    } catch (e) {
                      print(
                          "Error parsing routine data: ${snapshot.data!.data()} -> $e");
                      noRoutineExists = true;
                      routine = null;
                    }
                  }

                  // --- AFFICHAGE BASÉ SUR L'ÉTAT DE LA ROUTINE ---
                  if (noRoutineExists || isRoutineExpired) {
                    String title = isRoutineExpired
                        ? "Routine Expired"
                        : "No Active Routine";
                    String message = isRoutineExpired
                        ? "Your previous plan has finished after ${routine?.durationInWeeks ?? 0} weeks. Time for a new one!" // Affiche la durée si routine n'est pas null
                        : "Let's generate your personalized AI fitness plan!";
                    String buttonText = isRoutineExpired
                        ? "Generate New Plan"
                        : "Generate First Plan";
                    IconData iconData = isRoutineExpired
                        ? Icons.autorenew
                        : Icons.sentiment_dissatisfied;

                    return Column(
                      children: [
                        if (isRoutineExpired && routine != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Previous Plan: ${routine.name}",
                              style: textTheme.titleMedium?.copyWith(
                                  color: textTheme.bodySmall?.color
                                      ?.withOpacity(0.7)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Expanded(
                          child: Card(
                              elevation: isRoutineExpired
                                  ? 4
                                  : 2, // Plus d'emphase si expirée
                              color: isRoutineExpired
                                  ? colorScheme.errorContainer.withOpacity(
                                      0.3) // Couleur d'avertissement léger
                                  : colorScheme.surface.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: isRoutineExpired
                                    ? BorderSide(
                                        color: colorScheme.error, width: 1.5)
                                    : BorderSide.none,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(iconData,
                                        color: isRoutineExpired
                                            ? colorScheme.error
                                            : colorScheme.secondary,
                                        size: 40),
                                    const SizedBox(height: 10),
                                    Text(title,
                                        style: textTheme.titleLarge?.copyWith(
                                          color: isRoutineExpired
                                              ? colorScheme.onErrorContainer
                                              : null,
                                        )),
                                    const SizedBox(height: 5),
                                    Text(
                                      message,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: isRoutineExpired
                                            ? colorScheme.onErrorContainer
                                                .withOpacity(0.9)
                                            : null,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      icon: Icon(_isGeneratingRoutine
                                          ? Icons.hourglass_empty
                                          : (isRoutineExpired
                                              ? Icons.add_circle_outline
                                              : Icons.auto_awesome)),
                                      label: _isGeneratingRoutine
                                          ? const SizedBox(
                                              // Utilise le label pour l'indicateur pour garder la taille du bouton
                                              height: 20,
                                              width:
                                                  90, // Approx. la largeur du texte
                                              child: Center(
                                                  child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors
                                                                  .white))))
                                          : Text(buttonText),
                                      onPressed: _isGeneratingRoutine
                                          ? null
                                          : _generateRoutine,
                                      style: isRoutineExpired
                                          ? ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.error,
                                              foregroundColor:
                                                  colorScheme.onError,
                                            )
                                          : null, // Style par défaut sinon
                                    )
                                  ],
                                ),
                              )),
                        ),
                      ],
                    );
                  }
                  // Routine existe et n'est pas expirée
                  else if (routine != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  routine.name,
                                  style: textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                avatar: Icon(Icons.timer_sand_empty,
                                    size: 16,
                                    color: colorScheme.onSecondaryContainer
                                        .withOpacity(0.8)),
                                label: Text(routineStatusText,
                                    style: textTheme.labelMedium?.copyWith(
                                        color:
                                            colorScheme.onSecondaryContainer)),
                                backgroundColor: colorScheme.secondaryContainer,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4), // Un peu plus de padding
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: WeeklyRoutine.daysOfWeek.length,
                            itemBuilder: (context, index) {
                              final day = WeeklyRoutine.daysOfWeek[index];
                              final List<RoutineExercise>? dayExercises =
                                  routine!.dailyWorkouts[day];
                              final isRestDay =
                                  dayExercises == null || dayExercises.isEmpty;
                              final dayTitle =
                                  day[0].toUpperCase() + day.substring(1);

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(isRestDay ? 0.7 : 1.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  leading: Icon(
                                    isRestDay
                                        ? Icons.bedtime_outlined
                                        : Icons.fitness_center,
                                    color: isRestDay
                                        ? colorScheme.onSurfaceVariant
                                            .withOpacity(0.6)
                                        : colorScheme.secondary,
                                    size: 28,
                                  ),
                                  title: Text(dayTitle,
                                      style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    isRestDay
                                        ? "Rest Day"
                                        : "${dayExercises!.length} ${dayExercises.length == 1 ? 'exercise' : 'exercises'}",
                                    style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.8)),
                                  ),
                                  trailing: isRestDay
                                      ? null
                                      : Icon(Icons.arrow_forward_ios,
                                          size: 16,
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.6)),
                                  onTap: isRestDay
                                      ? null
                                      : () {
                                          if (dayExercises != null &&
                                              dayExercises.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DailyWorkoutDetailScreen(
                                                  dayTitle: "$dayTitle Workout",
                                                  exercises: dayExercises,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                        child: Text("Routine data is unavailable.",
                            style: textTheme.bodyMedium));
                  }
                } else {
                  return Center(
                      child: Text("No routine data found.",
                          style: textTheme.bodyMedium));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
