// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/data/static_routine.dart';
import 'package:gymgenius/models/routine.dart';
// Importez le nouvel écran
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

  String _getWeeksRemainingText(WeeklyRoutine? routine) {
    if (routine == null ||
        routine.createdAt == null ||
        routine.durationInWeeks <= 0) {
      return "Duration not set";
    }
    final DateTime creationDate = routine.createdAt!.toDate();
    final DateTime endDate =
        creationDate.add(Duration(days: routine.durationInWeeks * 7));
    final Duration difference = endDate.difference(DateTime.now());

    if (difference.isNegative) {
      return "Plan finished";
    }
    int weeksRemaining = (difference.inDays / 7).ceil();
    if (weeksRemaining > routine.durationInWeeks)
      weeksRemaining = routine.durationInWeeks;
    if (weeksRemaining < 0) weeksRemaining = 0;

    return "$weeksRemaining week${weeksRemaining == 1 ? '' : 's'} remaining";
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
                  bool isRoutineExpired = false;
                  String weeksRemainingText = "N/A";

                  if (snapshot.data != null && snapshot.data!.exists) {
                    noRoutineExists = false;
                    try {
                      routine = WeeklyRoutine.fromFirestore(snapshot.data!);
                      weeksRemainingText = _getWeeksRemainingText(routine);
                      if (routine.createdAt != null &&
                          routine.durationInWeeks > 0) {
                        final DateTime creationDate =
                            routine.createdAt!.toDate();
                        final DateTime endDate = creationDate
                            .add(Duration(days: routine.durationInWeeks * 7));
                        if (DateTime.now().isAfter(endDate)) {
                          isRoutineExpired = true;
                          weeksRemainingText = "Plan finished";
                        }
                      }
                    } catch (e) {
                      print(
                          "Error parsing routine data: ${snapshot.data!.data()} -> $e");
                      noRoutineExists = true;
                      routine = null;
                    }
                  }

                  if (noRoutineExists || isRoutineExpired) {
                    return Column(
                      children: [
                        if (isRoutineExpired && routine != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Previous Plan: ${routine.name} (Finished)",
                              style: textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Expanded(
                          child: Card(
                              color: colorScheme.surface.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        isRoutineExpired
                                            ? Icons.autorenew
                                            : Icons.sentiment_dissatisfied,
                                        color: colorScheme.secondary,
                                        size: 40),
                                    const SizedBox(height: 10),
                                    Text(
                                        isRoutineExpired
                                            ? "Routine Expired"
                                            : "No Active Routine",
                                        style: textTheme.titleLarge),
                                    const SizedBox(height: 5),
                                    Text(
                                      isRoutineExpired
                                          ? "Your previous plan has finished. Time for a new one!"
                                          : "Let's generate your personalized AI fitness plan!",
                                      style: textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _isGeneratingRoutine
                                          ? null
                                          : _generateRoutine,
                                      child: _isGeneratingRoutine
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
                                              ),
                                            )
                                          : Text(isRoutineExpired
                                              ? "Generate New Plan"
                                              : "Generate First Plan"),
                                    )
                                  ],
                                ),
                              )),
                        ),
                      ],
                    );
                  } else if (routine != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                label: Text(weeksRemainingText,
                                    style: textTheme.labelMedium?.copyWith(
                                        color:
                                            colorScheme.onSecondaryContainer)),
                                backgroundColor: colorScheme.secondaryContainer,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
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
                                          // NAVIGATE HERE
                                          if (dayExercises != null &&
                                              dayExercises.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DailyWorkoutDetailScreen(
                                                  dayTitle:
                                                      "$dayTitle Workout", // Ex: "Monday Workout"
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
