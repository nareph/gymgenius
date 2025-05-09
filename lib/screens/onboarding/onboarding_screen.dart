// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // Uses the centralized model
import 'package:gymgenius/screens/auth/signin_screen.dart'; // Imports the Sign In screen
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/views/question_view.dart'; // Uses the renamed view
import 'package:gymgenius/screens/onboarding/views/stats_input_view.dart'; // Imports the new stats view
// Consider using a package like smooth_page_indicator for a more polished page indicator,
// or keep the simple dots as implemented.

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

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

  // Triggers the completion of the onboarding process via the BLoC
  void _triggerCompletion() {
    // Removed context as it's available via `this.context`
    context.read<OnboardingBloc>().add(CompleteOnboarding());
  }

  // Moves to the next page in the PageView or triggers completion if on the last page
  void _nextPage() {
    final isLastPage = _currentPage == _questions.length - 1;
    if (!isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350), // Animation duration
        curve: Curves.easeOutCubic, // Animation curve
      );
    } else {
      _triggerCompletion(); // Trigger completion on the last page
    }
  }

  @override
  Widget build(BuildContext context) {
    // The BlocProvider is typically provided when navigating TO this screen,
    // so no need to wrap another one here if it's already an ancestor.

    // Access theme for indicator colors and text styles
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // --- AppBar ---
      // Styling (backgroundColor, titleTextStyle, iconTheme, elevation)
      // comes automatically from AppBarTheme in AppTheme.
      appBar: AppBar(
        // Title style is taken from AppBarTheme.titleTextStyle
        title: const Text("Your Fitness Profile"), // Or "Complete Your Profile"
        // --- Skip Button ---
        actions: [
          // Simplified version without explicit Builder, using the build context directly.
          Padding(
            padding: const EdgeInsets.only(
                right: 8.0), // Add some padding for aesthetics
            child: TextButton(
              onPressed:
                  _triggerCompletion, // Calls the method to complete onboarding
              // Style comes from TextButtonThemeData.
              // To use a different color (e.g., less vibrant), override here:
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface
                    .withOpacity(0.8), // Less vibrant than primary
                textStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600), // Adjusted text style
              ).merge(Theme.of(context)
                  .textButtonTheme
                  .style), // Merge with theme for consistency
              child: const Text("SKIP"),
            ),
          ),
        ],
      ),
      // The Scaffold's background color is defined by scaffoldBackgroundColor in AppTheme.

      // --- Body with BlocListener for navigation ---
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          // Navigate to SignInScreen when onboarding is complete
          if (state.status == OnboardingStatus.complete) {
            Navigator.pushReplacement(
              // Use pushReplacement to prevent going back to onboarding
              context,
              MaterialPageRoute(
                // Pass the collected onboarding answers to the SignInScreen
                builder: (_) => SignInScreen(onboardingData: state.answers),
              ),
            );
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
                        onNext: _nextPage,
                      );
                    case QuestionType.numericInput:
                      // This view is specifically for questions with id "physical_stats"
                      // or any other question of type numericInput.
                      return StatsInputView(
                        question: currentQuestion,
                        onNext: _nextPage,
                      );
                    // default: // Should not happen if all question types are handled
                    //   return const Center(child: Text("Unknown question type"));
                  }
                },
              ),
            ),

            // --- Page Indicator ---
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 35.0, top: 20.0), // Adjusted padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _questions.length,
                  // Uses the helper function _buildDot which now uses theme colors
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
    // Access theme colors
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(
          milliseconds: 250), // Animation duration for dot transition
      margin: const EdgeInsets.symmetric(horizontal: 4.0), // Adjusted margin
      height: 10, // Dot height
      width: _currentPage == index ? 28 : 10, // Active dot is wider
      decoration: BoxDecoration(
        // Use secondary color (or primary) for the active dot
        // and a muted color (or surface+opacity) for inactive ones.
        color: _currentPage == index
            ? colorScheme.primary // Theme's primary color for active dot
            : colorScheme.onSurface
                .withOpacity(0.25), // Muted color for inactive dots
        borderRadius: BorderRadius.circular(5), // Rounded corners for dots
      ),
    );
  }
}
