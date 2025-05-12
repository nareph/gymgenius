// lib/screens/onboarding/onboarding_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For saving partial data
import 'package:firebase_auth/firebase_auth.dart'; // For checking current user
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // Uses the centralized model
import 'package:gymgenius/screens/auth/sign_up_screen.dart'; // Imports the Sign UP screen
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/views/question_view.dart'; // Uses the renamed view
import 'package:gymgenius/screens/onboarding/views/stats_input_view.dart'; // Imports the new stats view

class OnboardingScreen extends StatefulWidget {
  // Flag to indicate if this screen is shown after login to complete profile
  final bool isPostLoginCompletion;

  const OnboardingScreen({
    super.key,
    this.isPostLoginCompletion = false, // Default assumes pre-signup flow
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  // Uses the global defaultOnboardingQuestions list
  final List<OnboardingQuestion> _questions = defaultOnboardingQuestions;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      // Listen to page changes to update the current page indicator
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        if (mounted) {
          // Ensure widget is still in the tree
          setState(() {
            _currentPage = page;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handles the action when the user 'Skips' or completes the last question.
  /// Determines the correct navigation based on the context (pre-signup vs post-login).
  void _triggerCompletionOrSkip() {
    final bloc = context.read<OnboardingBloc>();
    // Get the answers collected so far from the BLoC state
    final Map<String, dynamic> currentAnswers = bloc.state.answers;

    if (widget.isPostLoginCompletion) {
      // --- CONTEXT: Logged-in user completing profile ---
      print(
          "OnboardingScreen: Skipping/Completing post-login. Saving data (if any) and navigating to /main_app.");

      // Save any answers collected, even if skipping
      _savePartialOnboardingData(currentAnswers);

      // Navigate directly to the main application dashboard
      // Use pushNamedAndRemoveUntil to clear the onboarding screen from the stack
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main_app', // Route for MainDashboardScreen
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      }
    } else {
      // --- CONTEXT: New user before sign-up ---
      print(
          "OnboardingScreen: Skipping/Completing pre-signup. Triggering BLoC to navigate to SignUp.");

      // Trigger the BLoC event. The BlocListener will handle navigation to SignUpScreen.
      // The BLoC state already holds the answers.
      bloc.add(CompleteOnboarding());
    }
  }

  /// Saves the collected onboarding answers to Firestore for the current user.
  /// Used primarily when a logged-in user skips or finishes completing their profile.
  Future<void> _savePartialOnboardingData(Map<String, dynamic> answers) async {
    // Ensure we only attempt this if the user is logged in (context isPostLoginCompletion is true)
    if (!widget.isPostLoginCompletion) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: _savePartialOnboardingData called but user is null.");
      return; // Should not happen in this context, but safety check
    }
    if (answers.isEmpty) {
      print("Info: _savePartialOnboardingData called but no answers to save.");
      return; // Nothing to save
    }

    try {
      print("Saving onboarding data for logged-in user ${user.uid}: $answers");
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'onboardingData': answers},
        SetOptions(
            merge: true), // Use merge to avoid overwriting other user data
      );
      print("Onboarding data saved successfully for user ${user.uid}.");
    } catch (e) {
      print("Error saving onboarding data for user ${user.uid}: $e");
      // Optionally show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not save profile preferences. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Moves to the next page in the PageView or triggers the completion/skip logic if on the last page.
  void _nextPage() {
    final isLastPage = _currentPage == _questions.length - 1;
    if (!isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      // On the last page, completing it is the same as skipping or finishing
      _triggerCompletionOrSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        // Adjust title based on the context
        title: Text(widget.isPostLoginCompletion
            ? "Complete Your Profile"
            : "Your Fitness Profile"),
        automaticallyImplyLeading: widget
            .isPostLoginCompletion, // Show back button only if completing profile later
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              // Use the unified handler for skip/completion
              onPressed: _triggerCompletionOrSkip,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface.withOpacity(0.8),
                textStyle:
                    textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ).merge(Theme.of(context).textButtonTheme.style),
              child: const Text("SKIP"),
            ),
          ),
        ],
      ),
      // --- Body with BlocListener ---
      body: BlocListener<OnboardingBloc, OnboardingState>(
        // This listener now ONLY handles navigation for the PRE-SIGNUP flow
        listener: (context, state) {
          // Navigate to SignUpScreen ONLY if it's NOT the post-login completion flow
          // AND the onboarding status is complete in the BLoC.
          if (!widget.isPostLoginCompletion &&
              state.status == OnboardingStatus.complete) {
            print("BlocListener: Navigating to SignUpScreen (New user flow).");
            Navigator.pushReplacement(
              // Use pushReplacement to prevent back navigation
              context,
              MaterialPageRoute(
                // Pass collected answers to SignUpScreen
                builder: (_) => SignUpScreen(onboardingData: state.answers),
              ),
            );
          } else if (widget.isPostLoginCompletion &&
              state.status == OnboardingStatus.complete) {
            // For post-login flow, navigation is handled directly in _triggerCompletionOrSkip
            print(
                "BlocListener: State complete, but navigation handled by _triggerCompletionOrSkip (Post-login flow). No navigation needed here.");
          }
        },
        child: Column(
          children: [
            // --- PageView for Questions ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _questions.length,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable manual swipe
                itemBuilder: (context, index) {
                  final currentQuestion = _questions[index];
                  // Select the appropriate view based on question type
                  switch (currentQuestion.type) {
                    case QuestionType.singleChoice:
                    case QuestionType.multipleChoice:
                      return QuestionView(
                        question: currentQuestion,
                        // Pass the unified next page handler
                        onNext: _nextPage,
                      );
                    case QuestionType.numericInput:
                      return StatsInputView(
                        question: currentQuestion,
                        // Pass the unified next page handler
                        onNext: _nextPage,
                      );
                  }
                },
              ),
            ),

            // --- Page Indicator ---
            Padding(
              padding: const EdgeInsets.only(bottom: 35.0, top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _questions.length,
                  (index) => _buildDotIndicator(index, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget for the Page Indicator Dot (uses AppTheme) ---
  Widget _buildDotIndicator(int index, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 10, // Dot height
      width: _currentPage == index ? 28 : 10, // Active dot is wider
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary // Theme's primary color for active dot
            : colorScheme.onSurface
                .withOpacity(0.25), // Muted color for inactive dots
        borderRadius: BorderRadius.circular(5), // Rounded corners for dots
      ),
    );
  }
}
