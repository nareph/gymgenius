// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
import 'package:gymgenius/utils/enums.dart';
import 'package:gymgenius/widgets/routine_card.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../main_dashboard_screen.dart'; // Pour kProfileTabIndex

final _uuid = Uuid();

class HomeTabScreen extends StatefulWidget {
  final User user;
  final Function(int) onNavigateToTab;

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
    print(
        "HomeTabScreen initState: User ID: ${widget.user.uid}. Initializing profile stream.");
  }

  void _initializeUserProfileStream() {
    if (mounted) {
      setState(() {
        _userProfileStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .snapshots();
      });
      print(
          "HomeTabScreen _initializeUserProfileStream: Stream initialized for user ${widget.user.uid}");
    }
  }

  Future<void> _triggerAiRoutineGeneration(
      OnboardingData onboardingData, WeeklyRoutine? previousRoutine) async {
    if (!mounted) return;
    setState(() {
      _routineGenerationState = RoutineGenerationState.loading;
      _errorMessage = null;
    });
    print(
        "HomeTabScreen _triggerAiRoutineGeneration: Setting state to LOADING for user ${widget.user.uid}.");

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'generateAiRoutine',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 120)));

      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Calling Cloud Function 'generateAiRoutine' with onboarding data: ${onboardingData.toMap()} and possibly previous routine: ${previousRoutine?.toMapForCloudFunction()}");
      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        'onboardingData': onboardingData.toMap(),
        if (previousRoutine != null)
          'previousRoutineData': previousRoutine.toMapForCloudFunction(),
      });

      if (!mounted) return;

      final Map<String, dynamic> aiRoutineData;
      if (result.data is Map) {
        try {
          aiRoutineData = Map<String, dynamic>.from(result.data as Map);
        } catch (e) {
          print("Error converting result.data to Map<String, dynamic>: $e");
          throw Exception(
              "Received malformed data structure from AI service (top level).");
        }
      } else {
        print(
            "AI response (result.data) is not a Map: ${result.data.runtimeType}");
        throw Exception("Unexpected data format from AI service (top level).");
      }

      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Received data from Cloud Function: $aiRoutineData");

      final String newRoutineId = _uuid.v4();

      Map<String, dynamic> dailyWorkoutsFromAIConverted = {};
      final dynamic rawDailyWorkouts = aiRoutineData['dailyWorkouts'];

      if (rawDailyWorkouts == null) {
        print(
            "Warning: AI response missing 'dailyWorkouts'. Proceeding with empty workouts.");
      } else if (rawDailyWorkouts is Map) {
        rawDailyWorkouts.forEach((dayKey, exercisesForDay) {
          if (dayKey is String && exercisesForDay is List) {
            List<Map<String, dynamic>> convertedExercises = [];
            for (var exercise in exercisesForDay) {
              if (exercise is Map) {
                try {
                  convertedExercises.add(Map<String, dynamic>.from(exercise));
                } catch (e) {
                  print(
                      "Error converting an exercise to Map<String, dynamic> for day $dayKey: $e. Exercise data: $exercise");
                }
              } else {
                print(
                    "Exercise data for day $dayKey is not a Map: ${exercise.runtimeType}");
              }
            }
            dailyWorkoutsFromAIConverted[dayKey.toLowerCase()] =
                convertedExercises;
          } else {
            print(
                "Malformed daily workout entry: Day key is not String or exercises not List. Key: ${dayKey.runtimeType}, Value: ${exercisesForDay.runtimeType}");
          }
        });
      } else {
        throw Exception(
            "AI response 'dailyWorkouts' is not a map. Received: ${rawDailyWorkouts.runtimeType}");
      }

      final Map<String, dynamic> dataForWeeklyRoutineConstructor = {
        'id': newRoutineId,
        'name': aiRoutineData['name'] as String?,
        'durationInWeeks': (aiRoutineData['durationInWeeks'] as num?)?.toInt(),
        'dailyWorkouts': dailyWorkoutsFromAIConverted,
        'generatedAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(
            days: ((aiRoutineData['durationInWeeks'] as num?)?.toInt() ?? 4) *
                7))),
      };
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Data being passed to WeeklyRoutine.fromMap: $dataForWeeklyRoutineConstructor");

      final WeeklyRoutine newRoutine =
          WeeklyRoutine.fromMap(dataForWeeklyRoutineConstructor);

      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Constructed WeeklyRoutine object. Name: ${newRoutine.name}, ID: ${newRoutine.id}, Duration: ${newRoutine.durationInWeeks} weeks.");
      newRoutine.dailyWorkouts.forEach((day, exercises) {
        print(
            "HomeTabScreen _triggerAiRoutineGeneration: Processed Day: $day, Number of exercises: ${exercises.length}");
        for (var ex in exercises) {
          print(
              "HomeTabScreen _triggerAiRoutineGeneration: Processed Exercise in newRoutine: ID: ${ex.id}, Name: '${ex.name}', Sets: ${ex.sets}, Reps: ${ex.reps}, UsesWeight: ${ex.usesWeight}, IsTimed: ${ex.isTimed}, TargetDuration: ${ex.targetDurationSeconds}, Desc: '${ex.description}', WeightSugg: '${ex.weightSuggestionKg}'");
        }
      });

      final Map<String, dynamic> routineToSaveInFirestore =
          newRoutine.toMapForFirestore();
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Data being sent to Firestore (toMapForFirestore result): $routineToSaveInFirestore");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'currentRoutine': routineToSaveInFirestore,
        'onboardingCompleted': true,
        'lastRoutineGeneratedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _routineGenerationState = RoutineGenerationState.success;
        print(
            "HomeTabScreen _triggerAiRoutineGeneration: Routine saved successfully. State set to SUCCESS.");
      });
    } on FirebaseFunctionsException catch (e, s) {
      if (!mounted) return;
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: FirebaseFunctionsException calling 'generateAiRoutine': ${e.code} - ${e.message}\nDetails: ${e.details}\nStackTrace: $s");
      setState(() {
        _routineGenerationState = RoutineGenerationState.error;
        _errorMessage =
            "Failed to generate routine: ${e.message ?? 'Cloud function error.'} (Code: ${e.code}). Please try again.";
      });
    } catch (e, s) {
      if (!mounted) return;
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Generic error during routine generation process: $e\nStackTrace: $s");
      setState(() {
        _routineGenerationState = RoutineGenerationState.error;
        _errorMessage =
            "An unexpected error occurred while creating your routine. Please try again in a few moments. If the issue continues, our team has been notified.";
      });
    }
  }

  void _startTodaysWorkout(
      BuildContext context, WeeklyRoutine routine, String dayKey) {
    final List<RoutineExercise>? exercisesForDay =
        routine.dailyWorkouts[dayKey.toLowerCase()];

    if (exercisesForDay == null || exercisesForDay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("No exercises planned for ${capitalize(dayKey)} today."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      print("HomeTabScreen _startTodaysWorkout: No exercises for $dayKey.");
      return;
    }

    final workoutManager =
        Provider.of<WorkoutSessionManager>(context, listen: false);
    final theme = Theme.of(context);

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
                            builder: (_) => const ActiveWorkoutSessionScreen()),
                      );
                    },
                    child: Text("Resume Current",
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      workoutManager.forceStartNewWorkout(
                        exercisesForDay,
                        workoutName:
                            "${capitalize(routine.name)} - ${capitalize(dayKey)}",
                        routineId: routine.id,
                        dayKey: dayKey.toLowerCase(),
                      );
                      if (workoutManager.isWorkoutActive) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ActiveWorkoutSessionScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                const Text("Failed to start the new workout."),
                            backgroundColor: theme.colorScheme.error));
                      }
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
      bool started = workoutManager.startWorkoutIfNoSession(
        exercisesForDay,
        workoutName: "${capitalize(routine.name)} - ${capitalize(dayKey)}",
        routineId: routine.id,
        dayKey: dayKey.toLowerCase(),
      );
      if (started) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ActiveWorkoutSessionScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                "Failed to start workout. An unexpected error occurred."),
            backgroundColor: theme.colorScheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        "HomeTabScreen build: Building UI. Current routine generation state: $_routineGenerationState");
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
              _routineGenerationState != RoutineGenerationState.loading) {
            return const Center(
                child: CircularProgressIndicator(
                    key: Key("profile_snapshot_waiting")));
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error loading profile: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print(
                "HomeTabScreen: User profile document does not exist for user ${widget.user.uid}. This is unexpected if AuthWrapper worked correctly.");
            return _buildWrapperForRefreshIndicatorCenteredContent(
                _buildErrorState(
                    "User profile not found. Please try logging out and back in.",
                    OnboardingData(completed: false),
                    null));
          }

          final Map<String, dynamic> userProfile = snapshot.data!.data()!;
          final bool onboardingCompletedFlag =
              userProfile['onboardingCompleted'] as bool? ?? false;

          OnboardingData? onboardingDataModel;
          if (userProfile['onboardingData'] != null &&
              userProfile['onboardingData'] is Map) {
            try {
              onboardingDataModel = OnboardingData.fromMap(
                  Map<String, dynamic>.from(userProfile['onboardingData']));
            } catch (e) {
              print("Error parsing onboardingData from Firestore: $e");
              onboardingDataModel =
                  OnboardingData(completed: onboardingCompletedFlag);
            }
          } else {
            onboardingDataModel =
                OnboardingData(completed: onboardingCompletedFlag);
          }

          final WeeklyRoutine? currentRoutine =
              userProfile['currentRoutine'] != null &&
                      userProfile['currentRoutine'] is Map
                  ? WeeklyRoutine.fromMap(
                      Map<String, dynamic>.from(userProfile['currentRoutine']))
                  : null;

          if (!onboardingCompletedFlag) {
            print(
                "HomeTabScreen: onboardingCompletedFlag is false. This user should have been caught by AuthWrapper.");
            return _buildWrapperForRefreshIndicatorCenteredContent(
                _buildNeedsProfileCompletionState(context, true));
          }

          if (onboardingDataModel == null ||
              !onboardingDataModel.isSufficientForAiGeneration) {
            print(
                "HomeTabScreen: Onboarding is 'completed' (flag is true) but data is insufficient or null. User needs to complete profile details. isSufficient: ${onboardingDataModel?.isSufficientForAiGeneration}");
            return RefreshIndicator(
              onRefresh: () async {
                _initializeUserProfileStream();
              },
              child: _buildWrapperForRefreshIndicatorCenteredContent(
                  _buildNeedsProfileCompletionState(context, false)),
            );
          }

          final OnboardingData finalOnboardingData = onboardingDataModel;

          Widget screenContent;

          if (_routineGenerationState == RoutineGenerationState.loading) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildLoadingIndicator(
                    "Generating your personalized routine..."));
          } else if (_routineGenerationState == RoutineGenerationState.error &&
              _errorMessage != null) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildErrorState(
                    _errorMessage!, finalOnboardingData, currentRoutine));
          } else if (currentRoutine == null) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildNoRoutineState(finalOnboardingData));
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
              await _triggerAiRoutineGeneration(
                  finalOnboardingData, currentRoutine);
            },
            child: screenContent,
          );
        },
      ),
    );
  }

  Widget _buildWrapperForRefreshIndicatorCenteredContent(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 32.0,
            ),
            child: Center(
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
        ]),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, OnboardingData onboardingData,
      WeeklyRoutine? previousRoutine) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer, size: 40),
          const SizedBox(height: 10),
          Text(
            "Routine Generation Failed",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            onPressed: () =>
                _triggerAiRoutineGeneration(onboardingData, previousRoutine),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError),
          )
        ]),
      ),
    );
  }

  Widget _buildNoRoutineState(OnboardingData onboardingData) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.fitness_center,
              size: 50, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text("No Workout Plan Found",
              style: Theme.of(context).textTheme.headlineSmall,
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

  Widget _buildNeedsProfileCompletionState(
      BuildContext context, bool dueToOnboardingFlagFalse) {
    String title = "Complete Your Profile";
    String message =
        "To generate a personalized workout plan, we need a bit more information about you and your goals.";
    String buttonText = "Complete Profile";

    if (dueToOnboardingFlagFalse) {
      title = "Finalize Account Setup";
      message =
          "Please complete your profile to activate all features and get your personalized workout plan.";
      buttonText = "Go to Profile";
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_pin_circle_outlined,
              size: 50, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.account_circle_outlined),
            label: Text(buttonText),
            onPressed: () {
              widget.onNavigateToTab(kProfileTabIndex);
            },
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ]),
      ),
    );
  }

  Widget _buildCurrentRoutineSection(
      WeeklyRoutine currentRoutine, OnboardingData onboardingData) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayDayKey = WeeklyRoutine.daysOfWeek[today.weekday - 1];
    final List<RoutineExercise>? todaysExercises =
        currentRoutine.dailyWorkouts[todayDayKey.toLowerCase()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Current Plan: ${currentRoutine.name}",
            style: Theme.of(context).textTheme.headlineSmall),
        Text(
            "Duration: ${currentRoutine.durationInWeeks} weeks. Expires: ${currentRoutine.expiresAt.toDate().toLocal().toString().split(' ')[0]}",
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        if (todaysExercises != null && todaysExercises.isNotEmpty)
          Card(
            color: theme.colorScheme.primaryContainer
                .withAlpha((0.7 * 255).round()),
            elevation: 1,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              leading: Icon(Icons.fitness_center_outlined,
                  color: theme.colorScheme.onPrimaryContainer, size: 28),
              title: Text("Today: ${capitalize(todayDayKey)}",
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer)),
              subtitle: Text("${todaysExercises.length} exercises planned",
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withAlpha((0.8 * 255).round()))),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text("Start"),
                onPressed: () =>
                    _startTodaysWorkout(context, currentRoutine, todayDayKey),
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          )
        else
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: ListTile(
              leading: Icon(Icons.weekend_outlined,
                  color: theme.colorScheme.onSurfaceVariant),
              title: Text("Rest Day Today!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant)),
              subtitle: Text(
                  "Enjoy your recovery, ${widget.user.displayName?.split(' ')[0] ?? 'User'}.",
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant
                          .withAlpha((0.8 * 255).round()))),
            ),
          ),
        const SizedBox(height: 20),
        Text("Full Routine Schedule:",
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
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
              isToday: dayKey.toLowerCase() == todayDayKey.toLowerCase(),
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.autorenew_outlined),
            label: const Text("Generate New Routine Variation"),
            onPressed: () =>
                _triggerAiRoutineGeneration(onboardingData, currentRoutine),
            style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
      ],
    );
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
