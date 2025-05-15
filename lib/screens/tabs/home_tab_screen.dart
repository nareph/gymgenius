// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/screens/active_workout_session_screen.dart';
// import 'package:gymgenius/screens/daily_workout_detail_screen.dart'; // Pas utilisé directement ici pour le moment
import 'package:gymgenius/utils/enums.dart';
import 'package:gymgenius/widgets/routine_card.dart';
import 'package:intl/intl.dart'; // <<--- ADDED for date formatting
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

    // Afficher une boîte de dialogue de confirmation si une routine précédente existe (même expirée)
    bool shouldProceed = true;
    if (previousRoutine != null) {
      shouldProceed = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Generate New Routine?'),
                content: Text(previousRoutine.isExpired()
                    ? 'Your current routine has expired. Would you like to generate a new one based on your progress and previous plan?'
                    : 'You already have an active routine. Generating a new one will replace it. Are you sure you want to proceed? (This option might be removed or restricted later)'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Generate New',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                  ),
                ],
              );
            },
          ) ??
          false; // Si la dialogue est fermée sans sélection, on considère false
    }

    if (!shouldProceed) {
      setState(() {
        _routineGenerationState =
            RoutineGenerationState.idle; // Reset loading state
      });
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: User cancelled generation.");
      return;
    }

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'generateAiRoutine',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 120)));

      final Map<String, dynamic> payload = {
        'onboardingData': onboardingData.toMap(),
      };
      if (previousRoutine != null) {
        // Assurez-vous que toMapForCloudFunction() existe et fonctionne correctement
        payload['previousRoutineData'] =
            previousRoutine.toMapForCloudFunction();
        print(
            "HomeTabScreen _triggerAiRoutineGeneration: Calling Cloud Function 'generateAiRoutine' with onboarding data and previous routine: ${previousRoutine.id}");
      } else {
        print(
            "HomeTabScreen _triggerAiRoutineGeneration: Calling Cloud Function 'generateAiRoutine' with onboarding data only.");
      }

      final HttpsCallableResult result = await callable.call(payload);

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

      int durationInWeeks =
          (aiRoutineData['durationInWeeks'] as num?)?.toInt() ?? 4;
      // Assurer une durée minimale (ex: 1 semaine) et maximale (ex: 12 semaines)
      durationInWeeks = durationInWeeks.clamp(1, 12);

      final Map<String, dynamic> dataForWeeklyRoutineConstructor = {
        'id': newRoutineId,
        'name': aiRoutineData['name'] as String? ?? "My New Routine",
        'durationInWeeks': durationInWeeks,
        'dailyWorkouts': dailyWorkoutsFromAIConverted,
        'generatedAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(
            DateTime.now().add(Duration(days: durationInWeeks * 7))),
      };
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Data being passed to WeeklyRoutine.fromMap: $dataForWeeklyRoutineConstructor");

      final WeeklyRoutine newRoutine =
          WeeklyRoutine.fromMap(dataForWeeklyRoutineConstructor);

      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Constructed WeeklyRoutine object. Name: ${newRoutine.name}, ID: ${newRoutine.id}, Duration: ${newRoutine.durationInWeeks} weeks.");
      // ... (le reste du logging et de la création de routine) ...

      final Map<String, dynamic> routineToSaveInFirestore =
          newRoutine.toMapForFirestore();
      print(
          "HomeTabScreen _triggerAiRoutineGeneration: Data being sent to Firestore (toMapForFirestore result): $routineToSaveInFirestore");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'currentRoutine': routineToSaveInFirestore,
        'onboardingCompleted': true, // S'assurer que c'est toujours vrai ici
        'lastRoutineGeneratedAt': FieldValue.serverTimestamp(),
        // Potentiellement, stocker un historique des routines si nécessaire
        // 'routineHistory': FieldValue.arrayUnion([previousRoutine?.toMapForFirestore()]) // Exemple
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
            "An unexpected error occurred while creating your routine: $e. Please try again.";
      });
    } finally {
      // S'assurer que l'état de chargement est réinitialisé même en cas d'erreur avant la fin
      if (_routineGenerationState == RoutineGenerationState.loading &&
          mounted) {
        setState(() {
          _routineGenerationState = RoutineGenerationState.idle;
        });
      }
    }
  }

  void _startTodaysWorkout(
      BuildContext context, WeeklyRoutine routine, String dayKey) {
    // ... (votre logique existante pour _startTodaysWorkout, qui semble correcte)
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
          // Garder l'indicateur de chargement si _routineGenerationState est loading,
          // SAUF si on est déjà dans un état d'erreur ou de succès pour cette génération.
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
            print(
                "HomeTabScreen: User profile document does not exist for user ${widget.user.uid}.");
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
            print("HomeTabScreen: onboardingCompletedFlag is false.");
            return _buildWrapperForRefreshIndicatorCenteredContent(
                _buildNeedsProfileCompletionState(context, true));
          }

          if (!onboardingDataModel.isSufficientForAiGeneration) {
            print(
                "HomeTabScreen: Onboarding data is insufficient. isSufficient: ${onboardingDataModel.isSufficientForAiGeneration}");
            return RefreshIndicator(
              onRefresh: () async {
                _initializeUserProfileStream(); // Re-fetch profile data
              },
              child: _buildWrapperForRefreshIndicatorCenteredContent(
                  _buildNeedsProfileCompletionState(context, false)),
            );
          }

          final OnboardingData finalOnboardingData = onboardingDataModel;

          Widget screenContent;

          // Priorité à l'état de génération de routine
          if (_routineGenerationState == RoutineGenerationState.loading) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildLoadingIndicator(
                    "Generating your personalized routine..."));
          } else if (_routineGenerationState == RoutineGenerationState.error &&
              _errorMessage != null) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildErrorState(
                    _errorMessage!, finalOnboardingData, currentRoutine));
            // Après affichage de l'erreur, revenir à idle pour permettre une nouvelle tentative
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
            // Si la routine est null OU si on vient de générer avec succès une nouvelle routine
            // (pour forcer la reconstruction de l'UI avec la nouvelle routine si currentRoutine était déjà là mais expiré)
            // L'état success est temporaire, on veut afficher la nouvelle routine ou l'état "pas de routine"
            // Si success, currentRoutine devrait être mis à jour par le stream, sinon on affiche "NoRoutine"
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
              // Si routineGenerationState était success, on veut afficher la routine (qui devrait être la nouvelle)
              screenContent = ListView(
                // Changed to ListView to avoid AlwaysScrollableScrollPhysics conflict
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCurrentRoutineSection(
                      currentRoutine, finalOnboardingData)
                ],
              );
            }
          }
          // Si une routine existe et qu'elle est expirée
          else if (currentRoutine.isExpired()) {
            screenContent = _buildWrapperForRefreshIndicatorCenteredContent(
                _buildExpiredRoutineState(currentRoutine, finalOnboardingData));
          }
          // Si une routine existe et n'est pas expirée
          else {
            screenContent = ListView(
              // Changed to ListView
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
                // Si une routine active existe, le pull-to-refresh ne devrait rien faire
                // ou afficher un message indiquant que la routine est active.
                // Pour l'instant, on ne fait rien pour éviter une génération non désirée.
                print(
                    "Refresh action: Active routine present. No regeneration triggered.");
                return;
              }
              // Si routine expirée ou pas de routine, ou si on est dans un état d'erreur, on peut tenter de générer.
              await _triggerAiRoutineGeneration(finalOnboardingData,
                  currentRoutine); // Passe la routine actuelle (expirée ou non)
            },
            child: screenContent,
          );
        },
      ),
    );
  }

  Widget _buildWrapperForRefreshIndicatorCenteredContent(Widget child) {
    // ... (inchangé)
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  32.0, // Adjust if AppBar is present or other fixed elements
            ),
            child: Center(
              // Center the content vertically if it's smaller than the viewport
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(String message) {
    // ... (inchangé)
    return Center(
      // Wrap in Center if not already centered by parent
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
    // ... (inchangé)
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
          Text(errorMessage, // Utilise le _errorMessage mis à jour
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
    // ... (inchangé)
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
            onPressed: () => _triggerAiRoutineGeneration(
                onboardingData, null), // Pas de routine précédente
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
    // ... (inchangé)
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

  // <<--- NEW WIDGET for Expired Routine State --- >>
  Widget _buildExpiredRoutineState(
      WeeklyRoutine expiredRoutine, OnboardingData onboardingData) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.colorScheme.tertiaryContainer.withAlpha((0.7 * 255).round()),
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
              "Your routine '${expiredRoutine.name}' which started on ${DateFormat.yMMMd().format(expiredRoutine.generatedAt!.toDate())} has completed its ${expiredRoutine.durationInWeeks} weeks.", // Assumes generatedAt is not null
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
          const SizedBox(height: 8),
          Text(
              "It's time to generate a new plan to continue your fitness journey and build on your progress!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer
                      .withAlpha((0.9 * 255).round()))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.autorenew_rounded),
            label: const Text("Generate New Routine"),
            onPressed: () => _triggerAiRoutineGeneration(
                onboardingData, expiredRoutine), // Passe la routine expirée
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
              // Pourrait afficher l'ancienne routine en lecture seule ou la supprimer
              // Pour l'instant, on retourne à un état de "pas de routine" si l'utilisateur ne veut pas générer
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.uid)
                  .update({
                'currentRoutine': null, // ou archiver l'ancienne routine
                // 'archivedRoutines': FieldValue.arrayUnion([expiredRoutine.toMapForFirestore()])
              }).then((_) {
                print("Expired routine cleared / archived conceptually.");
                // L'UI se mettra à jour via le StreamBuilder pour afficher _buildNoRoutineState
              }).catchError((error) {
                print("Error clearing/archiving expired routine: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Could not clear old routine: $error"),
                      backgroundColor: theme.colorScheme.error),
                );
              });
            },
            child: Text("Dismiss (Clear Old Routine)",
                style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant
                        .withAlpha((0.8 * 255).round()))),
          )
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

    // bool isRoutineExpired = currentRoutine.isExpired(); // Déjà vérifié avant d'appeler cette méthode

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Current Plan: ${currentRoutine.name}",
            style: Theme.of(context).textTheme.headlineSmall),
        Text(
            "Duration: ${currentRoutine.durationInWeeks} weeks. Expires: ${DateFormat.yMMMd().add_jm().format(currentRoutine.expiresAt!.toDate().toLocal())}", // Assumes expiresAt is not null
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
        // Le bouton "Generate New Routine Variation" est maintenant conditionnel ou remplacé par le flux d'expiration
        // Si la routine n'est PAS expirée, on ne montre PAS ce bouton pour forcer l'adhérence au plan.
        // Il sera géré par _buildExpiredRoutineState si la routine est expirée.
        // Pour l'instant, on le cache si la routine est active.
        // Center(
        //   child: OutlinedButton.icon(
        //     icon: const Icon(Icons.autorenew_outlined),
        //     label: const Text("Generate New Routine Variation"),
        //     onPressed: () =>
        //         _triggerAiRoutineGeneration(onboardingData, currentRoutine),
        //     style: OutlinedButton.styleFrom(
        //         padding:
        //             const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //         side: BorderSide(color: theme.colorScheme.primary)),
        //   ),
        // ),
      ],
    );
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
