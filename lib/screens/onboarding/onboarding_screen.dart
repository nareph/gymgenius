// lib/screens/onboarding/onboarding_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/views/question_view.dart';
import 'package:gymgenius/screens/onboarding/views/stats_input_view.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isPostLoginCompletion;

  const OnboardingScreen({
    super.key,
    this.isPostLoginCompletion = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<OnboardingQuestion> _questions =
      defaultOnboardingQuestions; // Utilise la liste mise à jour
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        if (mounted) {
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

  void _triggerCompletionOrSkip() {
    final bloc = context.read<OnboardingBloc>();
    final Map<String, dynamic> currentAnswersFromBloc = bloc.state.answers;

    if (widget.isPostLoginCompletion) {
      print(
          "OnboardingScreen: Completing/Skipping post-login. Saving data and navigating to /main_app.");
      _saveOnboardingDataForLoggedInUser(
          currentAnswersFromBloc); // Le BLoC n'est pas impliqué dans la sauvegarde ici

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main_app',
          (Route<dynamic> route) => false,
        );
      }
    } else {
      print(
          "OnboardingScreen: Completing/Skipping pre-signup. Triggering BLoC CompleteOnboarding.");
      bloc.add(
          CompleteOnboarding()); // Le BlocListener s'occupera de la navigation vers SignUpScreen
    }
  }

  Future<void> _saveOnboardingDataForLoggedInUser(
      Map<String, dynamic> answersMap) async {
    if (!widget.isPostLoginCompletion) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print(
          "Error: _saveOnboardingDataForLoggedInUser called but user is null.");
      return;
    }

    OnboardingData dataToSave;

    if (answersMap.isEmpty && !widget.isPostLoginCompletion) {
      // Si pré-signup et skip total
      dataToSave = OnboardingData(
          completed:
              true); // 'completed' sera mis à true par le BLoC pour pré-signup
    } else {
      PhysicalStats? physicalStats;
      if (answersMap.containsKey('physical_stats') &&
          answersMap['physical_stats'] is Map) {
        final statsMap = answersMap['physical_stats'] as Map<String, dynamic>;
        physicalStats =
            PhysicalStats.fromMap(statsMap); // Utilisation de fromMap
      }

      dataToSave = OnboardingData(
        goal: answersMap['goal'] as String?,
        gender: answersMap['gender'] as String?,
        experience: answersMap['experience'] as String?,
        frequency: answersMap['frequency'] as String?,
        sessionDurationPreference:
            answersMap['session_duration_minutes'] as String?, // <<--- AJOUTÉ
        workoutDays: answersMap['workout_days'] != null
            ? List<String>.from(answersMap['workout_days'])
            : null,
        equipment: answersMap['equipment'] != null
            ? List<String>.from(answersMap['equipment'])
            : null,
        focusAreas: answersMap['focus_areas'] != null
            ? List<String>.from(answersMap['focus_areas'])
            : null,
        physicalStats: physicalStats,
        completed:
            true, // Pour le flux post-login, on marque toujours comme complété ici
      );
    }

    try {
      print(
          "OnboardingScreen: Saving OnboardingData for logged-in user ${user.uid}: ${dataToSave.toMap()}");
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'onboardingData': dataToSave.toMap(),
          'onboardingCompleted': true,
          'profileLastUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      print(
          "OnboardingScreen: OnboardingData saved successfully for user ${user.uid}.");
    } catch (e) {
      print(
          "OnboardingScreen: Error saving OnboardingData for user ${user.uid}: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not save profile preferences. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _nextPage() {
    final isLastQuestionPage = _currentPage == _questions.length - 1;
    if (!isLastQuestionPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _triggerCompletionOrSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPostLoginCompletion
            ? "Complete Your Profile"
            : "Your Fitness Profile"),
        automaticallyImplyLeading: widget.isPostLoginCompletion,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _triggerCompletionOrSkip,
              style: TextButton.styleFrom(
                foregroundColor:
                    colorScheme.onSurface.withAlpha((0.8 * 255).round()),
                textStyle:
                    textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ).merge(Theme.of(context).textButtonTheme.style),
              child: const Text("SKIP"),
            ),
          ),
        ],
      ),
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (!widget.isPostLoginCompletion &&
              state.status == OnboardingStatus.complete) {
            print(
                "BlocListener (Pre-SignUp): Navigating to SignUpScreen with answers: ${state.answers}.");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SignUpScreen(onboardingData: state.answers),
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _questions.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final currentQuestion = _questions[index];
                  if (currentQuestion.type == QuestionType.numericInput &&
                      currentQuestion.id == 'physical_stats') {
                    return StatsInputView(
                      question: currentQuestion,
                      onNext: _nextPage,
                    );
                  } else {
                    return QuestionView(
                      question: currentQuestion,
                      onNext: _nextPage,
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

  Widget _buildDotIndicator(int index, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 10,
      width: _currentPage == index ? 28 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary
            : colorScheme.onSurface.withAlpha((0.25 * 255).round()),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
