import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/presentation/blocs/profile_setup/profile_setup_bloc.dart';
import 'package:gymgenius/presentation/mappers/profile_completeness.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';
import 'package:gymgenius/presentation/screens/profile_setup/views/question_view.dart';
import 'package:gymgenius/presentation/screens/profile_setup/views/stats_input_view.dart';

class ProfileSetupScreen extends StatelessWidget {
  final bool isPostLogin;
  final void Function(HealthProfile)? onProfileComplete;

  /// Required question ids still missing (from `HealthProfile.missingFieldIds`,
  /// via AuthBloc). When provided and non-empty, only these questions are
  /// shown — not the whole questionnaire again.
  final List<String>? missingFieldIds;

  const ProfileSetupScreen({
    super.key,
    this.isPostLogin = false,
    this.onProfileComplete,
    this.missingFieldIds,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileSetupBloc(
        healthRepository: isPostLogin ? getIt<HealthRepository>() : null,
      ),
      child: BlocListener<ProfileSetupBloc, ProfileSetupState>(
        listener: (context, state) {
          if (state.status == ProfileSetupStatus.complete) {
            if (isPostLogin) {
              Navigator.of(context).pop();
            } else if (onProfileComplete != null && state.profile != null) {
              onProfileComplete!(state.profile!);
            }
          }
          if (state.status == ProfileSetupStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error saving profile'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: _ProfileSetupView(
          isPostLogin: isPostLogin,
          missingFieldIds: missingFieldIds,
        ),
      ),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  final bool isPostLogin;
  final List<String>? missingFieldIds;

  const _ProfileSetupView({
    required this.isPostLogin,
    this.missingFieldIds,
  });

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final List<ProfileQuestion> _questions;

  @override
  void initState() {
    super.initState();

    final missing = widget.missingFieldIds;
    if (missing != null && missing.isNotEmpty) {
      final filtered = ProfileCompleteness.filterQuestionsById(
          defaultProfileQuestions, missing);
      // Safety net: if the filter yields nothing (shouldn't normally
      // happen if the caller routed here correctly), fall back to the
      // full list rather than showing an empty PageView.
      _questions = filtered.isNotEmpty ? filtered : defaultProfileQuestions;
    } else {
      _questions = defaultProfileQuestions;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<ProfileSetupBloc>().add(
            CompleteProfileSetup(isPostLogin: widget.isPostLogin),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPostLogin = widget.isPostLogin;
    final isResuming =
        widget.missingFieldIds != null && widget.missingFieldIds!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPostLogin ? "Complete Your Profile" : "Your Fitness Profile",
        ),
        automaticallyImplyLeading: isPostLogin,
        actions: [
          // SKIP is only offered on first-time onboarding, never when
          // resuming a profile the app has flagged as incomplete.
          if (!isPostLogin && !isResuming)
            TextButton(
              onPressed: () {
                context.read<ProfileSetupBloc>().add(
                      CompleteProfileSetup(isPostLogin: false),
                    );
              },
              child: const Text("SKIP"),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              physics: const NeverScrollableScrollPhysics(),
              children: _questions.map((question) {
                if (question.id == 'physical_stats') {
                  return StatsInputView(
                    question: question,
                    onNext: _nextPage,
                  );
                }
                return QuestionView(
                  question: question,
                  onNext: _nextPage,
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _questions.length,
                (index) => _buildDotIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 10,
      width: _currentPage == index ? 28 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary
            : colorScheme.onSurface.withAlpha(64),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
