import 'package:flutter/material.dart';
import 'package:gymgenius/repositories/profile_repository.dart';
import 'package:gymgenius/blocs/onboarding/onboarding_bloc.dart';
import 'package:gymgenius/services/logger_service.dart';

class OnboardingViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final OnboardingBloc _onboardingBloc;
  final bool isPostLogin;
  final Function(Map<String, dynamic>) onPreSignupComplete;
  final VoidCallback onPostLoginComplete;

  final PageController pageController = PageController();
  int _currentPage = 0;
  int get currentPage => _currentPage;

  OnboardingViewModel({
    required this.isPostLogin,
    required ProfileRepository profileRepository,
    required OnboardingBloc onboardingBloc,
    required this.onPreSignupComplete,
    required this.onPostLoginComplete,
  })  : _profileRepository = profileRepository,
        _onboardingBloc = onboardingBloc {
    pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Called when the user presses 'NEXT' on the last page or 'SKIP'.
  Future<void> completeOnboarding() async {
    final answers = _onboardingBloc.state.answers;
    
    if (isPostLogin) {
      Log.debug("OnboardingViewModel: Completing post-login onboarding...");
      try {
        await _profileRepository.updateOnboardingData(answers);
        Log.debug("OnboardingViewModel: Data saved. Triggering completion callback.");
        onPostLoginComplete();
      } catch (e) {
        Log.error("OnboardingViewModel: Failed to save post-login data", error: e);
        // Optionally show an error to the user.
      }
    } else {
      Log.debug("OnboardingViewModel: Completing pre-signup onboarding...");
      onPreSignupComplete(answers);
    }
  }

  /// Moves to the next page in the PageView.
  void nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      // If on the last page, trigger completion.
      completeOnboarding();
    }
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }
}