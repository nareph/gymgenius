// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/utils/enums.dart';
import 'package:gymgenius/widgets/routine_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../main_dashboard_screen.dart'; // For kProfileTabIndex

final _uuid = Uuid();

// HomeTabScreen: Displays the user's current routine, "Today's Workout" summary,
// and handles AI routine generation.
class HomeTabScreen extends StatefulWidget {
  final User user;
  final Function(int) onNavigateToTab; // Callback to navigate to other tabs

  const HomeTabScreen(
      {super.key, required this.user, required this.onNavigateToTab});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userProfileStream;
  RoutineGenerationState _routineGenerationState = RoutineGenerationState.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUserProfileStream();
    Log.debug(
        "HomeTabScreen initState: User ID: ${widget.user.uid}. Initializing profile stream.");
  }

  // Initializes the stream to listen for user profile data changes from Firestore.
  void _initializeUserProfileStream() {
    if (mounted) {
      setState(() {
        _userProfileStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .snapshots();
      });
      Log.debug(
          "HomeTabScreen _initializeUserProfileStream: Stream initialized for user ${widget.user.uid}");
    }
  }

  // Triggers the AI routine generation Cloud Function.
  Future<void> _triggerAiRoutineGeneration(
      OnboardingData onboardingData, WeeklyRoutine? previousRoutine) async {
    if (!mounted) return;
    setState(() {
      _routineGenerationState = RoutineGenerationState.loading;
      _errorMessage = null;
    });
    Log.debug(
        "HomeTabScreen _triggerAiRoutineGeneration: Setting state to LOADING for user ${widget.user.uid}.");

    bool shouldProceed = true;
    if (previousRoutine != null) {
      shouldProceed = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Generate New Routine?'),
                content: Text(previousRoutine.isExpired()
                    ? 'Your current routine has expired. Would you like to generate a new one based on your progress and previous plan?'
                    : 'You already have an active routine. Generating a new one will replace it. Are you sure you want to proceed?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  TextButton(
                    child: Text('Generate New',
                        style: TextStyle(
                            color:
                                Theme.of(dialogContext).colorScheme.primary)),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    if (!shouldProceed) {
      if (mounted) {
        setState(() {
          _routineGenerationState = RoutineGenerationState.idle;
        });
      }
      Log.debug(
          "HomeTabScreen _triggerAiRoutineGeneration: User cancelled generation.");
      return;
    }

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'generateAiRoutine',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 120)));

      final Map<String, dynamic> payload = {
        'onboardingData': onboardingData.toMap()
      };
      if (previousRoutine != null) {
        payload['previousRoutineData'] =
            previousRoutine.toMapForCloudFunction();
      }

      Log.debug(
          "HomeTabScreen _triggerAiRoutineGeneration: Calling Cloud Function 'generateAiRoutine'.");
      final HttpsCallableResult result = await callable.call(payload);

      if (!mounted) return;
      final Map<String, dynamic> aiRoutineData =
          Map<String, dynamic>.from(result.data as Map);

      final String newRoutineId = _uuid.v4();
      Map<String, dynamic> dailyWorkoutsFromAIConverted = {};
      final dynamic rawDailyWorkouts = aiRoutineData['dailyWorkouts'];

      if (rawDailyWorkouts is Map) {
        rawDailyWorkouts.forEach((dayKey, exercisesForDay) {
          if (dayKey is String && exercisesForDay is List) {
            dailyWorkoutsFromAIConverted[dayKey.toLowerCase()] = exercisesForDay
                .map((exercise) => exercise is Map
                    ? Map<String, dynamic>.from(exercise)
                    : null)
                .where((item) => item != null)
                .toList()
                .cast<Map<String, dynamic>>();
          }
        });
      } else if (rawDailyWorkouts == null) {
        Log.warning(
            "HomeTabScreen Warning: AI response missing 'dailyWorkouts'.");
      } else {
        throw Exception("AI response 'dailyWorkouts' is not a map.");
      }

      int durationInWeeks =
          (aiRoutineData['durationInWeeks'] as num?)?.toInt() ?? 4;
      durationInWeeks = durationInWeeks.clamp(1, 12);

      final WeeklyRoutine newRoutine = WeeklyRoutine.fromMap({
        'id': newRoutineId,
        'name': aiRoutineData['name'] as String? ?? "My New Routine",
        'durationInWeeks': durationInWeeks,
        'dailyWorkouts': dailyWorkoutsFromAIConverted,
        'generatedAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(
            DateTime.now().add(Duration(days: durationInWeeks * 7))),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'currentRoutine': newRoutine.toMapForFirestore(),
        'lastRoutineGeneratedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _routineGenerationState = RoutineGenerationState.success;
      });
      Log.debug("HomeTabScreen: Routine saved successfully.");
    } on FirebaseFunctionsException catch (e, s) {
      if (!mounted) return;
      Log.error(
          "HomeTabScreen FirebaseFunctionsException: ${e.code} - ${e.message}",
          error: e,
          stackTrace: s);
      setState(() {
        _routineGenerationState = RoutineGenerationState.error;
        _errorMessage =
            "Failed to generate routine: ${e.message ?? 'Cloud function error.'} (Code: ${e.code}).";
      });
    } catch (e, s) {
      if (!mounted) return;
      Log.error("HomeTabScreen Generic error: $e", error: e, stackTrace: s);
      setState(() {
        _routineGenerationState = RoutineGenerationState.error;
        _errorMessage = "An unexpected error occurred: $e.";
      });
    } finally {
      if (mounted &&
          _routineGenerationState == RoutineGenerationState.loading) {
        setState(() {
          _routineGenerationState = RoutineGenerationState.idle;
        });
      }
    }
  }

  // Starts today's workout directly. Handles confirmation if a workout is already active.
  void _startTodaysDirectWorkout(BuildContext context, WeeklyRoutine routine,
      String dayKey, List<RoutineExercise> exercisesForDay) {
    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);
    final theme = Theme.of(context);

    void _initiateAndNavigate() {
      workoutManager.forceStartNewWorkout(
        exercisesForDay,
        workoutName: "${capitalize(routine.name)} - ${capitalize(dayKey)}",
        routineId: routine.id,
        dayKey: dayKey.toLowerCase(),
      );
      if (mounted && workoutManager.isWorkoutActive) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActiveWorkoutSessionScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Failed to start the workout."),
            backgroundColor: theme.colorScheme.error));
      }
    }

    if (workoutManager.isWorkoutActive) {
      showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
                title: const Text("Workout in Progress"),
                content: const Text(
                    "A workout session is currently active. What would you like to do?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ActiveWorkoutSessionScreen()));
                    },
                    child: Text("Resume Current",
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      _initiateAndNavigate();
                    },
                    child: Text("End & Start New",
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text("Cancel")),
                ],
              ));
    } else {
      _initiateAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.debug("HomeTabScreen build: UI State: $_routineGenerationState");
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userProfileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _userProfileStream == null) {
            return const Center(
                child: CircularProgressIndicator(
                    key: Key("initial_profile_load")));
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              _routineGenerationState != RoutineGenerationState.loading &&
              _routineGenerationState != RoutineGenerationState.error &&
              _routineGenerationState != RoutineGenerationState.success) {
            return const Center(
                child: CircularProgressIndicator(
                    key: Key("profile_snapshot_waiting")));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading profile: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildWrapperForRefreshIndicatorCenteredContent(
                _buildErrorState("User profile not found.",
                    OnboardingData(completed: false), null));
          }

          final Map<String, dynamic> userProfile = snapshot.data!.data()!;
          final bool onboardingCompletedFlag =
              userProfile['onboardingCompleted'] as bool? ?? false;
          OnboardingData onboardingDataModel = OnboardingData.fromMap(
              userProfile['onboardingData'] is Map
                  ? Map<String, dynamic>.from(userProfile['onboardingData'])
                  : {});
          if (onboardingDataModel.completed != onboardingCompletedFlag) {
            onboardingDataModel = onboardingDataModel.copyWith(
                completed: onboardingCompletedFlag);
          }

          final WeeklyRoutine? currentRoutine =
              userProfile['currentRoutine'] != null &&
                      userProfile['currentRoutine'] is Map
                  ? WeeklyRoutine.fromMap(
                      Map<String, dynamic>.from(userProfile['currentRoutine']))
                  : null;

          if (!onboardingCompletedFlag) {
            return _buildWrapperForRefreshIndicatorCenteredContent(
                _buildNeedsProfileCompletionState(context, true));
          }
          if (!onboardingDataModel.isSufficientForAiGeneration) {
            Log.debug(
                "HomeTabScreen: Onboarding data is insufficient. isSufficient: ${onboardingDataModel.isSufficientForAiGeneration}, Data: ${onboardingDataModel.toMap()}");
            return RefreshIndicator(
              onRefresh: () async => _initializeUserProfileStream(),
              child: _buildWrapperForRefreshIndicatorCenteredContent(
                  _buildNeedsProfileCompletionState(context, false)),
            );
          }

          final OnboardingData finalOnboardingData = onboardingDataModel;
          Widget screenContent;

          if (_routineGenerationState == RoutineGenerationState.loading) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildLoadingIndicator("Generating your routine..."));
          } else if (_routineGenerationState == RoutineGenerationState.error &&
              _errorMessage != null) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildErrorState(
                    _errorMessage!, finalOnboardingData, currentRoutine));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  _routineGenerationState == RoutineGenerationState.error) {
                setState(() {
                  _routineGenerationState = RoutineGenerationState.idle;
                });
              }
            });
          } else if (currentRoutine == null ||
              _routineGenerationState == RoutineGenerationState.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  _routineGenerationState == RoutineGenerationState.success) {
                setState(() {
                  _routineGenerationState = RoutineGenerationState.idle;
                });
              }
            });
            if (currentRoutine == null) {
              screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                  _buildNoRoutineState(finalOnboardingData));
            } else {
              screenContent = ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCurrentRoutineSection(
                      currentRoutine, finalOnboardingData)
                ],
              );
            }
          } else if (currentRoutine.isExpired()) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildExpiredRoutineState(currentRoutine, finalOnboardingData));
          } else {
            screenContent = ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCurrentRoutineSection(currentRoutine, finalOnboardingData)
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (currentRoutine != null &&
                  !currentRoutine.isExpired() &&
                  _routineGenerationState == RoutineGenerationState.idle) {
                Log.debug(
                    "Refresh action: Active routine present. No regeneration triggered by pull-to-refresh.");
                return;
              }
              await _triggerAiRoutineGeneration(
                  finalOnboardingData, currentRoutine);
            },
            child: screenContent,
          );
        },
      ),
    );
  }

  // Wraps content to ensure it's scrollable for RefreshIndicator and centered if small.
  Widget _buildWrapperForRefreshIndicatorCenteredContent(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: constraints.maxHeight - 32.0),
            child: Center(child: child),
          ),
        );
      },
    );
  }

  // Displays a loading indicator with a message.
  Widget _buildLoadingIndicator(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium),
      ]),
    );
  }

  // Displays an error message card, typically for routine generation failures.
  Widget _buildErrorState(String errorMessage, OnboardingData onboardingData,
      WeeklyRoutine? previousRoutine) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline,
              color: theme.colorScheme.onErrorContainer, size: 40),
          const SizedBox(height: 10),
          Text("Routine Generation Failed",
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onErrorContainer)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            onPressed: () =>
                _triggerAiRoutineGeneration(onboardingData, previousRoutine),
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError),
          )
        ]),
      ),
    );
  }

  // Displays when no current workout routine is found for the user.
  Widget _buildNoRoutineState(OnboardingData onboardingData) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.fitness_center,
              size: 50, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text("No Workout Plan Found",
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text(
              "Let's generate a personalized workout plan to help you reach your fitness goals!",
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text("Generate My First Routine"),
            onPressed: () => _triggerAiRoutineGeneration(onboardingData, null),
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ]),
      ),
    );
  }

  // Displays when user's onboarding is flagged as complete but data is insufficient,
  // or if onboardingCompleted flag is false.
  Widget _buildNeedsProfileCompletionState(
      BuildContext context, bool dueToOnboardingFlagFalse) {
    final theme = Theme.of(context);
    String title = dueToOnboardingFlagFalse
        ? "Finalize Account Setup"
        : "Complete Your Profile";
    String message = dueToOnboardingFlagFalse
        ? "Please complete your profile to activate all features and get your personalized workout plan."
        : "To generate a personalized workout plan, we need a bit more information about you and your goals.";
    String buttonText =
        dueToOnboardingFlagFalse ? "Go to Profile" : "Complete Profile";

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_pin_circle_outlined,
              size: 50, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.account_circle_outlined),
            label: Text(buttonText),
            onPressed: () => widget.onNavigateToTab(kProfileTabIndex),
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ]),
      ),
    );
  }

  // Displays when the user's current routine has expired.
  Widget _buildExpiredRoutineState(
      WeeklyRoutine expiredRoutine, OnboardingData onboardingData) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.colorScheme.tertiaryContainer.withAlpha((178).round()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_busy_outlined,
              size: 50, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(height: 16),
          Text("Routine Expired!",
              style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
              "Your routine '${expiredRoutine.name}' which started on ${DateFormat.yMMMd().format(expiredRoutine.generatedAt.toDate())} has completed its ${expiredRoutine.durationInWeeks} weeks.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
          const SizedBox(height: 8),
          Text(
              "It's time to generate a new plan to continue your fitness journey and build on your progress!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer
                      .withAlpha((230).round()))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.autorenew_rounded),
            label: const Text("Generate New Routine"),
            onPressed: () =>
                _triggerAiRoutineGeneration(onboardingData, expiredRoutine),
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.uid)
                  .update({'currentRoutine': null});
            },
            child: Text("Dismiss (Clear Old Routine)",
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant
                        .withAlpha((204).round()))),
          )
        ]),
      ),
    );
  }

  // Builds the main section displaying the current routine information.
  Widget _buildCurrentRoutineSection(
      WeeklyRoutine currentRoutine, OnboardingData onboardingData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final today = DateTime.now();
    final todayDayKey = WeeklyRoutine.daysOfWeek[today.weekday - 1];
    final List<RoutineExercise>? todaysExercises =
        currentRoutine.dailyWorkouts[todayDayKey.toLowerCase()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Current Plan: ${currentRoutine.name}",
            style: textTheme.headlineSmall),
        Text(
          "Duration: ${currentRoutine.durationInWeeks} weeks. Expires: ${DateFormat.yMMMd().add_jm().format(currentRoutine.expiresAt.toDate().toLocal())}",
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (todaysExercises != null &&
            todaysExercises.isNotEmpty &&
            !currentRoutine.isExpired())
          Card(
            color: colorScheme.primaryContainer.withAlpha((178).round()),
            elevation: 2,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              leading: Icon(Icons.fitness_center,
                  color: colorScheme.onPrimaryContainer, size: 30),
              title: Text("Today: ${capitalize(todayDayKey)}",
                  style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer)),
              subtitle: Text("${todaysExercises.length} exercises planned",
                  style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer
                          .withAlpha((204).round()))),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text("START"),
                onPressed: () => _startTodaysDirectWorkout(
                    context, currentRoutine, todayDayKey, todaysExercises),
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        else if (!currentRoutine.isExpired()) // Rest Day
          Card(
            color: colorScheme.surfaceContainerHighest,
            elevation: 1,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              leading: Icon(Icons.hotel_rounded,
                  color: colorScheme.onSurfaceVariant, size: 30),
              title: Text("Rest Day Today!",
                  style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant)),
              subtitle: Text(
                  "Enjoy your recovery, ${widget.user.displayName?.split(' ')[0] ?? 'User'}.",
                  style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withAlpha((204).round()))),
            ),
          ),
        const SizedBox(height: 24),
        if (!currentRoutine.isExpired()) ...[
          Text("Full Routine Schedule:",
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: WeeklyRoutine.daysOfWeek.length,
            itemBuilder: (context, index) {
              final dayKey = WeeklyRoutine.daysOfWeek[index];
              final exercises =
                  currentRoutine.dailyWorkouts[dayKey.toLowerCase()] ?? [];
              return RoutineCard(
                dayKey: dayKey,
                exercises: exercises,
                parentRoutine: currentRoutine,
                onboardingData:
                    onboardingData, // Pass onboardingData to RoutineCard
                isToday: dayKey.toLowerCase() == todayDayKey.toLowerCase(),
              );
            },
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // Helper to capitalize the first letter of a string.
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
