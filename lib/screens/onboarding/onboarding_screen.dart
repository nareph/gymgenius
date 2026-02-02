// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/repositories/profile_repository.dart';
import 'package:gymgenius/blocs/onboarding/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/views/question_view.dart';
import 'package:gymgenius/screens/onboarding/views/stats_input_view.dart';
import 'package:gymgenius/viewmodels/onboarding_viewmodel.dart';
import 'package:provider/provider.dart';

/// OnboardingScreen: Guides the user through a series of questions to set up their profile.
///
/// This widget acts as a provider scope for its specific BLoC and ViewModel.
/// It can be used in two contexts:
/// 1. Pre-signup: Gathers initial data before account creation.
/// 2. Post-login: Allows a logged-in user to complete their profile.
class OnboardingScreen extends StatelessWidget {
  final bool isPostLoginCompletion;
  final void Function(Map<String, dynamic>)? onSignUpRequested;

  const OnboardingScreen({
    super.key,
    this.isPostLoginCompletion = false,
    this.onSignUpRequested,
  });

  @override
  Widget build(BuildContext context) {
    // This widget sets up the necessary providers for the OnboardingView.
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: ChangeNotifierProvider(
        create: (context) => OnboardingViewModel(
          isPostLogin: isPostLoginCompletion,
          profileRepository: context.read<ProfileRepository>(),
          onboardingBloc: context.read<OnboardingBloc>(),
          onPreSignupComplete: (answers) {
            // Callback for pre-signup flow
            if (onSignUpRequested != null) {
              onSignUpRequested!(answers);
            }
          },
          onPostLoginComplete: () {
            // Callback for post-login flow: close the screen
            // AuthBloc will handle the navigation through AuthWrapper
            Navigator.of(context).pop();
          },
        ),
        child: const OnboardingView(),
      ),
    );
  }
}

/// The core UI of the onboarding screen, now stateless and driven by the ViewModel.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewModel>();
    final questions = defaultOnboardingQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isPostLogin
            ? "Complete Your Profile"
            : "Your Fitness Profile"),
        automaticallyImplyLeading: viewModel.isPostLogin,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: viewModel.completeOnboarding,
              child: const Text("SKIP"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: viewModel.pageController,
              itemCount: questions.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final currentQuestion = questions[index];
                if (currentQuestion.id == 'physical_stats') {
                  return StatsInputView(
                    question: currentQuestion,
                    onNext: () => viewModel.nextPage(questions.length),
                  );
                } else {
                  return QuestionView(
                    question: currentQuestion,
                    onNext: () => viewModel.nextPage(questions.length),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                questions.length,
                (index) =>
                    _buildDotIndicator(index, viewModel.currentPage, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index, int currentPage, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 10,
      width: currentPage == index ? 28 : 10,
      decoration: BoxDecoration(
        color: currentPage == index
            ? colorScheme.primary
            : colorScheme.onSurface.withAlpha(64),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
