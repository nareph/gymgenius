// lib/screens/onboarding/onboarding_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding.dart'; // Pour OnboardingData et PhysicalStats
import 'package:gymgenius/models/onboarding_question.dart'; // Pour OnboardingQuestion et defaultOnboardingQuestions
import 'package:gymgenius/screens/auth/sign_up_screen.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // Pour OnboardingBloc, OnboardingState, etc.
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
  // Utiliser la liste de questions définie dans onboarding_question.dart
  final List<OnboardingQuestion> _questions = defaultOnboardingQuestions;
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
    // Optionnel: si vous voulez charger des données existantes pour isPostLoginCompletion
    // if (widget.isPostLoginCompletion) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       final user = FirebaseAuth.instance.currentUser;
    //       if (user != null) {
    //         context.read<OnboardingBloc>().add(LoadExistingAnswers(userId: user.uid));
    //       }
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _triggerCompletionOrSkip() {
    final bloc = context.read<OnboardingBloc>();
    // Obtenir les réponses actuelles du BLoC.
    // Si l'utilisateur skippe sans répondre, currentAnswersFromBloc sera vide (ou ce qu'il y avait avant).
    final Map<String, dynamic> currentAnswersFromBloc = bloc.state.answers;

    if (widget.isPostLoginCompletion) {
      print(
          "OnboardingScreen: Completing/Skipping post-login. Answers from BLoC: $currentAnswersFromBloc. Saving data and navigating to /main_app.");
      // _saveOnboardingDataForLoggedInUser utilisera currentAnswersFromBloc.
      // Si currentAnswersFromBloc est vide (skip total), _saveOnboardingDataForLoggedInUser
      // créera un OnboardingData(completed: true).
      // Si des réponses existent, elles seront utilisées.
      _saveOnboardingDataForLoggedInUser(currentAnswersFromBloc);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main_app',
          (Route<dynamic> route) => false,
        );
      }
    } else {
      // Flux de pré-inscription: Déclencher l'événement CompleteOnboarding.
      // Le BLoC ajoutera 'completed': true aux réponses actuelles (state.answers).
      // Le BlocListener naviguera ensuite vers SignUpScreen avec ces réponses mises à jour.
      print(
          "OnboardingScreen: Completing/Skipping pre-signup. Triggering BLoC CompleteOnboarding. Current answers in BLoC: ${bloc.state.answers}");
      bloc.add(CompleteOnboarding());
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

    // Si answersMap est vide (l'utilisateur a "skippé" sans rien sélectionner)
    // ou ne contient pas les champs essentiels, nous sauvegardons un OnboardingData
    // marqué comme 'completed' mais avec des champs de données potentiellement vides/null.
    if (answersMap.isEmpty) {
      print(
          "Info: _saveOnboardingDataForLoggedInUser received empty answersMap (likely a full skip). Marking as completed.");
      dataToSave = OnboardingData(completed: true);
    } else {
      // Transformer le answersMap (venant du BLoC, qui devrait inclure 'completed': true si _triggerCompletionOrSkip
      // a appelé CompleteOnboarding et que ce n'est pas le flux post-login)
      // en un objet OnboardingData.
      // Pour le flux post-login, 'completed' sera explicitement mis à true ci-dessous.

      PhysicalStats? physicalStats;
      if (answersMap.containsKey('physical_stats') &&
          answersMap['physical_stats'] is Map) {
        final statsMap = answersMap['physical_stats'] as Map<String, dynamic>;
        // Utiliser les clés du modèle PhysicalStats
        physicalStats = PhysicalStats(
          age: (statsMap['age'] as num?)?.toInt(),
          weightKg: (statsMap['weight_kg'] as num?)?.toDouble(),
          heightM: (statsMap['height_m'] as num?)?.toDouble(),
          targetWeightKg: (statsMap['target_weight_kg'] as num?)?.toDouble(),
        );
      }

      dataToSave = OnboardingData(
        goal: answersMap['goal'] as String?,
        gender: answersMap['gender'] as String?,
        experience: answersMap['experience'] as String?,
        frequency: answersMap['frequency'] as String?,
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
            true, // Toujours marquer comme 'completed' ici pour le flux post-login
      );
    }

    try {
      print(
          "OnboardingScreen: Saving OnboardingData for logged-in user ${user.uid}: ${dataToSave.toMap()}");
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'onboardingData':
              dataToSave.toMap(), // Contient son propre 'completed: true'
          'onboardingCompleted':
              true, // Drapeau de haut niveau pour AuthWrapper
          'profileLastUpdatedAt': FieldValue.serverTimestamp(), // Optionnel
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
      // L'utilisateur a répondu à la dernière question, considérer comme complété
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
        automaticallyImplyLeading:
            widget.isPostLoginCompletion, // Bouton retour si post-login
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed:
                  _triggerCompletionOrSkip, // Gère le skip pour les deux flux
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
          // Gère la navigation pour le flux de pré-inscription
          if (!widget.isPostLoginCompletion &&
              state.status == OnboardingStatus.complete) {
            // state.answers devrait maintenant inclure 'completed': true grâce au BLoC
            print(
                "BlocListener (Pre-SignUp): Navigating to SignUpScreen with answers: ${state.answers}.");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SignUpScreen(onboardingData: state.answers),
              ),
            );
          }
          // Pour le flux post-login, la navigation est gérée par _triggerCompletionOrSkip directement.
          // On pourrait ajouter un log ici si nécessaire.
          // else if (widget.isPostLoginCompletion && state.status == OnboardingStatus.complete) {
          //   print("BlocListener (Post-Login): Onboarding complete status received. Navigation handled by _triggerCompletionOrSkip.");
          // }
        },
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _questions.length,
                physics:
                    const NeverScrollableScrollPhysics(), // Empêcher le swipe manuel
                itemBuilder: (context, index) {
                  final currentQuestion = _questions[index];
                  // Passer le BLoC aux vues enfants si elles en ont besoin directement,
                  // mais il est généralement préférable qu'elles utilisent context.read<OnboardingBloc>()
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
            // Indicateurs de page
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
