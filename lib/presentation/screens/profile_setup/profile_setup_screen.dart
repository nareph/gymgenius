import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gymgenius/di/injection.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/repositories/auth_repository.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/presentation/blocs/auth/auth_bloc.dart';
import 'package:gymgenius/presentation/blocs/profile_setup/profile_setup_bloc.dart';
import 'package:gymgenius/presentation/mappers/profile_completeness.dart';
import 'package:gymgenius/presentation/question/profile_questions.dart';
import 'package:gymgenius/presentation/screens/profile_setup/views/profile_summary_view.dart';
import 'package:gymgenius/presentation/screens/profile_setup/views/question_view.dart';
import 'package:gymgenius/presentation/screens/profile_setup/views/stats_input_view.dart';

class ProfileSetupScreen extends StatelessWidget {
  final bool isPostLogin;
  final void Function(HealthProfile)? onProfileComplete;
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
        healthRepository: getIt<HealthRepository>(),
        authRepository: getIt<AuthRepository>(),
        initialAnswers: null, // Could be pre-filled if editing later
      ),
      child: BlocListener<ProfileSetupBloc, ProfileSetupState>(
        listener: (context, state) {
          if (state.status == ProfileSetupStatus.complete) {
            // For post‑login flow, refresh auth state and close the screen.
            if (isPostLogin) {
              context.read<AuthBloc>().add(const AuthStateCheckRequested());
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            } else if (onProfileComplete != null && state.profile != null) {
              // For pre‑signup flow (if any), invoke the callback.
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

// ---------------------------------------------------------------------
// The UI part remains unchanged, but we keep it here for completeness.
// ---------------------------------------------------------------------

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

  int get _totalPages => _questions.length + 1;

  @override
  void initState() {
    super.initState();

    final missing = widget.missingFieldIds;
    if (missing != null && missing.isNotEmpty) {
      final filtered = ProfileCompleteness.filterQuestionsById(
          defaultProfileQuestions, missing);
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
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToQuestion(int questionIndex) {
    _pageController.animateToPage(
      questionIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPostLogin = widget.isPostLogin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPostLogin ? "Complete Your Profile" : "Your Fitness Profile",
        ),
        automaticallyImplyLeading: isPostLogin,
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
              children: [
                ..._questions.map((question) {
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
                }),
                ProfileSummaryView(
                  questions: _questions,
                  isPostLogin: isPostLogin,
                  onEditQuestion: _goToQuestion,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
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
