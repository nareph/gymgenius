import 'package:flutter/material.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/presentation/mappers/profile_setup_mapper.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/presentation/blocs/profile_setup/profile_setup_bloc.dart';

/// ViewModel for the Profile Setup screen.
///
/// Coordinates between the UI, the ProfileSetupBloc, and the HealthRepository.
class ProfileSetupViewModel extends ChangeNotifier {
  final HealthRepository? _healthRepository;
  final ProfileSetupBloc _profileSetupBloc;
  final bool isPostLogin;
  final void Function(HealthProfile) onPreSignupComplete;
  final VoidCallback onPostLoginComplete;

  final PageController pageController = PageController();
  int _currentPage = 0;

  int get currentPage => _currentPage;

  ProfileSetupViewModel({
    required this.isPostLogin,
    HealthRepository? healthRepository,
    required ProfileSetupBloc profileSetupBloc,
    required this.onPreSignupComplete,
    required this.onPostLoginComplete,
  })  : _healthRepository = healthRepository,
        _profileSetupBloc = profileSetupBloc {
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
  Future<void> completeProfileSetup() async {
    final answers = _profileSetupBloc.state.answers;

    Log.debug("ProfileSetupViewModel: Completing profile setup");
    Log.debug("  - Mode: ${isPostLogin ? 'POST-LOGIN' : 'PRE-SIGNUP'}");
    Log.debug("  - Answers: $answers");

    if (isPostLogin) {
      Log.debug("ProfileSetupViewModel: Saving profile for existing user...");
      try {
        // Build HealthProfile from answers
        final profile = ProfileSetupMapper.toDomain(answers);
        // The userId will be set by the repository; we pass an empty string.
        // The healthRepository should get the current user id.
        await _healthRepository?.saveHealthProfile(profile);
        Log.debug("ProfileSetupViewModel: Profile saved successfully");
        onPostLoginComplete();
      } catch (e, s) {
        Log.error("ProfileSetupViewModel: Failed to save profile",
            error: e, stackTrace: s);
        // You could emit an error state; for now, rethrow or handle in UI.
        rethrow;
      }
    } else {
      Log.debug("ProfileSetupViewModel: Passing profile to signup...");
      // Build HealthProfile and pass it to the signup callback
      final profile = ProfileSetupMapper.toDomain(answers);
      onPreSignupComplete(profile);
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
      completeProfileSetup();
    }
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }
}
