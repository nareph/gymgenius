// lib/screens/onboarding/views/question_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart'; // Assurez-vous que ce chemin est correct
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart'; // Assurez-vous que ce chemin est correct

class QuestionView extends StatefulWidget {
  final OnboardingQuestion question;
  final VoidCallback onNext;

  const QuestionView({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  Set<String> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    // Utilise WidgetsBinding pour s'assurer que le contexte est disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Vérifie si le widget est toujours monté
        _loadInitialState();
      }
    });
  }

  void _loadInitialState() {
    // Accéder au Bloc est sûr ici car appelé après la construction initiale
    final bloc = context.read<OnboardingBloc>();
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (widget.question.type == QuestionType.multipleChoice &&
        existingAnswer is List) {
      setState(() {
        _selectedValues = Set<String>.from(existingAnswer.whereType<String>());
      });
    } else if (widget.question.type == QuestionType.singleChoice &&
        existingAnswer is String) {
      // Rien à pré-remplir visuellement pour l'instant pour le choix unique
    }
  }

  void _handleSingleChoiceSelection(String selectedValue) {
    context.read<OnboardingBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue: selectedValue,
          ),
        );
    widget.onNext();
  }

  void _handleMultiChoiceSelection(String value, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedValues.add(value);
      } else {
        _selectedValues.remove(value);
      }
    });
    context.read<OnboardingBloc>().add(
          UpdateAnswer(
            questionId: widget.question.id,
            answerValue: _selectedValues.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Accès au thème et aux dimensions
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Le fond est maintenant géré par l'écran parent (OnboardingScreen)
    // ou le thème global. Plus besoin de Container de fond ici.
    // return Container(
    //   decoration: BoxDecoration( ... gradient ... ),
    //   child: Padding(...)
    // );

    // Padding général pour le contenu de la vue
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08, vertical: screenHeight * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Texte de la Question ---
          Text(
            widget.question.text,
            textAlign: TextAlign.center,
            // Utilise le style 'headlineMedium' du thème
            style: textTheme.headlineMedium,
          ),
          SizedBox(height: screenHeight * 0.06),

          // --- Options de Réponse (Affichage conditionnel) ---
          if (widget.question.type == QuestionType.singleChoice)
            // --- CAS : Choix Unique ---
            ...widget.question.options.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _handleSingleChoiceSelection(option.value),
                    // Le style vient automatiquement du thème ElevatedButtonThemeData
                    // Si vous vouliez un style *différent* du bouton principal orange
                    // (ex: un fond moins vif), vous styleriez ici. Sinon, laissez vide.
                    // style: ElevatedButton.styleFrom(
                    //   backgroundColor: Colors.blue.shade600, // Exemple de dérogation
                    //   foregroundColor: Colors.white,
                    // ),
                    // Le style de texte est pris de ElevatedButtonThemeData.textStyle (labelLarge)
                    child: Text(option.text),
                  ),
                ))
          else if (widget.question.type == QuestionType.multipleChoice)
            // --- CAS : Choix Multiple (Cercles/Tags) ---
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: widget.question.options.map((option) {
                final bool isSelected = _selectedValues.contains(option.value);

                return GestureDetector(
                  onTap: () =>
                      _handleMultiChoiceSelection(option.value, !isSelected),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 10.0), // Ajusté
                    constraints: const BoxConstraints(minWidth: 60), // Ajusté
                    decoration: BoxDecoration(
                      // Utilise les couleurs du thème
                      color: isSelected
                          ? colorScheme.secondary.withOpacity(
                              0.9) // Couleur secondaire si sélectionné
                          : colorScheme.surface.withOpacity(
                              0.5), // Couleur surface (plus sombre) si non sélectionné
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.secondary
                            : Colors
                                .white54, // Bordure secondaire si sélectionné
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      option.text,
                      textAlign: TextAlign.center,
                      // Utilise 'labelSmall' du thème, ajuste la couleur/graisse selon sélection
                      style: textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colorScheme
                                .onSecondary // Texte sur couleur secondaire (noir ?)
                            : colorScheme.onSurface
                                .withOpacity(0.9), // Texte sur couleur surface
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ), // Fin du Wrap

          // --- Bouton "Next" ---
          if (widget.question.type == QuestionType.multipleChoice) ...[
            SizedBox(height: screenHeight * 0.05),
            ElevatedButton(
              onPressed: _selectedValues.isNotEmpty ? widget.onNext : null,
              // Style spécifique VERT pour ce bouton "Next" (dérogation au thème)
              // Si vous voulez qu'il soit orange comme les autres, supprimez ce style.
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700, // Vert spécifique
                foregroundColor: Colors.white, // Texte blanc
                // Utilise la forme/padding/elevation du thème si non spécifié ici
                textStyle: textTheme
                    .labelLarge, // Assure la cohérence de la taille/graisse
              )
                  // Fusionne avec le style du thème pour l'état désactivé
                  // (nécessaire car on a redéfini le style de base)
                  .merge(Theme.of(context).elevatedButtonTheme.style),

              child: const Text("Next"),
            ),
          ]
        ],
      ),
    );
  }
}
