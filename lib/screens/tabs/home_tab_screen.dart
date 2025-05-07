// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/data/static_routine.dart'; // Votre service AI simulé
import 'package:gymgenius/models/routine.dart'; // WeeklyRoutine et RoutineExercise
import 'package:gymgenius/screens/daily_workout_detail_screen.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

// Définir la constante ici ou l'importer d'un fichier de constantes partagé
const int kProfileTabIndex = 2; // Supposant Home(0), Tracking(1), Profile(2)
// AJUSTEZ CET INDEX SI VOTRE ORDRE D'ONGLETS EST DIFFÉRENT

class HomeTabScreen extends StatefulWidget {
  final User user;
  final Function(int) onNavigateToTab;

  const HomeTabScreen({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  bool _isGeneratingRoutine = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userDocStream;

  @override
  void initState() {
    super.initState();
    _userDocStream = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .cast<DocumentSnapshot<Map<String, dynamic>>>();
  }

  Future<Map<String, dynamic>> _callAiRoutineService({
    required String userId,
    required Map<String, dynamic> onboardingData,
    Map<String, dynamic>? previousRoutineData,
  }) async {
    print("HTS: Simulating AI routine generation for user: $userId");
    if (previousRoutineData != null) {
      print(
          "HTS: Using previous routine context: Name: ${previousRoutineData['name']}, ID: ${previousRoutineData['id']}");
    }
    await Future.delayed(const Duration(seconds: 2));
    return createStaticAiGeneratedParts(
        userId: userId,
        onboardingData: onboardingData,
        previousRoutineData: previousRoutineData);
  }

  Future<void> _generateRoutine() async {
    if (_isGeneratingRoutine) return;
    setState(() => _isGeneratingRoutine = true);

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(widget.user.uid).get();

      Map<String, dynamic> onboardingData = {};
      Map<String, dynamic>? oldRoutineData;

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        onboardingData =
            (data['onboardingData'] as Map<String, dynamic>?) ?? {};
        oldRoutineData = (data['currentRoutine'] as Map<String, dynamic>?);
      }

      if (onboardingData.isEmpty) {
        _showErrorSnackBar(
            "Please complete your preferences in your profile before generating a plan.");
        widget.onNavigateToTab(kProfileTabIndex);
        if (mounted) setState(() => _isGeneratingRoutine = false);
        return;
      }

      final Map<String, dynamic> aiGeneratedParts = await _callAiRoutineService(
        userId: widget.user.uid,
        onboardingData: onboardingData,
        previousRoutineData: oldRoutineData,
      );

      final String newRoutineId = uuid.v4();
      final DateTime now = DateTime.now();
      final int durationInWeeks =
          aiGeneratedParts['durationInWeeks'] as int? ?? 4;
      final DateTime expiresAt = now.add(Duration(days: durationInWeeks * 7));

      final Map<String, dynamic> newCurrentRoutine = {
        'id': newRoutineId,
        'name': aiGeneratedParts['name'] as String? ?? 'AI Generated Routine',
        'dailyWorkouts': aiGeneratedParts['dailyWorkouts'] ?? {},
        'durationInWeeks': durationInWeeks,
        'generatedAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'onboardingSnapshot': onboardingData,
      };

      await _firestore.collection('users').doc(widget.user.uid).set(
        {'currentRoutine': newCurrentRoutine},
        SetOptions(merge: true),
      );

      if (mounted) {
        _showSuccessSnackBar("New routine generated successfully!");
      }
    } catch (e, s) {
      print("HTS: Error generating routine: $e\n$s");
      if (mounted)
        _showErrorSnackBar("Failed to generate routine. Please check logs.");
    } finally {
      if (mounted) setState(() => _isGeneratingRoutine = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: TextStyle(color: Theme.of(context).colorScheme.onError)),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 4),
    ));
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer)),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      duration: const Duration(seconds: 3),
    ));
  }

  ({String statusText, bool isExpired, bool isValid}) _getRoutineStatus(
      Map<String, dynamic>? routineData) {
    if (routineData == null || routineData.isEmpty) {
      return (statusText: "No Active Plan", isExpired: true, isValid: false);
    }

    final Timestamp? generatedAtTs = routineData['generatedAt'] as Timestamp?;
    final Timestamp? expiresAtTs = routineData['expiresAt'] as Timestamp?;
    final int durationInWeeks = routineData['durationInWeeks'] as int? ?? 0;
    final String routineName = routineData['name'] as String? ?? '';

    if (generatedAtTs == null ||
        expiresAtTs == null ||
        durationInWeeks <= 0 ||
        routineName.isEmpty) {
      return (statusText: "Invalid Plan Data", isExpired: true, isValid: false);
    }

    final DateTime expiresAtDate = expiresAtTs.toDate();

    if (DateTime.now().isAfter(expiresAtDate)) {
      return (statusText: "Plan Finished", isExpired: true, isValid: true);
    }

    final Duration difference = expiresAtDate.difference(DateTime.now());
    int weeksRemaining = (difference.inDays / 7).ceil();
    if (weeksRemaining < 0) weeksRemaining = 0;
    if (weeksRemaining > durationInWeeks) weeksRemaining = durationInWeeks;

    return (
      statusText:
          "$weeksRemaining week${weeksRemaining == 1 ? '' : 's'} remaining",
      isExpired: false,
      isValid: true
    );
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
            padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
            child: Center(
                child: Text(
              _isGeneratingRoutine ? "Generating Your Plan..." : "Current Plan",
              style: _isGeneratingRoutine
                  ? textTheme.titleMedium
                  : textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            )),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userDocStream,
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !_isGeneratingRoutine) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: colorScheme.secondary));
                }
                if (snapshot.hasError) {
                  print(
                      "HTS: Error in UserDoc StreamBuilder: ${snapshot.error}");
                  return Center(
                      child: Text("Error loading user data.",
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.error)));
                }

                final Map<String, dynamic>? userData = snapshot.data?.data();

                if (!snapshot.hasData ||
                    !snapshot.data!.exists ||
                    userData == null) {
                  return _buildOnboardingPromptUI(
                      context,
                      "Welcome!",
                      "Let's get your first fitness plan by setting up your preferences.",
                      "Setup Preferences");
                }

                final Map<String, dynamic>? onboardingData =
                    userData['onboardingData'] as Map<String, dynamic>?;
                if (onboardingData == null || onboardingData.isEmpty) {
                  return _buildOnboardingPromptUI(
                      context,
                      "Set Your Preferences",
                      "We need your fitness goals and preferences to create the best plan for you.",
                      "Update Profile Preferences");
                }

                Map<String, dynamic>? currentRoutineData =
                    userData['currentRoutine'] as Map<String, dynamic>?;
                final routineStatusInfo = _getRoutineStatus(currentRoutineData);

                final bool showGenerateFirstOrNewUI =
                    !routineStatusInfo.isValid || routineStatusInfo.isExpired;

                if (_isGeneratingRoutine) {
                  return _buildGeneratingUI(context);
                }

                if (showGenerateFirstOrNewUI) {
                  bool hadValidPreviousAndExpired =
                      currentRoutineData != null &&
                          routineStatusInfo.isValid &&
                          routineStatusInfo.isExpired;
                  return _buildNoOrExpiredRoutineUI(
                      context, currentRoutineData, hadValidPreviousAndExpired);
                } else {
                  final WeeklyRoutine activeRoutine =
                      WeeklyRoutine.fromMap(currentRoutineData!);
                  return _buildActiveRoutineUI(
                      context, activeRoutine, routineStatusInfo.statusText);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingUI(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Accès au thème
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 16),
        Text("Hold on, crafting your plan...", style: textTheme.titleMedium),
      ],
    ));
  }

  Widget _buildOnboardingPromptUI(
      BuildContext context, String title, String message, String buttonText) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_input_component_outlined,
                size: 60, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(title,
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message,
                style: textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _isGeneratingRoutine
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary))
                  : const Icon(Icons.settings_outlined),
              label: Text(_isGeneratingRoutine ? "Please wait..." : buttonText),
              onPressed: _isGeneratingRoutine
                  ? null
                  : () => widget.onNavigateToTab(kProfileTabIndex),
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)), // Appliquer fontWeight ici
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrExpiredRoutineUI(BuildContext context,
      Map<String, dynamic>? oldRoutineData, bool hadValidPreviousAndExpired) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final String? previousRoutineName =
        (oldRoutineData != null && hadValidPreviousAndExpired)
            ? (oldRoutineData['name'] as String? ?? 'Unnamed')
            : null;

    String title =
        hadValidPreviousAndExpired ? "Routine Expired" : "No Active Routine";
    String message = hadValidPreviousAndExpired
        ? "Your previous plan (${previousRoutineName ?? 'Unnamed'}) has finished. Time for a new one!"
        : "Let's generate your personalized AI fitness plan!";
    String buttonText =
        hadValidPreviousAndExpired ? "Generate New Plan" : "Get First Plan";
    IconData iconData = hadValidPreviousAndExpired
        ? Icons.autorenew_outlined
        : Icons.add_circle_outline;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hadValidPreviousAndExpired && previousRoutineName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text("Previous: $previousRoutineName",
                style: textTheme.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: textTheme.bodySmall?.color?.withOpacity(0.7))),
          ),
        Card(
            elevation: 2,
            color: colorScheme
                .surfaceContainer, // Utiliser une couleur de surface appropriée
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, color: colorScheme.primary, size: 48),
                  const SizedBox(height: 12),
                  Text(title,
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(message,
                      style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: _isGeneratingRoutine
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary))
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                        _isGeneratingRoutine ? "Generating..." : buttonText),
                    onPressed: _isGeneratingRoutine ? null : _generateRoutine,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: textTheme.titleMedium?.copyWith(
                            fontWeight:
                                FontWeight.bold)), // Appliquer fontWeight ici
                  )
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActiveRoutineUI(BuildContext context,
      WeeklyRoutine activeRoutine, String routineStatusText) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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
                  activeRoutine.name,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                avatar: Icon(Icons.timer_outlined,
                    size: 16,
                    color: colorScheme.onSecondaryContainer.withOpacity(0.8)),
                label: Text(routineStatusText,
                    style: textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSecondaryContainer)),
                backgroundColor: colorScheme.secondaryContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                labelPadding: const EdgeInsets.only(left: 4.0),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: WeeklyRoutine.daysOfWeek.length,
            itemBuilder: (context, index) {
              final dayKey = WeeklyRoutine.daysOfWeek[index];
              final List<RoutineExercise>? dayExercises =
                  activeRoutine.dailyWorkouts[dayKey];
              final isRestDay = dayExercises == null || dayExercises.isEmpty;
              final dayTitle = dayKey[0].toUpperCase() + dayKey.substring(1);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  leading: Icon(
                    isRestDay
                        ? Icons.bedtime_outlined
                        : Icons.fitness_center_outlined,
                    color: isRestDay
                        ? colorScheme.onSurfaceVariant.withOpacity(0.7)
                        : colorScheme.primary,
                    size: 28,
                  ),
                  title: Text(dayTitle,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isRestDay
                        ? "Rest Day"
                        : "${dayExercises!.length} exercise${dayExercises.length == 1 ? '' : 's'}",
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.9)),
                  ),
                  trailing: isRestDay
                      ? null
                      : Icon(Icons.arrow_forward_ios,
                          size: 16,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                  onTap: isRestDay
                      ? null
                      : () {
                          if (dayExercises != null && dayExercises.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DailyWorkoutDetailScreen(
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
        // LE BOUTON "Generate New Plan Now" A ÉTÉ SUPPRIMÉ D'ICI
        // pour respecter la philosophie de ne pas permettre la génération manuelle
        // si un plan est déjà actif et non expiré.
      ],
    );
  }
}
