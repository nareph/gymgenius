// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // Utilise le modèle centralisé
import 'package:gymgenius/screens/auth/signin_screen.dart'; // Importe l'écran Sign In
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:gymgenius/screens/onboarding/views/question_view.dart'; // Utilise la vue renommée
import 'package:gymgenius/screens/onboarding/views/stats_input_view.dart'; // Importe la nouvelle vue
// Vous pouvez utiliser un package comme smooth_page_indicator ou garder les points simples

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<OnboardingQuestion> questions = defaultOnboardingQuestions;
  int _currentPage = 0;

  // initState et dispose restent inchangés
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // _triggerCompletion et _nextPage restent inchangés
  void _triggerCompletion(BuildContext context) {
    context.read<OnboardingBloc>().add(CompleteOnboarding());
  }

  void _nextPage() {
    final isLastPage = _currentPage == questions.length - 1;
    if (!isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _triggerCompletion(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le BlocProvider est fourni LORS DE LA NAVIGATION vers cet écran,
    // donc pas besoin d'en remettre un ici.

    // Accès au thème pour les couleurs de l'indicateur
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // --- AppBar ---
      // Le style (backgroundColor, titleTextStyle, iconTheme, elevation)
      // vient automatiquement de AppBarTheme dans AppTheme
      appBar: AppBar(
        // Le style du titre est pris de AppBarTheme.titleTextStyle
        title: const Text("Your Fitness Profile"),
        // --- Bouton Skip ---
        actions: [
          // Le Builder n'est plus strictement nécessaire car le contexte de build
          // est maintenant sous le BlocProvider fourni lors de la navigation.
          // Mais on peut le garder pour la clarté ou l'enlever.
          // Builder(builder: (buttonContext) { // Peut utiliser 'context' directement
          //   return TextButton(
          //     onPressed: () => _triggerCompletion(context), // Utilise le context de build
          //     // Le style du TextButton vient du thème
          //     // Si on veut une couleur spécifique pour "SKIP"
          //     child: Text(
          //       "SKIP",
          //       style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
          //       // Ou utiliser directement le style du thème TextButton
          //       // style: Theme.of(context).textButtonTheme.style?.textStyle?.copyWith(color: ...)
          //     ),
          //   );
          // }),
          // Version simplifiée sans Builder, si le contexte fonctionne
          Padding(
            // Ajoute un peu de padding pour l'esthétique
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () => _triggerCompletion(context),
              // Style vient du thème TextButtonThemeData
              // Pour une couleur différente (ex: moins vive), on surcharge:
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface
                    .withOpacity(0.7), // Moins vif que l'orange
                textStyle: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold), // Style texte adapté
              ).merge(Theme.of(context)
                  .textButtonTheme
                  .style), // Fusionne avec le thème
              child: const Text("SKIP"),
            ),
          ),
        ],
      ),
      // Le fond du Scaffold est défini par scaffoldBackgroundColor dans AppTheme

      // --- Body avec BlocListener ---
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.complete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SignInScreen(onboardingData: state.answers),
              ),
            );
          }
        },
        child: Column(
          children: [
            // --- PageView ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final currentQuestion = questions[index];
                  // Sélectionne la vue appropriée (pas de changement de style ici)
                  switch (currentQuestion.type) {
                    case QuestionType.singleChoice:
                    case QuestionType.multipleChoice:
                      return QuestionView(
                        question: currentQuestion,
                        onNext: _nextPage,
                      );
                    case QuestionType.numericInput:
                      return StatsInputView(
                        question: currentQuestion,
                        onNext: _nextPage,
                      );
                  }
                },
              ),
            ),

            // --- Indicateur de Page ---
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  questions.length,
                  // Utilise la fonction helper buildDot qui utilise maintenant les couleurs du thème
                  (index) => buildDot(index, context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget pour l'indicateur de page (utilise AppTheme) ---
  Widget buildDot(int index, BuildContext context) {
    // Accède aux couleurs du thème
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        // Utilise la couleur secondaire (orange) pour le point actif
        // et une couleur grise (ou surface+opacité) pour les inactifs
        color: _currentPage == index
            ? colorScheme.secondary // Couleur active du thème
            : colorScheme.onSurface
                .withOpacity(0.3), // Couleur inactive (ajuster l'opacité)
        // : Colors.grey.shade600, // Alternative grise si préférée
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
