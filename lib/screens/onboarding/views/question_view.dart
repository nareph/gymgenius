// lib/screens/onboarding/views/question_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/models/onboarding_question.dart';
import 'package:gymgenius/screens/onboarding/bloc/onboarding_bloc.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialAnswer();
      }
    });
  }

  void _loadInitialAnswer() {
    final bloc = context.read<OnboardingBloc>();
    final existingAnswer = bloc.state.answers[widget.question.id];

    if (widget.question.type == QuestionType.multipleChoice &&
        existingAnswer is List) {
      setState(() {
        _selectedValues = Set<String>.from(existingAnswer.whereType<String>());
      });
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.03), // Réduction du padding vertical
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.question.text,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.03), // Réduction de l'espacement

          if (widget.question.type == QuestionType.singleChoice)
            // Envelopper les options singleChoice dans un Expanded + SingleChildScrollView si elles peuvent aussi déborder
            Expanded(
              child: SingleChildScrollView(
                // Permet de scroller si beaucoup d'options
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Pour centrer si peu d'options
                  children: widget.question.options
                      .map((option) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _handleSingleChoiceSelection(option.value),
                              child: Text(option.text,
                                  textAlign: TextAlign.center),
                            ),
                          ))
                      .toList(),
                ),
              ),
            )
          else if (widget.question.type == QuestionType.multipleChoice)
            // --- MODIFICATION ICI pour QuestionType.multipleChoice ---
            Expanded(
              // Pour que cette section prenne l'espace restant
              child: Column(
                children: [
                  Expanded(
                    // Pour que le SingleChildScrollView prenne l'espace dans la Column
                    child: SingleChildScrollView(
                      // Rendre la zone des chips scrollable
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: widget.question.options.map((option) {
                          final bool isSelected =
                              _selectedValues.contains(option.value);
                          return InkWell(
                            onTap: () => _handleMultiChoiceSelection(
                                option.value, !isSelected),
                            borderRadius: BorderRadius.circular(25.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 10.0),
                              constraints: const BoxConstraints(minWidth: 70),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                option.text,
                                textAlign: TextAlign.center,
                                style: textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // --- "Next" Button for Multiple Choice (en dehors du SingleChildScrollView) ---
                  SizedBox(
                      height:
                          screenHeight * 0.03), // Espace avant le bouton Next
                  ElevatedButton(
                    onPressed:
                        _selectedValues.isNotEmpty ? widget.onNext : null,
                    child: const Text("NEXT"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
