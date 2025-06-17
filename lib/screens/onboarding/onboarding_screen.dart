import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/repositories/profile_repository.dart';
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/screens/main_dashboard_screen.dart';
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

  const OnboardingScreen({
    super.key,
    this.isPostLoginCompletion = false,
  });

  /// Static method to create a route that provides all necessary dependencies
  /// for the post-login completion flow. This is called by the AuthWrapper.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) {
        // We wrap the screen with its required providers.
        // OnboardingScreen itself handles providing these, so we just instantiate it.
        return const OnboardingScreen(isPostLoginCompletion: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget now sets up the necessary providers for the OnboardingView.
    // This keeps the dependency setup logic encapsulated within the feature itself.
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: ChangeNotifierProvider(
        create: (context) => OnboardingViewModel(
          isPostLogin: isPostLoginCompletion,
          profileRepository: context.read<ProfileRepository>(),
          onboardingBloc: context.read<OnboardingBloc>(),
          onPreSignupComplete: (answers) {
            // Callback for pre-signup flow: navigates to the SignUp screen.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => SignUpScreen(onboardingData: answers)),
            );
          },
          onPostLoginComplete: () {
            // Callback for post-login flow: navigates to the main dashboard.
            // This is the manual but pragmatic solution for this specific flow.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
              (route) => false,
            );
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
