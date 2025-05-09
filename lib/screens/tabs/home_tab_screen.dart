// lib/screens/tabs/home_tab_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import for Firebase Functions
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Static routine import is no longer needed as we call a Cloud Function.
// import 'package:gymgenius/data/static_routine.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/screens/daily_workout_detail_screen.dart';
import 'package:uuid/uuid.dart'; // For generating new routine IDs

// Global Uuid instance (consider making it private or local if only used here)
var uuid = Uuid();

// Constant for the Profile tab index (adjust if your tab order changes)
const int kProfileTabIndex = 2; // Assuming Home(0), Tracking(1), Profile(2)
// If you have 4 tabs and Profile is last, this would be 3.

class HomeTabScreen extends StatefulWidget {
  final User user;
  final Function(int) onNavigateToTab; // Callback to navigate to a specific tab

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
  // Firebase Functions instance
  // ADJUST THE REGION if necessary (e.g., 'europe-west1') for your Cloud Functions.
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  void initState() {
    super.initState();
    _userDocStream = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .snapshots() // Listen to real-time updates of the user document
        .cast<DocumentSnapshot<Map<String, dynamic>>>(); // Ensure correct type

    // Emulator configuration for Functions should now be done in main.dart for global setup.
  }

  // Calls the Cloud Function to generate an AI-powered routine.
  Future<Map<String, dynamic>> _callAiRoutineService({
    required String
        userId, // Useful for logging or context in the Cloud Function
    required Map<String, dynamic> onboardingData,
    Map<String, dynamic>?
        previousRoutineData, // Optional: for evolving routines
  }) async {
    print("HomeTabScreen: Calling Cloud Function 'generateAiRoutine'...");

    final Map<String, dynamic> payload = {
      'onboardingData': onboardingData,
      if (previousRoutineData != null)
        'previousRoutineData': previousRoutineData,
    };

    final HttpsCallable callable =
        _functions.httpsCallable('generateAiRoutine');

    try {
      final HttpsCallableResult result =
          await callable.call<Map<String, dynamic>>(payload);
      print("HomeTabScreen: Received data from Cloud Function: ${result.data}");
      if (result.data == null) {
        throw Exception(
            "Cloud function 'generateAiRoutine' returned null data.");
      }
      // Basic validation for expected keys from the Cloud Function response
      if (result.data!['name'] == null ||
          result.data!['durationInWeeks'] == null ||
          result.data!['dailyWorkouts'] == null) {
        throw Exception(
            "Cloud function returned an incomplete data structure. Missing 'name', 'durationInWeeks', or 'dailyWorkouts'.");
      }
      return result.data!; // Return the data from the Cloud Function
    } on FirebaseFunctionsException catch (e) {
      print(
          "HomeTabScreen: FirebaseFunctionsException calling 'generateAiRoutine': ${e.code} - ${e.message}");
      // Provide more user-friendly error messages based on the exception code
      String friendlyMessage =
          "Failed to generate routine: ${e.message ?? e.code}";
      if (e.code == 'aborted') {
        // Often used if the function itself threw an error (e.g., prompt blocked)
        friendlyMessage = "Routine generation failed: ${e.message}";
      } else if (e.code == 'internal') {
        friendlyMessage =
            "An internal error occurred during routine generation. Please try again later.";
      } else if (e.code == 'invalid-argument') {
        friendlyMessage =
            "Invalid data sent for routine generation. Please check your profile information.";
      } else if (e.code == 'unauthenticated') {
        friendlyMessage =
            "Authentication error. Please sign out and sign in again.";
      }
      throw Exception(friendlyMessage); // Propagate the user-friendly error
    } catch (e) {
      print(
          "HomeTabScreen: Generic error calling Cloud Function 'generateAiRoutine': $e");
      throw Exception(
          "An unexpected error occurred while contacting the AI service. Please try again.");
    }
  }

  // Generates a new routine by fetching onboarding data, calling the AI service, and saving to Firestore.
  Future<void> _generateRoutine() async {
    if (_isGeneratingRoutine)
      return; // Prevent multiple simultaneous generations
    if (mounted) setState(() => _isGeneratingRoutine = true);

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(widget.user.uid).get();

      Map<String, dynamic> onboardingData = {};
      Map<String, dynamic>? oldRoutineData;

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        onboardingData =
            (data['onboardingData'] as Map<String, dynamic>?) ?? {};
        oldRoutineData = (data['currentRoutine']
            as Map<String, dynamic>?); // For context to the AI
      }

      if (onboardingData.isEmpty) {
        _showErrorSnackBar(
            "Please complete your preferences in your profile before generating a plan.");
        widget.onNavigateToTab(kProfileTabIndex); // Navigate to profile tab
        // Do not return here if we want to ensure the loader stops in 'finally'
      } else {
        // Proceed only if onboardingData is present
        // CALL THE CLOUD FUNCTION
        final Map<String, dynamic> aiGeneratedParts =
            await _callAiRoutineService(
          userId: widget.user.uid,
          onboardingData: onboardingData,
          previousRoutineData: oldRoutineData,
        );

        // Construct the new routine object for Firestore
        final String newRoutineId = uuid.v4();
        final DateTime now = DateTime.now();
        final int durationInWeeks =
            aiGeneratedParts['durationInWeeks'] as int? ?? 4;
        final DateTime expiresAt = now.add(Duration(days: durationInWeeks * 7));

        // Ensure dailyWorkouts is correctly structured.
        // Assuming the Cloud Function returns Map<String, List<Map<String, dynamic>>> for dailyWorkouts.
        final Map<String, dynamic> newCurrentRoutine = {
          'id': newRoutineId,
          'name': aiGeneratedParts['name'] as String? ?? 'AI Generated Routine',
          'dailyWorkouts': aiGeneratedParts['dailyWorkouts'] ??
              {}, // Directly from Cloud Function
          'durationInWeeks': durationInWeeks,
          'generatedAt': Timestamp.fromDate(now),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'onboardingSnapshot':
              onboardingData, // Snapshot of onboarding data at time of generation
        };

        // Save the new routine to Firestore
        await _firestore.collection('users').doc(widget.user.uid).set(
          {'currentRoutine': newCurrentRoutine},
          SetOptions(merge: true), // Merge to avoid overwriting other user data
        );

        if (mounted) {
          _showSuccessSnackBar("New routine generated successfully!");
        }
      }
    } catch (e) {
      // Catches errors from Firestore, _callAiRoutineService, etc.
      print("HomeTabScreen: Error during routine generation process: $e");
      if (mounted) {
        _showErrorSnackBar(
            e.toString()); // Display the propagated error message
      }
    } finally {
      if (mounted) setState(() => _isGeneratingRoutine = false);
    }
  }

  // Helper to show error SnackBars
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    // Potentially remove "Exception: " prefix from the message for cleaner display
    final displayMessage =
        message.startsWith("Exception: ") ? message.substring(11) : message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(displayMessage,
          style: TextStyle(color: Theme.of(context).colorScheme.onError)),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating, // Consider floating for better UI
    ));
  }

  // Helper to show success SnackBars
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer)),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // Determines the status of the routine (active, expired, invalid).
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
      return (
        statusText: "Plan Finished",
        isExpired: true,
        isValid: true
      ); // Valid structure, but expired
    }

    final Duration difference = expiresAtDate.difference(DateTime.now());
    int weeksRemaining = (difference.inDays / 7).ceil();
    if (weeksRemaining < 0) weeksRemaining = 0;
    // Cap weeks remaining at total duration to avoid display issues if dates are off
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
      padding: const EdgeInsets.fromLTRB(
          16.0, 16.0, 16.0, 8.0), // Adjust bottom padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 12.0, top: 0.0), // Reduced top padding
            child: Center(
                child: Text(
              _isGeneratingRoutine ? "Generating Your Plan..." : "Current Plan",
              style: _isGeneratingRoutine
                  ? textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary) // Style for generating state
                  : textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold), // Style for normal state
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
                          color: colorScheme.primary));
                }
                if (snapshot.hasError) {
                  print(
                      "HomeTabScreen: Error in UserDoc StreamBuilder: ${snapshot.error}");
                  return Center(
                      child: Text(
                    "Error loading your data. Please try again.",
                    style:
                        textTheme.bodyLarge?.copyWith(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ));
                }

                final Map<String, dynamic>? userData = snapshot.data?.data();

                if (!snapshot.hasData ||
                    !snapshot.data!.exists ||
                    userData == null) {
                  // This case might indicate a new user or data issue.
                  return _buildOnboardingPromptUI(
                      context,
                      "Welcome to GymGenius!",
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
                      "Go to Profile");
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
                  // Assume fromMap handles data correctly
                  try {
                    final WeeklyRoutine activeRoutine =
                        WeeklyRoutine.fromMap(currentRoutineData!);
                    return _buildActiveRoutineUI(
                        context, activeRoutine, routineStatusInfo.statusText);
                  } catch (e) {
                    print(
                        "HomeTabScreen: Error converting Firestore Map to WeeklyRoutine: $e. Routine Data: $currentRoutineData");
                    // If conversion fails, display as if the routine is invalid or missing
                    return _buildNoOrExpiredRoutineUI(
                        context,
                        currentRoutineData,
                        false); // Treat as "no valid routine"
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // UI for when a routine is being generated
  Widget _buildGeneratingUI(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: colorScheme.primary),
        const SizedBox(height: 20),
        Text("Hold on, crafting your personalized plan...",
            style: textTheme.titleMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
      ],
    ));
  }

  // UI to prompt user to complete onboarding/profile
  Widget _buildOnboardingPromptUI(
      BuildContext context, String title, String message, String buttonText) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.settings_input_component_outlined,
                size: 64, color: colorScheme.primary.withOpacity(0.8)),
            const SizedBox(height: 20),
            Text(title,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message,
                style: textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: _isGeneratingRoutine
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: colorScheme.onPrimary))
                  : const Icon(Icons.person_search_outlined), // Changed icon
              label: Text(_isGeneratingRoutine ? "Loading..." : buttonText),
              onPressed: _isGeneratingRoutine
                  ? null
                  : () =>
                      widget.onNavigateToTab(kProfileTabIndex), // Use constant
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                textStyle: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold), // Using titleSmall for button
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI for when there's no active routine or an old one has expired
  Widget _buildNoOrExpiredRoutineUI(BuildContext context,
      Map<String, dynamic>? oldRoutineData, bool hadValidPreviousAndExpired) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final String? previousRoutineName =
        (oldRoutineData != null && hadValidPreviousAndExpired)
            ? (oldRoutineData['name'] as String? ?? 'Unnamed Plan')
            : null;

    String title =
        hadValidPreviousAndExpired ? "Plan Finished!" : "No Active Plan";
    String message = hadValidPreviousAndExpired
        ? "Your previous plan '${previousRoutineName ?? 'Unnamed Plan'}' has ended. Ready for a new challenge?"
        : "Let's generate your first personalized AI fitness plan!";
    String buttonText =
        hadValidPreviousAndExpired ? "Generate New Plan" : "Get My First Plan";
    IconData iconData = hadValidPreviousAndExpired
        ? Icons.event_repeat_outlined
        : Icons.auto_awesome_outlined; // Changed icons

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hadValidPreviousAndExpired && previousRoutineName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text("Last Plan: $previousRoutineName",
                style: textTheme.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
          ),
        Card(
            elevation: 3, // Slightly more elevation
            color: colorScheme
                .surfaceContainerHigh, // Use a slightly different surface color for emphasis
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, color: colorScheme.primary, size: 52),
                  const SizedBox(height: 16),
                  Text(title,
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(message,
                      style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    icon: _isGeneratingRoutine
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: colorScheme.onPrimary))
                        : const Icon(Icons.fitness_center), // Changed icon
                    label: Text(
                        _isGeneratingRoutine ? "Generating..." : buttonText),
                    onPressed: _isGeneratingRoutine
                        ? null
                        : _generateRoutine, // Calls the function that calls the Cloud Function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      textStyle: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            )),
      ],
    );
  }

  // UI to display the currently active routine
  Widget _buildActiveRoutineUI(BuildContext context,
      WeeklyRoutine activeRoutine, String routineStatusText) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(bottom: 10.0, top: 4.0), // Adjusted padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  activeRoutine.name,
                  style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600), // Slightly bolder title
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                avatar: Icon(Icons.timer_outlined,
                    size: 18,
                    color: colorScheme.onSecondaryContainer.withOpacity(0.9)),
                label: Text(routineStatusText,
                    style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600)),
                backgroundColor: colorScheme.secondaryContainer
                    .withOpacity(0.8), // Slightly transparent
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                labelPadding: const EdgeInsets.only(
                    left: 2.0, right: 2.0), // Adjusted label padding
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
                margin: const EdgeInsets.symmetric(
                    vertical: 6.0), // Slightly more vertical margin
                elevation: 1.5, // Subtle elevation
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                color: colorScheme.surfaceContainer, // Consistent surface color
                child: InkWell(
                  // Add InkWell for tap feedback
                  onTap: isRestDay
                      ? null
                      : () {
                          if (dayExercises != null && dayExercises.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DailyWorkoutDetailScreen(
                                  dayTitle: "$dayTitle Workout",
                                  exercises:
                                      dayExercises, // Pass the list of RoutineExercise objects
                                ),
                              ),
                            );
                          }
                        },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    // Add padding inside InkWell
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          isRestDay
                              ? Icons.hotel_outlined
                              : Icons.directions_run_outlined, // Changed icons
                          color: isRestDay
                              ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                              : colorScheme.primary,
                          size: 26,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dayTitle,
                                  style: textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                isRestDay
                                    ? "Rest Day"
                                    : "${dayExercises!.length} exercise${dayExercises.length == 1 ? '' : 's'}",
                                style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        if (!isRestDay)
                          Icon(Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurfaceVariant
                                  .withOpacity(0.6)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // No "Generate New Plan" button is shown here if a routine is active and not expired.
        // User would typically go to profile or settings to manage/request a new plan if desired before expiry.
        // Or, you could add a small button/icon for "Request New Plan Early".
        const SizedBox(
            height: 8), // Add a little space at the bottom of the list
        Center(
          child: OutlinedButton.icon(
            icon: Icon(Icons.refresh, size: 18),
            label: Text("Refresh Plan"),
            onPressed: _isGeneratingRoutine ? null : _generateRoutine,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
